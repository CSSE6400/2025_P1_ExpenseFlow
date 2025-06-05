"""Audit service tests."""

import pytest
from expenseflow.audit.schemas import AuditCreate
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreateInternal
from sqlalchemy.ext.asyncio import AsyncSession


# creating these fixtures because polyfactory creates non-jsonable data
@pytest.fixture
def audit_create():
    """Fixture for creating an audit log."""
    return AuditCreate(
        method="GET",
        endpoint="/api/users",
        request_body={"filter": "active"},
    )


@pytest.fixture
def audit_create_2():
    """Fixture for creating a second audit log."""
    return AuditCreate(
        method="POST",
        endpoint="/api/dashboard",
        request_body={"name": "John Doe", "email": "me"},
    )


@pytest.mark.asyncio()
async def test_create_audit(
    session: AsyncSession,
    user_create_internal: UserCreateInternal,
    audit_create: AuditCreate,
):
    """Test creating an audit log ."""
    from expenseflow.audit.service import create_audit
    from expenseflow.user.service import create_user

    user = await create_user(session, user_create_internal)

    audit = await create_audit(session, user, audit_create)

    assert audit.method == audit_create.method
    assert audit.endpoint == audit_create.endpoint
    assert audit.request_body == audit_create.request_body
    assert audit.user_id == user.user_id
    assert audit.audit_id is not None
    assert audit.created_at is not None
    assert audit.updated_at is not None


@pytest.mark.asyncio()
async def test_get_audits_for_user(
    session: AsyncSession,
    user_create_internal: UserCreateInternal,
    audit_create: AuditCreate,
    audit_create_2: AuditCreate,
):
    """Test retrieving audit logs for user."""
    from expenseflow.audit.service import create_audit, get_audits
    from expenseflow.user.service import create_user

    user = await create_user(session, user_create_internal)

    audit1 = await create_audit(session, user, audit_create)

    audit2 = await create_audit(session, user, audit_create_2)

    audits = await get_audits(session, user)

    assert len(audits) == 2
    audit_ids = [audit.audit_id for audit in audits]
    assert audit1.audit_id in audit_ids
    assert audit2.audit_id in audit_ids

    for audit in audits:
        assert audit.user_id == user.user_id


@pytest.mark.asyncio()
async def test_get_audits_empty_for_user(
    session: AsyncSession, user_create_internal: UserCreateInternal
):
    """Test retrieving audit logs with no history."""
    from expenseflow.audit.service import get_audits
    from expenseflow.user.service import create_user

    user = await create_user(session, user_create_internal)

    audits = await get_audits(session, user)

    assert audits == []


@pytest.mark.asyncio()
async def test_get_audits_user_isolation(
    session: AsyncSession,
    default_user: UserModel,
    user_model: UserModel,
    audit_create: AuditCreate,
    audit_create_2: AuditCreate,
):
    """Test that audit logs are properly isolated between users."""
    from expenseflow.audit.service import create_audit, get_audits

    audit1 = await create_audit(session, default_user, audit_create)

    audit2 = await create_audit(session, user_model, audit_create_2)

    user1_audits = await get_audits(session, default_user)
    assert len(user1_audits) == 1
    assert user1_audits[0].audit_id == audit1.audit_id
    assert user1_audits[0].user_id == default_user.user_id

    user2_audits = await get_audits(session, user_model)
    assert len(user2_audits) == 1
    assert user2_audits[0].audit_id == audit2.audit_id
    assert user2_audits[0].user_id == user_model.user_id


@pytest.mark.asyncio()
async def test_create_audit_with_none_request_body(
    session: AsyncSession, user_model: UserModel, audit_create: AuditCreate
):
    """Test creating an audit log with None request body."""
    from expenseflow.audit.service import create_audit

    audit = await create_audit(session, user_model, audit_create)

    assert audit.method == "GET"
    assert audit.endpoint == "/api/users"
    assert audit.user_id == user_model.user_id


@pytest.mark.asyncio()
async def test_create_multiple_audits_same_user(
    session: AsyncSession, user_model: UserModel
):
    """Test creating multiple audit logs for the same user and endpoint."""
    from expenseflow.audit.service import create_audit, get_audits

    # Create multiple audits with same endpoint but different methods
    audit_create_get = AuditCreate(
        method="GET", endpoint="/api/expenses", request_body=None
    )
    audit_create_post = AuditCreate(
        method="POST", endpoint="/api/expenses", request_body={"amount": 100}
    )

    _ = await create_audit(session, user_model, audit_create_get)
    _ = await create_audit(session, user_model, audit_create_post)

    audits = await get_audits(session, user_model)

    assert len(audits) == 2
    methods = [audit.method for audit in audits]
    assert "GET" in methods
    assert "POST" in methods
