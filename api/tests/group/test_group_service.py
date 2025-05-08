"""Test Group Service."""

import pytest
from expenseflow.enums import GroupRole
from expenseflow.group.schemas import GroupCreate, GroupUpdate
from expenseflow.user.models import UserModel
from sqlalchemy.ext.asyncio import AsyncSession


@pytest.mark.asyncio()
async def test_create_group(
    session: AsyncSession, group_create: GroupCreate, user_model: UserModel
):
    from expenseflow.group.service import create_group

    new_group = await create_group(session, user_model, group_create)

    assert new_group.name == group_create.name
    assert new_group.description == group_create.description


@pytest.mark.asyncio()
async def test_create_group_owner_created(
    session: AsyncSession, group_create: GroupCreate, user_model: UserModel
):
    from expenseflow.group.service import create_group

    new_group = await create_group(session, user_model, group_create)

    # Owner is created
    assert len(new_group.users) == 1
    group_user_model = new_group.users[0]

    # Owner is correct
    assert group_user_model.group == new_group
    assert group_user_model.role == GroupRole.admin
    assert group_user_model.user == user_model


@pytest.mark.asyncio()
async def test_get_groups(
    session: AsyncSession, group_create: GroupCreate, user_model: UserModel
):
    from expenseflow.group.service import create_group, get_groups

    g1 = await create_group(session, user_model, group_create)  # Group 1
    g2 = await create_group(session, user_model, group_create)  # Group 2

    user_groups = await get_groups(user_model)

    assert len(user_groups) == 2
    u_g1 = user_groups[0]
    u_g2 = user_groups[1]

    # Group 1
    assert u_g1.group == g1
    assert u_g1.user == user_model

    # Group 2
    assert u_g2.group == g2
    assert u_g2.user == user_model


@pytest.mark.asyncio()
async def test_get_groups_empty(session: AsyncSession, user_model: UserModel):
    from expenseflow.group.service import get_groups

    user_groups = await get_groups(user_model)

    assert len(user_groups) == 0


@pytest.mark.asyncio()
async def test_get_groups_other_user(
    session: AsyncSession,
    group_create: GroupCreate,
    user_model: UserModel,
    default_user: UserModel,
):
    from expenseflow.group.service import create_group, get_groups

    _ = await create_group(session, user_model, group_create)  # Group 1

    user_groups = await get_groups(default_user)

    assert len(user_groups) == 0


@pytest.mark.asyncio()
async def test_get_group(
    session: AsyncSession, group_create: GroupCreate, user_model: UserModel
):
    from expenseflow.group.service import create_group, get_user_group

    g1 = await create_group(session, user_model, group_create)  # Group 1
    _ = await create_group(session, user_model, group_create)  # Group 2

    g1_found = await get_user_group(session, user_model, g1.group_id)

    assert g1_found == g1


@pytest.mark.asyncio()
async def test_get_group_no_group(
    session: AsyncSession,
    group_create: GroupCreate,
    user_model: UserModel,
    default_user: UserModel,
):
    from expenseflow.group.service import create_group, get_user_group

    g1 = await create_group(session, user_model, group_create)  # Group 1

    g1_search = await get_user_group(session, default_user, g1.group_id)
    assert g1_search is None


@pytest.mark.asyncio()
async def test_update_group(
    session: AsyncSession,
    group_update: GroupUpdate,
    user_model: UserModel,
    group_create: GroupCreate,
):
    from expenseflow.group.service import create_group, update_group

    g = await create_group(session, user_model, group_create)  # Group 1

    g_updated = await update_group(session, g, group_update)

    assert g_updated.group_id == g.group_id
    assert g_updated.name == group_update.name
    assert g_updated.description == group_update.description
