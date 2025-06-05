"""Audit schemas."""

from uuid import UUID

from expenseflow.schemas import ExpenseFlowBase


class AuditCreate(ExpenseFlowBase):
    """Audit create schema."""

    method: str
    endpoint: str
    request_body: dict | None = None


class AuditRead(ExpenseFlowBase):
    """Audit read schema."""

    audit_id: UUID
    user_id: UUID

    method: str
    endpoint: str
    request_body: dict | None = None
