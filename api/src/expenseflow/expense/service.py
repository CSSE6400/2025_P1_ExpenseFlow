"""Expense services."""

from uuid import UUID

from loguru import logger
from sqlalchemy import delete, func, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.entity.models import EntityModel
from expenseflow.enums import ExpenseStatus
from expenseflow.errors import (
    ExpenseFlowError,
    InvalidStateError,
    NotFoundError,
    RoleError,
)
from expenseflow.expense.models import (
    ExpenseItemModel,
    ExpenseItemSplitModel,
    ExpenseModel,
)
from expenseflow.expense.schemas import (
    ExpenseCreate,
    ExpenseItemCreate,
    ExpenseItemSplitCreate,
    ExpenseOverview,
    ExpenseOverviewCategory,
)
from expenseflow.user.models import UserModel


async def create_expense(
    session: AsyncSession,
    creator: UserModel,
    expense_in: ExpenseCreate,
    parent: EntityModel,
) -> ExpenseModel:
    """Creates an expense."""
    items: list[ExpenseItemModel] = await create_expense_items(
        session, creator, expense_in.items, expense_in.splits
    )

    new_expense = ExpenseModel(
        name=expense_in.name,
        description=expense_in.description,
        category=expense_in.category,
        uploader=creator,
        expense_date=expense_in.expense_date,
        parent=parent,
        items=items,
    )

    session.add(new_expense)
    await session.commit()
    return new_expense


async def update_expense(
    session: AsyncSession,
    modifier: UserModel,
    expense: ExpenseModel,
    expense_in: ExpenseCreate,
) -> ExpenseModel:
    """Updates an expense."""
    if (
        expense.uploader_id != modifier.user_id
        and expense.parent_id != modifier.entity_id
    ):
        msg = f"User does not have permission to modify the expense '{expense.expense_id}'"
        raise RoleError(msg)

    user_splits = await get_split_users(session, expense)
    exp_status = await get_expense_status(session, expense)

    # If an expense is split solely with its creator, they can change it around
    split_soley_w_creator = (
        len(user_splits) == 1 and user_splits[0].user_id == expense.uploader_id
    )

    if (
        exp_status in (ExpenseStatus.accepted, ExpenseStatus.paid)
        and not split_soley_w_creator
    ):
        msg = f"Unable to modify the '{expense.expense_id}' expense when it is in the '{exp_status.value}' state"
        raise ExpenseFlowError(msg)

    items: list[ExpenseItemModel] = await create_expense_items(
        session, modifier, expense_in.items, expense_in.splits
    )

    expense.name = expense_in.name
    expense.description = expense_in.description
    expense.category = expense_in.category
    expense.expense_date = expense_in.expense_date

    # reset all splits to requested
    update_stmt = (
        update(ExpenseItemSplitModel)
        .where(
            ExpenseItemSplitModel.expense_item_id == ExpenseItemModel.expense_item_id
        )
        .where(ExpenseItemModel.expense_id == ExpenseModel.expense_id)
        .where(ExpenseModel.expense_id == expense.expense_id)
        .values(status=ExpenseStatus.requested)
    )

    await session.execute(update_stmt)

    # remove existing items
    await session.execute(
        delete(ExpenseItemModel).where(
            ExpenseItemModel.expense_id == expense.expense_id
        )
    )

    # attach new items
    for item in items:
        item.expense_id = expense.expense_id
        session.add(item)  # Explicitly add

    await session.commit()

    return expense


async def create_expense_items(
    session: AsyncSession,
    creator: UserModel,
    expense_items_in: list[ExpenseItemCreate],
    splits_in: list[ExpenseItemSplitCreate] | None,
) -> list[ExpenseItemModel]:
    """Creates expense items.

    Args:
        session (AsyncSession): db session
        creator (UserModel): creator of the expense
        expense_items_in (list[ExpenseItemCreate]): list of expense items
        splits_in (list[ExpenseItemSplitCreate] | None): splits for the expense items

    Raises:
        ExpenseFlowError: Raised if splits don't add up to 100%
        NotFoundError: Raised if invalid user is specified in the split

    Returns:
        list[ExpenseItemModel]: newly created expense items
    """
    return [
        ExpenseItemModel(
            name=item_in.name,
            quantity=item_in.quantity,
            price=item_in.price,
            splits=(await create_splits(session, splits_in, creator)),
        )
        for item_in in expense_items_in
    ]


