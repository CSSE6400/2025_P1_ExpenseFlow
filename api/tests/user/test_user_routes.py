"""User routes test module."""

import pytest
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreate, UserCreateInternal, UserRead
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession


@pytest.mark.asyncio
async def test_get_me(test_client: AsyncClient, default_user: UserModel):
    req = test_client.build_request(method="get", url="/users")

    resp = await test_client.send(req)

    assert resp.status_code == 200

    expected_user = UserRead.model_validate(default_user).model_dump(mode="json")

    assert expected_user == resp.json()


@pytest.mark.asyncio
async def test_get_user(
    test_client: AsyncClient,
    session: AsyncSession,
    user_create_internal: UserCreateInternal,
):
    from expenseflow.user.service import create_user

    new_user = await create_user(session, user_create_internal)

    req = test_client.build_request(method="get", url=f"/users/{new_user.user_id}")

    resp = await test_client.send(req)

    assert resp.status_code == 200

    expected_user = UserRead.model_validate(new_user).model_dump(mode="json")

    assert expected_user == resp.json()


@pytest.mark.asyncio
async def test_get_user_invalid_uuid(test_client: AsyncClient):
    req = test_client.build_request(method="get", url="/users/abc")

    resp = await test_client.send(req)

    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_get_user_not_found(test_client: AsyncClient):
    from uuid import uuid4

    req = test_client.build_request(method="get", url=f"/users/{uuid4()}")

    resp = await test_client.send(req)

    assert resp.status_code == 404


@pytest.mark.asyncio
async def test_create_user(
    session: AsyncSession, test_client: AsyncClient, user_create: UserCreate
):

    from expenseflow.user.service import get_user_by_id

    req = test_client.build_request(
        method="post", url="/users", json=user_create.model_dump(mode="json")
    )

    resp = await test_client.send(req)

    assert resp.status_code == 200

    user = await get_user_by_id(session, resp.json()["user_id"])
    assert user is not None

    expected_user = UserRead.model_validate(user).model_dump(mode="json")

    assert expected_user == resp.json()


@pytest.mark.asyncio
async def test_create_user_invalid_body(
    test_client: AsyncClient, user_create: UserCreate
):

    req_body = user_create.model_dump(mode="json")

    _ = req_body.pop("nickname")

    req = test_client.build_request(method="post", url="/users", json=req_body)

    resp = await test_client.send(req)

    assert resp.status_code == 422
