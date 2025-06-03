"""Group schemas."""

import datetime as dt
from uuid import UUID

from expenseflow.enums import GroupRole
from expenseflow.schemas import ExpenseFlowBase
from expenseflow.user.schemas import UserRead, UserReadMinimal


class GroupRead(ExpenseFlowBase):
    """Group schema."""

    group_id: UUID
    name: str
    description: str


class GroupReadWithMembers(ExpenseFlowBase):
    """Group schema."""

    group_id: UUID
    name: str
    description: str
    members: list[UserReadMinimal]


class GroupCreate(ExpenseFlowBase):
    """Group create schema."""

    name: str
    description: str


class GroupUpdate(ExpenseFlowBase):
    """Group update schema."""

    name: str
    description: str


class GroupUserRead(GroupRead):
    """User group membership with extra group details."""

    role: GroupRole
    joined_at: dt.datetime


class UserGroupRead(UserRead):
    """User group membership with extra user details."""

    role: GroupRole
    joined_at: dt.datetime