async def create_splits(
    session: AsyncSession,
    splits_in: list[ExpenseItemSplitCreate] | None,
    creator: UserModel,
) -> list[ExpenseItemSplitModel]:
    """Create splits from input."""
    splits: list[ExpenseItemSplitModel] = []

    if splits_in is not None and splits_in != []:

        user_ids = [split.user_id for split in splits_in]
        if len(user_ids) != len(set(user_ids)):
            msg = "A user_id is duplicated in splits"
            raise ExpenseFlowError(msg)

        # Expense splits must sum to 100%
        proportion_sum = sum([split.proportion for split in splits_in])
        if proportion_sum != 1:
            msg = f"Splits do not add up to 1, instead '{proportion_sum}'."
            logger.info(msg)
            raise ExpenseFlowError(msg)
        for split_create in splits_in:
            split_user = await session.get(UserModel, split_create.user_id)
            if split_user is None:
                raise NotFoundError(split_create.user_id, "user")
            splits.append(
                ExpenseItemSplitModel(
                    user=split_user,
                    proportion=split_create.proportion,
                    # If the creator is splitting, they've already paid for it
                    status=(
                        ExpenseStatus.paid
                        if split_user.user_id == creator.user_id
                        else ExpenseStatus.requested
                    ),
                )
            )
    else:
        splits = [
            ExpenseItemSplitModel(
                user=creator,
                proportion=1.0,
                status=ExpenseStatus.paid,  # Creator has paid for it
            )
        ]

    return splits


async def update_split_status(
    session: AsyncSession, user: UserModel, expense: ExpenseModel, status: ExpenseStatus
) -> None:
    """Update a user's split status of an expense."""
    usr_split_status = await get_user_split_status(session, expense, user)
    cur_expense_status = await get_expense_status(session, expense)

    # Check whether usr has had the expense split with them
    usr_splits = await get_split_users(session, expense)
    if user.user_id not in [u.user_id for u in usr_splits]:
        msg = f"User '{user.user_id}' has no splits in this expense"
        raise ExpenseFlowError(msg)

    if not is_valid_expense_change(status, usr_split_status, cur_expense_status):
        msg = f"Unable to change your expense status from '{usr_split_status.value}' to '{status.value}'"
        raise ExpenseFlowError(msg)

    # Do some status change
    update_stmt = (
        update(ExpenseItemSplitModel)
        .where(
            ExpenseItemSplitModel.expense_item_id == ExpenseItemModel.expense_item_id
        )
        .where(ExpenseItemModel.expense_id == ExpenseModel.expense_id)
        .where(ExpenseModel.expense_id == expense.expense_id)
        .where(ExpenseItemSplitModel.user_id == user.user_id)
        .values(status=status)
    )

    await session.execute(update_stmt)


