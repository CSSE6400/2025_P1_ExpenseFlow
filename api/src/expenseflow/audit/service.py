"""Audit service."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.audit.models import AuditModel
from expenseflow.audit.schemas import AuditCreate
from expenseflow.user.models import UserModel


async def create_audit(
    session: AsyncSession, audited_user: UserModel, audit_in: AuditCreate
) -> AuditModel:
    """Create group and create owner."""
    audit_model = AuditModel(
        method=audit_in.method,
        endpoint=audit_in.endpoint,
        request_body=audit_in.request_body,
        user=audited_user,
    )

    session.add(audit_model)
    await session.commit()
    return audit_model


async def get_audits(
    session: AsyncSession,
    user: UserModel,
) -> list[AuditModel]:
    """Get audit logs for a user."""
    result = await session.execute(
        select(AuditModel).where(AuditModel.user_id == user.user_id)
    )

    return list(result.scalars().unique().all())
