"""User service."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.errors import ExistsError
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreateSchema, UserSchema


async def get_user_by_id(session: AsyncSession, user_id: UUID) -> UserSchema | None:
    """Get a user by their id."""
    user_model = await session.get(UserModel, user_id)
    if user_model is None:
        return None
    return user_model.to_schema()


async def get_user_by_email(session: AsyncSession, email: str) -> UserSchema | None:
    """Get user by their email."""
    user = (
        await session.execute(select(UserModel).where(UserModel.email == email))
    ).scalar_one_or_none()
    return None if user is None else user.to_schema()


async def create_user(session: AsyncSession, user_in: UserCreateSchema) -> UserSchema:
    """Create user."""
    existing_user = await get_user_by_email(session, user_in.email)
    if existing_user is not None:
        msg = "User under the email '{}' already exists."
        raise ExistsError(msg)

    new_user = UserModel(
        email=user_in.email, first_name=user_in.first_name, last_name=user_in.last_name
    )

    session.add(new_user)
    await session.commit()
    return new_user.to_schema()
