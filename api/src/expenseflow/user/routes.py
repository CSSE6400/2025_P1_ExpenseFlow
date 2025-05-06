"""User endpoints."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.errors import ExistsError
from expenseflow.user.schemas import UserCreateSchema, UserSchema
from expenseflow.user.service import create_user, get_user_by_id

r = router = APIRouter()


@r.get("")
async def get_me(user: CurrentUser) -> UserSchema:
    """Get current user."""
    return user


@r.get("/{user_id}")
# TODO: Need to replace CurrentUser  # noqa: FIX002, TD002, TD003
async def get_user(db: DbSession, _: CurrentUser, user_id: UUID) -> UserSchema:
    """Endpoint to get user by id."""
    user = await get_user_by_id(db, user_id)
    if user is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the id '{user_id}' could not be found",
        )
    return user


@r.post("")
async def create(db: DbSession, user_in: UserCreateSchema) -> UserSchema:
    """Create a new user."""
    try:
        return await create_user(db, user_in)
    except ExistsError as e:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            detail=f"User already exists under the email '{user_in.email}'",
        ) from e
