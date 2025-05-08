"""Group schemas."""

import datetime as dt
from uuid import UUID

from expenseflow.enums import GroupRole
from expenseflow.schemas import ExpenseFlowBase


class GroupRead(ExpenseFlowBase):
    """Group schema."""

    group_id: UUID
    name: str
    description: str


class GroupCreate(ExpenseFlowBase):
    """Group create schema."""

    name: str
    description: str


class GroupUpdate(ExpenseFlowBase):
    """Group update schema."""

    name: str | None = None
    description: str | None = None


class UserGroupRead(GroupRead):
    """User group membership."""

    role: GroupRole
    joined_at: dt.datetime
