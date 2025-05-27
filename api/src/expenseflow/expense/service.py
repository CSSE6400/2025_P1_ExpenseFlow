"""Expense services."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.entity.models import EntityModel
from expenseflow.expense.models import ExpenseItemModel, ExpenseModel
from expenseflow.expense.schemas import ExpenseCreate
from expenseflow.user.models import UserModel


async def create_expense(
    session: AsyncSession,
    creator: UserModel,
    expense_in: ExpenseCreate,
    parent: EntityModel,
) -> ExpenseModel:
    """Creates an expense."""
    items: list[ExpenseItemModel] = [
        ExpenseItemModel(name=item.name, quantity=item.quantity, price=item.price)
        for item in expense_in.items
    ]

    new_expense = ExpenseModel(
        name=expense_in.name,
        description=expense_in.description,
        category=expense_in.category,
        uploader=creator,
        parent=parent,
        items=items,
    )

    session.add(new_expense)
    await session.commit()
    return new_expense


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


async def get_expenses(
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
