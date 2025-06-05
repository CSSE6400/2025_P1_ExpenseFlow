"""Expense Schemas."""

import datetime as dt
from uuid import UUID

from pydantic import computed_field

from expenseflow.entity.schemas import EntityRead
from expenseflow.enums import EntityKind, ExpenseCategory, ExpenseStatus
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

    parent: EntityRead
    uploader: UserRead
    items: list["ExpenseItemRead"]

    @computed_field
    def parent_kind(self) -> EntityKind:
        """Return the kind of parent."""
        return self.parent.kind

    @computed_field
    def expense_total(self) -> float:
        """Total cost of the expense."""
        return sum(item.quantity * item.price for item in self.items)

    @computed_field
    def status(self) -> ExpenseStatus:
        """Status of the expense."""
        statuses = [split.status for item in self.items for split in item.splits]

        lowest_status: ExpenseStatus = ExpenseStatus.paid

        for status in statuses:
            if status.ranking() < lowest_status.ranking():
                lowest_status = status

        return lowest_status


class ExpenseCreate(ExpenseFlowBase):
    """Expense create schema."""

    name: str
    description: str
    expense_date: dt.datetime
    category: ExpenseCategory
    items: list["ExpenseItemCreate"]
    splits: list["ExpenseItemSplitCreate"] | None = None


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


class ExpenseItemSplitCreate(ExpenseFlowBase):
    """Create schema for expense splitting."""

    user_id: UUID
    proportion: float


class ExpenseItemSplitRead(ExpenseFlowBase):
    """Read schema for expense splitting."""

    user_id: UUID
    proportion: float
    user_fullname: str
    status: ExpenseStatus


class ExpenseOverviewCategory(ExpenseFlowBase):
    """Expense overview category."""

    category: ExpenseCategory
    total: float


class ExpenseOverview(ExpenseFlowBase):
    """Overview of a users expenses."""

    total: float
    categories: list[ExpenseOverviewCategory]
