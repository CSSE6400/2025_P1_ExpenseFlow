"""Friend schemas."""

from expenseflow.enums import FriendStatus
from expenseflow.schemas import ExpenseFlowBase
from expenseflow.user.schemas import UserRead


class FriendRead(ExpenseFlowBase):
    """Friend read schema."""

    receiver: UserRead
    status: FriendStatus
