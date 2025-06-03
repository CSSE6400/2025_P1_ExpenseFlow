"""Friend routes."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseRead
from expenseflow.friend.models import FriendModel
from expenseflow.friend.schemas import FriendRead
from expenseflow.friend.service import (
    create_accept_friend_request,
    get_friend_expenses,
    get_friends,
    get_received_friend_requests,
    get_sent_friend_requests,
    remove_friend,
)
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserRead
from expenseflow.user.service import get_user_by_id, get_user_by_nickname

r = router = APIRouter()


@r.get("", response_model=list[UserRead])
async def friends(db: DbSession, user: CurrentUser) -> list[UserModel]:
    """Get my friends."""
    return await get_friends(db, user)


@r.get("/requests", response_model=list[UserRead])
async def get_requests(
    db: DbSession, user: CurrentUser, sent: bool  # noqa: FBT001
) -> list[UserModel]:
    """Get incoming friend requests."""
    if sent:
        return await get_sent_friend_requests(db, user)

    return await get_received_friend_requests(db, user)


@r.get("/{user_id}", response_model=UserRead)
async def get(db: DbSession, user: CurrentUser, user_id: UUID) -> UserModel:
    """Get friend by id."""
    other_user = await get_user_by_id(db, user_id)
    my_friends = await get_friends(db, user)
    if other_user is None or other_user.user_id not in [f.user_id for f in my_friends]:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the id '{user_id}' could not be found",
        )
    return other_user


@r.get("/{user_id}/expenses", response_model=list[ExpenseRead])
async def get_expenses(
    db: DbSession, user: CurrentUser, user_id: UUID
) -> list[ExpenseModel]:
    """Get friend expenses."""
    other_user = await get_user_by_id(db, user_id)
    my_friends = await get_friends(db, user)
    if other_user is None or other_user.user_id not in [f.user_id for f in my_friends]:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the id '{user_id}' could not be found",
        )

    return await get_friend_expenses(db, user, other_user)


@r.put("", response_model=FriendRead)
async def create_w_nickname(
    db: DbSession, user: CurrentUser, nickname: str
) -> FriendModel:
    """Add friend by nickname."""
    other_user = await get_user_by_nickname(db, nickname)
    if other_user is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the nickname '{nickname}' could not be found",
        )
    return await create_accept_friend_request(db, user, other_user)


@r.put("/{user_id}", response_model=FriendRead)
async def create(db: DbSession, user: CurrentUser, user_id: UUID) -> FriendModel:
    """Creates or Updates Friend Request."""
    other_user = await get_user_by_id(db, user_id)
    if other_user is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the id '{user_id}' could not be found",
        )
    return await create_accept_friend_request(db, user, other_user)


@r.delete("/{user_id}")
async def delete(db: DbSession, current_user: CurrentUser, user_id: UUID) -> None:
    """Deletes or cancels a friend/friend request."""
    other_user = await get_user_by_id(db, user_id)
    if other_user is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the id '{user_id}' could not be found",
        )
    _ = await remove_friend(db, current_user, other_user)
