"""Audit routes."""

from fastapi import APIRouter

from expenseflow.audit.models import AuditModel
from expenseflow.audit.schemas import AuditRead
from expenseflow.audit.service import get_audits
from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession

r = router = APIRouter()


@r.get("", response_model=list[AuditRead])
async def get(db: DbSession, user: CurrentUser) -> list[AuditModel]:
    """Get audit logs for a user."""
    return await get_audits(db, user)
