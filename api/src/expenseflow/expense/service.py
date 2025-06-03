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
        session, creator, expense_in.items
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
        session, modifier, expense_in.items
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
    session: AsyncSession, creator: UserModel, expense_items_in: list[ExpenseItemCreate]
) -> list[ExpenseItemModel]:
    """Creates expense items.

    Args:
        session (AsyncSession): db session
        creator (UserModel): creator of the expense
        expense_items_in (list[ExpenseItemCreate]): list of expense items

    Raises:
        ExpenseFlowError: Raised if splits don't add up to 100%
        NotFoundError: Raised if invalid user is specified in the split

    Returns:
        list[ExpenseItemModel]: newly created expense items
    """
    result: list[ExpenseItemModel] = []
    for item_in in expense_items_in:  # Go through each item
        splits: list[ExpenseItemSplitModel]

        if item_in.splits is not None and item_in.splits != []:
            splits = []

            # Expense splits must sum to 100%
            proportion_sum = sum([split.proportion for split in item_in.splits])
            if proportion_sum != 1:
                logger.info(
                    f"Splits for item {item_in.name} do not add up to 1, instead '{proportion_sum}'."
                )
                msg = f"The total proportion of the '{item_in.name}' item does not add to 1."
                raise ExpenseFlowError(msg)

            user_ids = [split.user_id for split in item_in.splits]
            if len(user_ids) != len(set(user_ids)):
                msg = f"A user_id is duplicated in splits for item '{item_in.name}'"
                raise ExpenseFlowError(msg)

            for split_create in item_in.splits:
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

        else:  # If no split specified, assume creator owns entire expense
            splits = [
                ExpenseItemSplitModel(
                    user=creator,
                    proportion=1,
                    status=ExpenseStatus.paid,
                )
            ]

        result.append(
            ExpenseItemModel(
                name=item_in.name,
                quantity=item_in.quantity,
                price=item_in.price,
                splits=splits,
            )
        )

    return result


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
    status_map = {
        ExpenseStatus.requested: 1,
        ExpenseStatus.accepted: 2,
        ExpenseStatus.paid: 3,
    }
    input_status_num = status_map[input_status]
    usr_status_num = status_map[usr_status]
    exp_status_num = status_map[exp_status]
    INVALID_SKIP_NUM = 2  # noqa: N806

    if (
        exp_status_num > usr_status_num
        or abs(usr_status_num - exp_status_num) == INVALID_SKIP_NUM
    ):
        msg = (
            f"The expense should only be in state '{exp_status}' if everyone is in state "
            f"'{exp_status}' or above, so this split is invalid as its in state '{usr_status}'"
        )
        logger.error(msg)
        raise InvalidStateError(msg)

    # Don't do anything when the status are the same
    if input_status == usr_status and usr_status == exp_status:
        return True

    if (
        abs(input_status_num - usr_status_num) == INVALID_SKIP_NUM
        or abs(input_status_num - exp_status_num) == INVALID_SKIP_NUM
    ):
        return False

    # Can't decrease usr's state when everything is requested or accepted or paid
    if (  # noqa: SIM103
        exp_status == usr_status and input_status_num - usr_status_num == -1
    ):
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
            return ExpenseStatus.paid

        msg = f"User '{user.user_id}' is not have any splits in this expense."
        raise ExpenseFlowError(msg)

    uniques = set(statuses)
    if len(uniques) != 1:
        msg = f"User '{user.user_id}' has splits in expense '{expense.expense_id}' that don't have the same status"
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

    if all(status == ExpenseStatus.paid for status in statuses):
        return ExpenseStatus.paid

    if all(status == ExpenseStatus.accepted for status in statuses):
        return ExpenseStatus.accepted

    return ExpenseStatus.requested


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
