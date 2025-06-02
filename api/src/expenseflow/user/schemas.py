"""User schemas."""

from uuid import UUID

from pydantic import Field

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
    budget: int


class UserCreate(ExpenseFlowBase):
    """Create user schema."""

    nickname: str
    first_name: str
    last_name: str
    budget: int = Field(gt=0)


class UserUpdate(ExpenseFlowBase):
    """Update user schema."""

    budget: int = Field(gt=0)


class UserCreateInternal(UserCreate):
    """Create user schema."""

    token_id: str
