"""Test user service."""

import pytest
from expenseflow.user.schemas import UserCreateInternal
from sqlalchemy.ext.asyncio import AsyncSession


@pytest.mark.asyncio()
async def test_get_user_by_id(
    session: AsyncSession, user_create_internal: UserCreateInternal
):
    from expenseflow.user.service import create_user, get_user_by_id

    created = await create_user(session, user_create_internal)

    found = await get_user_by_id(session, created.user_id)
    assert found is not None
    assert found.nickname == user_create_internal.nickname
    assert found.first_name == user_create_internal.first_name
    assert found.last_name == user_create_internal.last_name


@pytest.mark.asyncio()
async def test_get_user_by_id_not_found(session: AsyncSession):
    from uuid import uuid4

    from expenseflow.user.service import get_user_by_id

    found = await get_user_by_id(session, uuid4())
    assert found is None


@pytest.mark.asyncio()
async def test_create_user(
    session: AsyncSession, user_create_internal: UserCreateInternal
):
    from expenseflow.user.service import create_user

    new_user = await create_user(session, user_create_internal)

    assert new_user.token_id == user_create_internal.token_id
    assert new_user.nickname == user_create_internal.nickname
    assert new_user.last_name == user_create_internal.last_name
    assert new_user.first_name == user_create_internal.first_name
