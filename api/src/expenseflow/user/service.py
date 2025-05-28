"""User service."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.errors import ExistsError
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreateInternal


async def get_user_by_id(session: AsyncSession, user_id: UUID) -> UserModel | None:
    """Get a user by their id."""
    return await session.get(UserModel, user_id)


async def get_user_by_token_id(
    session: AsyncSession, token_id: str
) -> UserModel | None:
    """Get user by their token id."""
    return (
        await session.execute(select(UserModel).where(UserModel.token_id == token_id))
    ).scalar_one_or_none()


async def get_user_by_nickname(
    session: AsyncSession, nickname: str
) -> UserModel | None:
    """Get user by their nickname."""
    return (
        await session.execute(select(UserModel).where(UserModel.nickname == nickname))
    ).scalar_one_or_none()


async def create_user(session: AsyncSession, user_in: UserCreateInternal) -> UserModel:
    """Create user."""
    existing_user = await get_user_by_token_id(session, user_in.token_id)
    if existing_user is not None:
        return existing_user

    existing_user = await get_user_by_nickname(session, user_in.nickname)
    if existing_user is not None:
        msg = f"User already exists with the nickname '{user_in.nickname}'."
        raise ExistsError(msg)

    new_user = UserModel(
        nickname=user_in.nickname,
        first_name=user_in.first_name,
        last_name=user_in.last_name,
        token_id=user_in.token_id,
    )

    session.add(new_user)
    await session.commit()
    return new_user
