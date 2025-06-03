"""User endpoints."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser, CurrentUserTokenID
from expenseflow.database.deps import DbSession
from expenseflow.errors import ExistsError
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import (
    UserCreate,
    UserCreateInternal,
    UserRead,
    UserReadMinimal,
    UserUpdate,
)
from expenseflow.user.service import (
    create_user,
    get_all_users,
    get_user_by_id,
    get_user_by_nickname,
    update_user,
)

r = router = APIRouter()


@r.get("", response_model=UserRead)
async def get_me(user: CurrentUser) -> UserModel:
    """Get current user."""
    return user


@r.get("/all", response_model=list[UserReadMinimal])
async def get_all(db: DbSession, me: CurrentUser) -> list[UserModel]:
    """Get all users."""
    users = await get_all_users(db)
    return [u for u in users if u.user_id != me.user_id]


@r.get("/nickname-taken", response_model=bool)
async def check_nickname_taken(
    db: DbSession, _: CurrentUserTokenID, nickname: str
) -> bool:
    """Check if nickname is taken."""
    user = await get_user_by_nickname(db, nickname)
    return user is not None


@r.get("/{user_id}", response_model=UserRead)
async def get_user(db: DbSession, _: CurrentUser, user_id: UUID) -> UserModel:
    """Endpoint to get user by id."""
    user = await get_user_by_id(db, user_id)
    if user is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the id '{user_id}' could not be found",
        )
    return user


@r.post("", response_model=UserRead)
async def create(
    db: DbSession, user_token_id: CurrentUserTokenID, user_in: UserCreate
) -> UserModel:
    """Create a new user."""
    data = UserCreateInternal(
        nickname=user_in.nickname,
        first_name=user_in.first_name,
        last_name=user_in.last_name,
        budget=user_in.budget,
        token_id=user_token_id,
    )
    try:
        return await create_user(db, data)
    except ExistsError as e:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            detail=f"User already exists with the nickname '{user_in.nickname}'.",
        ) from e


@r.put("", response_model=UserRead)
async def update(user: CurrentUser, user_in: UserUpdate) -> UserModel:
    """Create a new user."""
    return await update_user(user, user_in)