def is_valid_expense_change(
    input_status: ExpenseStatus, usr_status: ExpenseStatus, exp_status: ExpenseStatus
) -> bool:
    """Function to manage expense state changes."""
    INVALID_SKIP_NUM = 2  # noqa: N806

    if (
        exp_status.ranking() > usr_status.ranking()
        or abs(usr_status.ranking() - exp_status.ranking()) == INVALID_SKIP_NUM
    ):
        msg = (
            f"The expense should only be in state '{exp_status}' if everyone is in state "
            f"'{exp_status}' or above, so this split is invalid as its in state '{usr_status}'"
        )
        logger.error(msg)
        raise InvalidStateError(msg)

    # Don't do anything when the status are the same
    if input_status == usr_status and usr_status == exp_status:
        logger.debug("No change in expense status, skipping update")
        return True

    if (
        abs(input_status.ranking() - usr_status.ranking()) == INVALID_SKIP_NUM
        or abs(input_status.ranking() - exp_status.ranking()) == INVALID_SKIP_NUM
    ):
        logger.debug(
            "Invalid expense status change, skipping update. "
            f"Input: {input_status.value}, User: {usr_status.value}, Expense: {exp_status.value}"
        )
        return False

    # Can't decrease usr's state when everything is requested or accepted or paid
    if exp_status == usr_status and input_status.ranking() - usr_status.ranking() == -1:
        logger.debug(
            "Invalid expense status change, skipping update. "
            f"Input: {input_status.value}, User: {usr_status.value}, Expense: {exp_status.value}"
        )
        return False

    return True


async def get_user_split_status(
    session: AsyncSession, expense: ExpenseModel, user: UserModel
) -> ExpenseStatus:
    """Get current status of a users split."""
    stmt = (
        select(ExpenseItemSplitModel.status)
        .join(
            ExpenseItemModel,
            ExpenseItemModel.expense_item_id == ExpenseItemSplitModel.expense_item_id,
        )
        .join(ExpenseModel, ExpenseModel.expense_id == ExpenseItemModel.expense_id)
        .where(ExpenseModel.expense_id == expense.expense_id)
        .where(ExpenseItemSplitModel.user_id == user.user_id)
    )

    statuses = (await session.execute(stmt)).scalars().all()

    if len(statuses) == 0:
        if expense.uploader_id == user.user_id or expense.parent_id == user.entity_id:
            logger.debug(
                f"User '{user.user_id}' has no splits in expense '{expense.expense_id}', "
                "but is the uploader or parent, so returning paid status."
            )
            return ExpenseStatus.paid

        msg = f"User '{user.user_id}' does not have any splits in this expense."
        raise ExpenseFlowError(msg)

    uniques = set(statuses)
    if len(uniques) != 1:
        msg = f"User '{user.user_id}' has splits in expense '{expense.expense_id}' that don't have the same status"
        logger.error(msg)
        raise Exception(msg)  # noqa: TRY002

    return uniques.pop()


async def get_split_users(
    session: AsyncSession, expense: ExpenseModel
) -> list[UserModel]:
    """Get the users an expense is split with."""
    stmt = (
        select(UserModel)
        .join(ExpenseItemSplitModel, ExpenseItemSplitModel.user_id == UserModel.user_id)
        .join(
            ExpenseItemModel,
            ExpenseItemModel.expense_item_id == ExpenseItemSplitModel.expense_item_id,
        )
        .join(ExpenseModel, ExpenseModel.expense_id == ExpenseItemModel.expense_id)
        .where(ExpenseModel.expense_id == expense.expense_id)
        .distinct()
    )
    return list((await session.execute(stmt)).scalars().all())


async def get_expense_status(
    session: AsyncSession, expense: ExpenseModel
) -> ExpenseStatus:
    """Get the status of an expense."""
    stmt = (
        select(ExpenseItemSplitModel.status)
        .join(
            ExpenseItemModel,
            ExpenseItemModel.expense_item_id == ExpenseItemSplitModel.expense_item_id,
        )
        .join(ExpenseModel, ExpenseModel.expense_id == ExpenseItemModel.expense_id)
        .where(ExpenseModel.expense_id == expense.expense_id)
    )

    statuses: list[ExpenseStatus] = list((await session.execute(stmt)).scalars().all())

    lowest_status: ExpenseStatus = ExpenseStatus.paid
    for status in statuses:
        if status.ranking() < lowest_status.ranking():
            lowest_status = status

    return lowest_status


async def get_uploaded_expenses(
    session: AsyncSession, uploader: UserModel
) -> list[ExpenseModel]:
    """Get all expenses someone has uploaded."""
    return list(
        (
            await session.execute(
                select(ExpenseModel).where(ExpenseModel.uploader_id == uploader.user_id)
            )
        )
        .scalars()
        .all()
    )


