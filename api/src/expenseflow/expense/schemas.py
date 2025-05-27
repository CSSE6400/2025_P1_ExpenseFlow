"""Expense Schemas."""

import datetime as dt
from uuid import UUID

from expenseflow.enums import ExpenseCategory
from expenseflow.schemas import ExpenseFlowBase
from expenseflow.user.schemas import UserRead


class ExpenseRead(ExpenseFlowBase):
    """Expense read schema."""

    expense_id: UUID
    name: str
    description: str
    category: ExpenseCategory
    expense_date: dt.datetime

    uploader: UserRead
    items: list["ExpenseItemRead"]


class ExpenseCreate(ExpenseFlowBase):
    """Expense create schema."""

    name: str
    description: str
    expense_date: dt.datetime
    category: ExpenseCategory
    items: list["ExpenseItemCreate"]


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
