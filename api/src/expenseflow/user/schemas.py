"""User schemas."""

from uuid import UUID

from expenseflow.schemas import ExpenseFlowBase


class UserSchema(ExpenseFlowBase):
    """User schema."""

    user_id: UUID
    email: str
    first_name: str
    last_name: str


class UserCreateSchema(ExpenseFlowBase):
    """Create user schema."""

    email: str
    first_name: str
    last_name: str
