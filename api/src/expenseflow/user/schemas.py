"""User schemas."""

from uuid import UUID

from expenseflow.schemas import ExpenseFlowBase


class UserRead(ExpenseFlowBase):
    """User read schema."""

    user_id: UUID
    email: str
    first_name: str
    last_name: str


class UserCreate(ExpenseFlowBase):
    """Create user schema."""

    email: str
    first_name: str
    last_name: str
