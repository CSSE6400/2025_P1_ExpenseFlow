"""Test Group Routes."""

import pytest  # noqa: F401
from uuid import uuid4, UUID
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.group.schemas import GroupCreate, GroupUpdate, GroupRole
from expenseflow.group.models import GroupModel, GroupUserModel
from expenseflow.group.service import create_update_group_user_role, create_group
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreateInternal
from expenseflow.user.service import create_user
from expenseflow.auth.deps import CurrentUser
from expenseflow.expense.models import ExpenseModel


# Fixtures for test data
@pytest.fixture
async def group_create() -> GroupCreate:
    return GroupCreate(name="Test Group", description="A test group")


@pytest.fixture
async def group_update() -> GroupUpdate:
    return GroupUpdate(name="Updated Group", description="An updated group")


@pytest.fixture
async def group(session: AsyncSession, default_user: UserModel) -> GroupModel:
    from expenseflow.group.service import create_group
    group = await create_group(session, default_user, GroupCreate(name="Fixture Group", description="Fixture description"))
    return group


@pytest.fixture
async def another_user(session: AsyncSession) -> UserModel:
    from expenseflow.user.service import create_user
    from expenseflow.user.schemas import UserCreateInternal
    user_in = UserCreateInternal(
        nickname="another",
        first_name="Another",
        last_name="User",
        token_id="another_token"
    )
    user = await create_user(session, user_in)
    return user


@pytest.fixture
async def group_with_users(session: AsyncSession, default_user: UserModel, another_user: UserModel) -> GroupModel:
    from expenseflow.group.service import create_group, create_update_group_user_role
    group = await create_group(session, default_user, GroupCreate(name="Multi-User Group", description="For testing user roles"))
    await create_update_group_user_role(session, default_user, group, another_user, GroupRole.user)
    return group


# Test cases
@pytest.mark.asyncio
async def test_get_groups(test_client: AsyncClient, default_user: UserModel, group: GroupModel):
    req = test_client.build_request("GET", "/groups")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert len(resp.json()) == 1
    assert resp.json()[0]["group_id"] == str(group.group_id)


@pytest.mark.asyncio
async def test_get_group(test_client: AsyncClient, group: GroupModel):
    req = test_client.build_request("GET", f"/groups/{group.group_id}")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert resp.json()["name"] == "Fixture Group"


@pytest.mark.asyncio
async def test_get_group_not_found(test_client: AsyncClient):
    req = test_client.build_request("GET", f"/groups/{uuid4()}")
    resp = await test_client.send(req)
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_create_group(test_client: AsyncClient, session: AsyncSession, default_user: UserModel, group_create: GroupCreate):
    req = test_client.build_request("POST", "/groups", json=group_create.model_dump(mode="json"))
    resp = await test_client.send(req)
    assert resp.status_code == 200
    group_id = UUID(resp.json()["group_id"])
    group = await session.get(GroupModel, group_id)
    assert group is not None
    assert group.name == "Test Group"


@pytest.mark.asyncio
async def test_update_group(test_client: AsyncClient, group: GroupModel, group_update: GroupUpdate):
    req = test_client.build_request("PUT", f"/groups/{group.group_id}", json=group_update.model_dump(mode="json"))
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert resp.json()["name"] == "Updated Group"


@pytest.mark.asyncio
async def test_update_group_not_found(test_client: AsyncClient, group_update: GroupUpdate):
    req = test_client.build_request("PUT", f"/groups/{uuid4()}", json=group_update.model_dump(mode="json"))
    resp = await test_client.send(req)
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_get_group_users(test_client: AsyncClient, group_with_users: GroupModel):
    req = test_client.build_request("GET", f"/groups/{group_with_users.group_id}/users")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert len(resp.json()) == 2  # default_user + another_user


@pytest.mark.asyncio
async def test_update_user_role(test_client: AsyncClient, session: AsyncSession, group_with_users: GroupModel, another_user: UserModel):
    req = test_client.build_request("PUT", f"/groups/{group_with_users.group_id}/users/{another_user.user_id}?role=admin")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert resp.json()["role"] == "admin"

    group_user = await session.get(GroupUserModel, {"group_id": group_with_users.group_id, "user_id": another_user.user_id})
    assert group_user.role == GroupRole.ADMIN


@pytest.mark.asyncio
async def test_update_user_role_invalid_group(test_client: AsyncClient, another_user: UserModel):
    req = test_client.build_request("PUT", f"/groups/{uuid4()}/users/{another_user.user_id}?role=member")
    resp = await test_client.send(req)
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_delete_user_from_group(test_client: AsyncClient, session: AsyncSession, group_with_users: GroupModel, another_user: UserModel):
    req = test_client.build_request("DELETE", f"/groups/{group_with_users.group_id}/users/{another_user.user_id}")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert resp.json()["user_id"] == str(another_user.user_id)

    from sqlalchemy import select
    result = await session.execute(
        select(GroupUserModel).where(
            GroupUserModel.group_id == group_with_users.group_id,
            GroupUserModel.user_id == another_user.user_id
        )
    )
    assert result.scalars().first() is None


@pytest.mark.asyncio
async def test_delete_user_not_found(test_client: AsyncClient, group: GroupModel):
    req = test_client.build_request("DELETE", f"/groups/{group.group_id}/users/{uuid4()}")
    resp = await test_client.send(req)
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_get_group_expenses(test_client: AsyncClient, session: AsyncSession, group: GroupModel):
    from expenseflow.expense.service import create_expense
    user_in = UserCreateInternal(
        nickname="test",
        first_name="Test",
        last_name="User",
        token_id="test_token"
    )
    user = await create_user(session, user_in)
    expense = await create_expense(session, group, user, 100.0, "Test expense")

    req = test_client.build_request("GET", f"/groups/{group.group_id}/expenses")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert len(resp.json()) == 1
    assert resp.json()[0]["description"] == "Test expense"