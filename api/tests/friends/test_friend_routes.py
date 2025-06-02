"""Test Friend Routes."""

import pytest  # noqa: F401

from expenseflow.enums import FriendStatus
from expenseflow.friend.models import UserModel, FriendModel
from expenseflow.friend.schemas import FriendRead, UserRead
from expenseflow.friend.service import create_accept_friend_request, \
    get_sent_friend_requests, get_received_friend_requests, get_friends, \
    remove_friend
from sqlalchemy.ext.asyncio import AsyncSession
from httpx import AsyncClient
from expenseflow.errors import ExpenseFlowError

@pytest.mark.asyncio
