"""User endpoints."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.errors import ExistsError
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreate, UserRead
from expenseflow.user.service import create_user, get_user_by_id

r = router = APIRouter()


@r.get("", response_model=UserRead)
async def get_me(user: CurrentUser) -> UserModel:
    """Get current user."""
    return user


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
# TODO: Need to replace CurrentUser  # noqa: FIX002, TD002, TD003
async def create(db: DbSession, user_in: UserCreate) -> UserModel:
    """Create a new user."""
    try:
        return await create_user(db, user_in)
    except ExistsError as e:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            detail=f"User already exists under the email '{user_in.email}'",
        ) from e
