"""Expense Schemas."""

from uuid import UUID

from expenseflow.enums import ExpenseCategory
from expenseflow.expense_item.schemas import ExpenseItemCreate, ExpenseItemRead
from expenseflow.schemas import ExpenseFlowBase
from expenseflow.user.schemas import UserRead


class ExpenseRead(ExpenseFlowBase):
    """Expense read schema."""

    expense_id: UUID
    name: str
    description: str
    category: ExpenseCategory

    uploader: UserRead
    items: list[ExpenseItemRead]


class ExpenseCreate(ExpenseFlowBase):
    """Expense create schema."""

    name: str
    description: str
    category: ExpenseCategory
    items: list[ExpenseItemCreate]
