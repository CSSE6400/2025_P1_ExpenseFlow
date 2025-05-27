"""Expense services."""

from uuid import UUID

from loguru import logger
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.entity.models import EntityModel
from expenseflow.errors import ExpenseFlowError, NotFoundError, RoleError
from expenseflow.expense.models import (
    ExpenseItemModel,
    ExpenseItemSplitModel,
    ExpenseModel,
)
from expenseflow.expense.schemas import ExpenseCreate, ExpenseItemCreate
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

    items: list[ExpenseItemModel] = await create_expense_items(
        session, modifier, expense_in.items
    )
    expense.name = expense_in.name
    expense.description = expense_in.description
    expense.category = expense_in.category
    expense.expense_date = expense_in.expense_date
    expense.items = items

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
        ValueError: Raised if splits don't add up to 100%
        ExistsError: Raised if invalid user is specified in the split

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
                        user=split_user, proportion=split_create.proportion
                    )
                )

        else:  # If no split specified, assume creator owns entire expense
            splits = [ExpenseItemSplitModel(user=creator, proportion=1)]

        result.append(
            ExpenseItemModel(
                name=item_in.name,
                quantity=item_in.quantity,
                price=item_in.price,
                splits=splits,
            )
        )

    return result


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
