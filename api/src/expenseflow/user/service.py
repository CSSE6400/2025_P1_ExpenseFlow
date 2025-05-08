"""User service."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.errors import ExistsError
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreate


async def get_user_by_id(session: AsyncSession, user_id: UUID) -> UserModel | None:
    """Get a user by their id."""
    return await session.get(UserModel, user_id)


async def get_user_by_email(session: AsyncSession, email: str) -> UserModel | None:
    """Get user by their email."""
    return (
        await session.execute(select(UserModel).where(UserModel.email == email))
    ).scalar_one_or_none()


async def create_user(session: AsyncSession, user_in: UserCreate) -> UserModel:
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
    return new_user
