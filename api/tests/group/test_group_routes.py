"""Test Group Routes."""

from uuid import UUID, uuid4

import pytest
import pytest_asyncio
from expenseflow.group.models import GroupModel
from expenseflow.group.schemas import GroupCreate, GroupRole, GroupUpdate
from expenseflow.group.service import get_group, get_group_user
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreateInternal
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession


@pytest_asyncio.fixture(scope="function")
async def another_user(
    session: AsyncSession, user_create_internal: UserCreateInternal
) -> UserModel:
    from expenseflow.user.service import create_user

    return await create_user(session, user_create_internal)


@pytest_asyncio.fixture(scope="function")
async def existing_group(
    session: AsyncSession, default_user: UserModel, group_create: GroupCreate
) -> GroupModel:
    from expenseflow.group.service import create_group

    return await create_group(session, default_user, group_create)


@pytest_asyncio.fixture(scope="function")
async def existing_group_with_users(
    session: AsyncSession,
    default_user: UserModel,
    another_user: UserModel,
    existing_group: GroupModel,
) -> GroupModel:
    from expenseflow.group.service import create_update_group_user_role

    # putting 'another_user' in the group
    await create_update_group_user_role(
        session, default_user, existing_group, another_user, GroupRole.user
    )
    return existing_group


@pytest.mark.asyncio
async def test_get_groups(
    test_client: AsyncClient,
    existing_group: GroupModel,
):
    req = test_client.build_request("GET", "/groups")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert len(resp.json()) == 1
    assert resp.json()[0]["group_id"] == str(existing_group.group_id)


@pytest.mark.asyncio
async def test_get_group(
    test_client: AsyncClient,
    existing_group: GroupModel,
):
    req = test_client.build_request("GET", f"/groups/{existing_group.group_id}")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert resp.json()["name"] == existing_group.name
    assert resp.json()["description"] == existing_group.description


@pytest.mark.asyncio
async def test_get_group_not_found(test_client: AsyncClient):
    req = test_client.build_request("GET", f"/groups/{uuid4()}")
    resp = await test_client.send(req)
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_create_group(
    test_client: AsyncClient,
    session: AsyncSession,
    default_user: UserModel,
    group_create: GroupCreate,
    another_user: UserModel,
):
    req = test_client.build_request(
        "POST", "/groups", json=group_create.model_dump(mode="json")
    )
    resp = await test_client.send(req)
    assert resp.status_code == 200
    group_id = UUID(resp.json()["group_id"])

    found_group = await get_group(session, default_user, group_id)
    assert found_group is not None
    assert found_group.name == group_create.name

    found_group_again = await get_group(session, another_user, group_id)
    assert found_group_again is None


@pytest.mark.asyncio
async def test_create_group_no_name(
    test_client: AsyncClient,
    group_create: GroupCreate,
):
    request_body = group_create.model_dump(mode="json")
    request_body.pop("name")

    req = test_client.build_request("POST", "/groups", json=request_body)
    resp = await test_client.send(req)
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_create_group_no_description(
    test_client: AsyncClient,
    group_create: GroupCreate,
):
    request_body = group_create.model_dump(mode="json")
    request_body.pop("description")

    req = test_client.build_request("POST", "/groups", json=request_body)
    resp = await test_client.send(req)
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_update_group(  # noqa: PLR0913
    test_client: AsyncClient,
    group_model: GroupModel,
    group_update: GroupUpdate,
    session: AsyncSession,
    default_user: UserModel,
    group_create: GroupCreate,
):
    from expenseflow.group.service import create_group

    group = await create_group(session, default_user, group_create)

    req = test_client.build_request(
        "PUT", f"/groups/{group.group_id}", json=group_update.model_dump(mode="json")
    )
    resp = await test_client.send(req)
    assert resp.status_code == 200

    assert resp.json()["name"] == group_update.name
    assert resp.json()["description"] == group_update.description


@pytest.mark.asyncio
async def test_update_group_not_found(
    test_client: AsyncClient, group_update: GroupUpdate
):
    req = test_client.build_request(
        "PUT", f"/groups/{uuid4()}", json=group_update.model_dump(mode="json")
    )
    resp = await test_client.send(req)
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_get_group_users(
    test_client: AsyncClient, existing_group_with_users: GroupModel
):
    req = test_client.build_request(
        "GET", f"/groups/{existing_group_with_users.group_id}/users"
    )
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert len(resp.json()) == 2  # default_user + another_user


@pytest.mark.asyncio
async def test_get_group_users_only_one(
    test_client: AsyncClient, existing_group: GroupModel
):
    req = test_client.build_request("GET", f"/groups/{existing_group.group_id}/users")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert len(resp.json()) == 1  # default_user


@pytest.mark.asyncio
async def test_create_user_role(
    test_client: AsyncClient,
    session: AsyncSession,
    existing_group: GroupModel,
    another_user: UserModel,
):
    req = test_client.build_request(
        "PUT",
        f"/groups/{existing_group.group_id}/users/{another_user.user_id}?role=user",
    )
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert resp.json()["role"] == "user"

    group_user = await get_group_user(session, another_user, existing_group)
    assert group_user is not None
    assert group_user.role == GroupRole.user


@pytest.mark.asyncio
async def test_update_user_role(
    test_client: AsyncClient,
    session: AsyncSession,
    existing_group_with_users: GroupModel,
    another_user: UserModel,
):
    req = test_client.build_request(
        "PUT",
        f"/groups/{existing_group_with_users.group_id}/users/{another_user.user_id}?role=admin",
    )
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert resp.json()["role"] == "admin"

    group_user = await get_group_user(session, another_user, existing_group_with_users)
    assert group_user is not None
    assert group_user.role == GroupRole.admin


@pytest.mark.asyncio
async def test_update_user_role_invalid_group(
    test_client: AsyncClient, another_user: UserModel
):
    req = test_client.build_request(
        "PUT", f"/groups/{uuid4()}/users/{another_user.user_id}?role=user"
    )
    resp = await test_client.send(req)
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_update_user_role_invalid_role(
    test_client: AsyncClient, another_user: UserModel, existing_group: GroupModel
):
    req = test_client.build_request(
        "PUT",
        f"/groups/{existing_group.group_id}/users/{another_user.user_id}?role=another_role",
    )
    resp = await test_client.send(req)
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_delete_user_not_found(
    test_client: AsyncClient, existing_group: GroupModel
):
    req = test_client.build_request(
        "DELETE", f"/groups/{existing_group.group_id}/users/{uuid4()}"
    )
    resp = await test_client.send(req)
    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_get_group_expenses_nothing(
    test_client: AsyncClient,
    existing_group: GroupModel,
):
    req = test_client.build_request(
        "GET", f"/groups/{existing_group.group_id}/expenses"
    )
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert len(resp.json()) == 0
