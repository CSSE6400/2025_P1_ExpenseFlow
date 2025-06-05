"""Aduti routes tests."""

import pytest
from expenseflow.audit.schemas import AuditCreate, AuditRead
from expenseflow.user.models import UserModel
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession


@pytest.mark.asyncio
async def test_get_audits_empty(test_client: AsyncClient):
    """Test user with no audit history."""
    req = test_client.build_request(method="get", url="/audits")
    resp = await test_client.send(req)
    assert resp.status_code == 200
    assert resp.json() == []


@pytest.mark.asyncio
async def test_get_audits_with_data(
    test_client: AsyncClient, session: AsyncSession, default_user: UserModel
):
    """Test logs for a user with history."""
    from expenseflow.audit.service import create_audit

    audit_create_1 = AuditCreate(
        method="GET", endpoint="/api/users/profile", request_body={}
    )
    audit_create_2 = AuditCreate(
        method="POST",
        endpoint="/api/expenses",
        request_body={"amount": 50.00, "category": "transport"},
    )

    audit1 = await create_audit(session, default_user, audit_create_1)
    audit2 = await create_audit(session, default_user, audit_create_2)

    req = test_client.build_request(method="get", url="/audits")
    resp = await test_client.send(req)

    assert resp.status_code == 200
    response_data = resp.json()
    assert len(response_data) == 2

    audit_ids = [audit["audit_id"] for audit in response_data]
    assert str(audit1.audit_id) in audit_ids
    assert str(audit2.audit_id) in audit_ids

    for audit in response_data:
        assert audit["user_id"] == str(default_user.user_id)
        assert "method" in audit
        assert "endpoint" in audit
        assert "request_body" in audit


@pytest.mark.asyncio
async def test_get_audits_user_isolation(
    test_client: AsyncClient,
    session: AsyncSession,
    default_user: UserModel,
    user_model: UserModel,
):
    """Test that logs are isolated between users."""
    from expenseflow.audit.service import create_audit

    audit_create_default = AuditCreate(
        method="GET",
        endpoint="/api/users/profile",
        request_body={"user_id": "default"},
    )
    audit_create_other = AuditCreate(
        method="POST", endpoint="/api/expenses", request_body={"user_id": "other"}
    )

    await create_audit(session, default_user, audit_create_default)
    await create_audit(session, user_model, audit_create_other)

    req = test_client.build_request(method="get", url="/audits")
    resp = await test_client.send(req)

    assert resp.status_code == 200
    response_data = resp.json()
    assert len(response_data) == 1

    audit = response_data[0]
    assert audit["user_id"] == str(default_user.user_id)
    assert audit["request_body"] == {"user_id": "default"}


@pytest.mark.asyncio
async def test_get_audits_multiple_for_same_user(
    test_client: AsyncClient, session: AsyncSession, default_user: UserModel
):
    """Test getting multiple audit logs for the same user."""
    from expenseflow.audit.service import create_audit

    audit_creates = [
        AuditCreate(method="GET", endpoint="/api/dashboard", request_body=None),
        AuditCreate(
            method="POST",
            endpoint="/api/expenses",
            request_body={"amount": 100.00, "category": "food"},
        ),
        AuditCreate(
            method="PUT",
            endpoint="/api/expenses/123",
            request_body={"amount": 150.00, "category": "transport"},
        ),
        AuditCreate(
            method="DELETE",
            endpoint="/api/expenses/456",
            request_body={"reason": "duplicate"},
        ),
    ]

    created_audits = []
    for audit_create in audit_creates:
        audit = await create_audit(session, default_user, audit_create)
        created_audits.append(audit)

    req = test_client.build_request(method="get", url="/audits")
    resp = await test_client.send(req)

    assert resp.status_code == 200
    response_data = resp.json()
    assert len(response_data) == 4

    returned_audit_ids = {audit["audit_id"] for audit in response_data}
    expected_audit_ids = {str(audit.audit_id) for audit in created_audits}
    assert returned_audit_ids == expected_audit_ids

    returned_methods = {audit["method"] for audit in response_data}
    expected_methods = {"GET", "POST", "PUT", "DELETE"}
    assert returned_methods == expected_methods


@pytest.mark.asyncio
async def test_get_audits_response_schema(
    test_client: AsyncClient, session: AsyncSession, default_user: UserModel
):
    from expenseflow.audit.service import create_audit

    audit_create = AuditCreate(
        method="GET", endpoint="/api/test", request_body={"test": "data"}
    )

    created_audit = await create_audit(session, default_user, audit_create)

    req = test_client.build_request(method="get", url="/audits")
    resp = await test_client.send(req)

    assert resp.status_code == 200
    response_data = resp.json()
    assert len(response_data) == 1

    audit_response = response_data[0]

    expected_audit = AuditRead.model_validate(created_audit).model_dump(mode="json")
    assert expected_audit == audit_response

    required_fields = [
        "audit_id",
        "user_id",
        "method",
        "endpoint",
        "request_body",
    ]
    for field in required_fields:
        assert field in audit_response


@pytest.mark.asyncio
async def test_get_audits_with_none_request_body(
    test_client: AsyncClient, session: AsyncSession, default_user: UserModel
):
    """Test getting audit logs where request_body is None."""
    from expenseflow.audit.service import create_audit

    audit_create = AuditCreate(
        method="GET", endpoint="/api/dashboard", request_body=None
    )

    await create_audit(session, default_user, audit_create)

    req = test_client.build_request(method="get", url="/audits")
    resp = await test_client.send(req)

    assert resp.status_code == 200
    response_data = resp.json()
    assert len(response_data) == 1

    audit = response_data[0]
    assert audit["method"] == "GET"
    assert audit["endpoint"] == "/api/dashboard"
    assert audit["request_body"] is None