async def get_expense_status_map(
    session: AsyncSession, expense: ExpenseModel
) -> dict[UserModel, ExpenseStatus]:
    """Get a mapping of all the statuses for an expense."""
    stmt = (
        select(UserModel, ExpenseItemSplitModel.status)
        .join(
            ExpenseItemModel,
            ExpenseItemModel.expense_item_id == ExpenseItemSplitModel.expense_item_id,
        )
        .join(
            UserModel,
            UserModel.user_id == ExpenseItemSplitModel.user_id,
        )
        .where(ExpenseItemModel.expense_id == expense.expense_id)
    )

    splits = (await session.execute(stmt)).all()

    return dict([row.tuple() for row in splits])


async def get_owned_expenses(
    session: AsyncSession, parent: EntityModel
) -> list[ExpenseModel]:
    """Get all expenses owned by someone."""
    return list(
        (
            await session.execute(
                select(ExpenseModel).where(ExpenseModel.parent_id == parent.entity_id)
            )
        )
        .scalars()
        .all()
    )


async def get_all_expenses(
    session: AsyncSession, user: UserModel
) -> list[ExpenseModel]:
    """Gets all expenses that a user is involved in."""
    exists_in_split_q = (
        select(1)
        .select_from(ExpenseItemModel)
        .join(
            ExpenseItemSplitModel,
            ExpenseItemModel.expense_item_id == ExpenseItemSplitModel.expense_item_id,
        )
        .where(ExpenseItemSplitModel.user_id == user.user_id)
        .where(ExpenseItemModel.expense_id == ExpenseModel.expense_id)
        .limit(1)
        .exists()
    )

    stmt = select(ExpenseModel).where(
        or_(
            ExpenseModel.uploader_id == user.user_id,
            exists_in_split_q,
        )
    )

    return list((await session.execute(stmt)).scalars().all())


async def get_expense(
    session: AsyncSession, user: UserModel, expense_id: UUID
) -> ExpenseModel | None:
    """Get a expense with a given 'id'. Expense must be owned, uploaded or split with the user."""
    exists_in_split_q = (
        select(1)
        .select_from(ExpenseItemModel)
        .join(
            ExpenseItemSplitModel,
            ExpenseItemModel.expense_item_id == ExpenseItemSplitModel.expense_item_id,
        )
        .where(ExpenseItemModel.expense_id == expense_id)
        .where(ExpenseItemSplitModel.user_id == user.user_id)
        .exists()
    )

    stmt = (
        select(ExpenseModel)
        .where(ExpenseModel.expense_id == expense_id)
        .where(
            or_(
                ExpenseModel.uploader_id == user.user_id,
                ExpenseModel.parent_id == user.entity_id,
                exists_in_split_q,
            )
        )
    )

    return (await session.execute(stmt)).scalar_one_or_none()


async def get_expenses_overview(
    session: AsyncSession, user: UserModel
) -> ExpenseOverview:
    """Get an overview of a user's expenses."""
    categories_query = (
        select(
            ExpenseModel.category,
            func.sum(
                ExpenseItemModel.price
                * ExpenseItemModel.quantity
                * ExpenseItemSplitModel.proportion
            ).label("category_total"),
        )
        .select_from(ExpenseItemSplitModel)
        .join(
            ExpenseItemModel,
            ExpenseItemModel.expense_item_id == ExpenseItemSplitModel.expense_item_id,
        )
        .join(ExpenseModel, ExpenseModel.expense_id == ExpenseItemModel.expense_id)
        .where(ExpenseItemSplitModel.user_id == user.user_id)
        .group_by(ExpenseModel.category)
    )

    rows = (await session.execute(categories_query)).all()

    categories = [
        ExpenseOverviewCategory(category=category, total=round(total, 2))
        for category, total in rows
    ]

    overall_total = round(sum(cat.total for cat in categories), 2)

    return ExpenseOverview(total=overall_total, categories=categories)
