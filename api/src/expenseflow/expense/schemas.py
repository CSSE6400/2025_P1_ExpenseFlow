"""Expense Schemas."""

import datetime as dt
from uuid import UUID

from expenseflow.enums import ExpenseCategory, ExpenseStatus
from expenseflow.schemas import ExpenseFlowBase
from expenseflow.user.schemas import UserRead


class SplitStatusInfo(ExpenseFlowBase):
    """Info on a user's split."""

    user_id: UUID
    nickname: str
    status: ExpenseStatus


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
    splits: list["ExpenseItemSplitRead"]


class ExpenseItemCreate(ExpenseFlowBase):
    """Create schema for expense items."""

    name: str
    quantity: int
    price: float
    splits: list["ExpenseItemSplitCreate"] | None = None


class ExpenseItemSplitCreate(ExpenseFlowBase):
    """Create schema for expense splitting."""

    user_id: UUID
    proportion: float


class ExpenseItemSplitRead(ExpenseFlowBase):
    """Read schema for expense splitting."""

    user_id: UUID
    proportion: float
    user_fullname: str


class ExpenseOverviewCategory(ExpenseFlowBase):
    """Expense overview category."""

    category: ExpenseCategory
    total: float


class ExpenseOverview(ExpenseFlowBase):
    """Overview of a users expenses."""

    total: float
    categories: list[ExpenseOverviewCategory]
