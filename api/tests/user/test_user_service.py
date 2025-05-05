"""Test user service."""

import pytest
from expenseflow.user.schemas import UserCreateSchema
from sqlalchemy.ext.asyncio import AsyncSession


@pytest.mark.asyncio()
async def test_get_user_by_id(session: AsyncSession, user_create: UserCreateSchema):
    from expenseflow.user.service import create_user, get_user_by_id

    created = await create_user(session, user_create)

    found = await get_user_by_id(session, created.user_id)
    assert found is not None
    assert found.email == user_create.email
    assert found.first_name == user_create.first_name
    assert found.last_name == user_create.last_name


@pytest.mark.asyncio()
async def test_get_user_by_id_not_found(session: AsyncSession):
    from uuid import uuid4

    from expenseflow.user.service import get_user_by_id

    found = await get_user_by_id(session, uuid4())
    assert found is None


@pytest.mark.asyncio()
async def test_get_user_by_email(session: AsyncSession, user_create: UserCreateSchema):
    from expenseflow.user.service import create_user, get_user_by_email

    created = await create_user(session, user_create)

    found = await get_user_by_email(session, created.email)

    assert found is not None
    assert found.email == user_create.email
    assert found.first_name == user_create.first_name
    assert found.last_name == user_create.last_name


@pytest.mark.asyncio()
async def test_get_user_by_email_not_found(session: AsyncSession):

    from expenseflow.user.service import get_user_by_email

    found = await get_user_by_email(session, "RANDOM_EMAIL")
    assert found is None


@pytest.mark.asyncio()
async def test_create_user(session: AsyncSession, user_create: UserCreateSchema):
    from expenseflow.user.service import create_user

    new_user = await create_user(session, user_create)

    assert new_user.email == user_create.email
    assert new_user.last_name == user_create.last_name
    assert new_user.first_name == user_create.first_name


@pytest.mark.asyncio()
async def test_create_user_already_exists(
    session: AsyncSession, user_create: UserCreateSchema
):
    from expenseflow.errors import ExistsError
    from expenseflow.user.service import create_user

    # Create first user
    await create_user(session, user_create)

    # Raise error if user created again with same email
    with pytest.raises(ExistsError):
        await create_user(session, user_create)
