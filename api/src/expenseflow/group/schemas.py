"""Group schemas."""

from uuid import UUID

from expenseflow.schemas import ExpenseFlowBase


class GroupSchema(ExpenseFlowBase):
    """Group schema."""

    group_id: UUID
    name: str
    description: str


class GroupCreateSchema(ExpenseFlowBase):
    """Group create schema."""

    name: str
    description: str


class GroupUpdateSchema(ExpenseFlowBase):
    """Group update schema."""

    name: str | None = None
    description: str | None = None
