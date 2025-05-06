"""User routes test module."""

import json

import pytest
from expenseflow.user.schemas import UserCreateSchema, UserSchema
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession


@pytest.mark.asyncio
async def test_get_me(test_client: AsyncClient, default_user: UserSchema):
    req = test_client.build_request(method="get", url="/users")

    resp = await test_client.send(req)

    assert resp.status_code == 200

    assert default_user.model_dump_json() == resp.text


@pytest.mark.asyncio
async def test_get_user(
    test_client: AsyncClient, session: AsyncSession, user_create: UserCreateSchema
):
    from expenseflow.user.service import create_user

    new_user = await create_user(session, user_create)

    req = test_client.build_request(method="get", url=f"/users/{new_user.user_id}")

    resp = await test_client.send(req)

    assert resp.status_code == 200

    assert new_user.model_dump_json() == resp.text


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
    session: AsyncSession, test_client: AsyncClient, user_create: UserCreateSchema
):

    from expenseflow.user.service import get_user_by_id

    req_body = json.loads(user_create.model_dump_json())

    req = test_client.build_request(method="post", url="/users", json=req_body)

    resp = await test_client.send(req)

    assert resp.status_code == 200

    user = await get_user_by_id(session, resp.json()["user_id"])
    assert user is not None

    assert resp.text == user.model_dump_json()


@pytest.mark.asyncio
async def test_create_user_invalid_body(
    test_client: AsyncClient, user_create: UserCreateSchema
):

    req_body = json.loads(user_create.model_dump_json())

    _ = req_body.pop("email")

    req = test_client.build_request(method="post", url="/users", json=req_body)

    resp = await test_client.send(req)

    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_create_user_exists(
    session: AsyncSession, test_client: AsyncClient, user_create: UserCreateSchema
):

    from expenseflow.user.service import create_user

    _ = await create_user(session, user_create)

    req_body = json.loads(user_create.model_dump_json())

    req = test_client.build_request(method="post", url="/users", json=req_body)

    resp = await test_client.send(req)

    # User already exists
    assert resp.status_code == 409
