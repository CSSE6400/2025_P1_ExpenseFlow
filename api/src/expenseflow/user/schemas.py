"""User schemas."""

from uuid import UUID

from expenseflow.schemas import ExpenseFlowBase


class UserReadMinimal(ExpenseFlowBase):
    """User minimal read schema."""

    user_id: UUID
    nickname: str


class UserRead(ExpenseFlowBase):
    """User read schema."""

    user_id: UUID
    nickname: str
    first_name: str
    last_name: str


class UserCreate(ExpenseFlowBase):
    """Create user schema."""

    nickname: str
    first_name: str
    last_name: str


class UserCreateInternal(UserCreate):
    """Create user schema."""

    token_id: str
