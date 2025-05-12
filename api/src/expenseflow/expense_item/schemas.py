"""Expense Item Schemas."""

from uuid import UUID

from expenseflow.schemas import ExpenseFlowBase


class ExpenseItemRead(ExpenseFlowBase):
    """Base read schema for expense items."""

    expense_item_id: UUID
    name: str
    quantity: int
    price: float


class ExpenseItemCreate(ExpenseFlowBase):
    """Create schema for expense items."""

    name: str
    quantity: int
    price: float
