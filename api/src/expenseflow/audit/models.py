"""Audit models."""

from uuid import UUID, uuid4

from sqlalchemy import JSON, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from expenseflow.database.base import BaseDBModel
from expenseflow.database.mixins import TimestampMixin
from expenseflow.user.models import UserModel


class AuditModel(BaseDBModel, TimestampMixin):
    """Audit DB Model."""

    __tablename__ = "audit"

    audit_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("user.user_id", ondelete="CASCADE")
    )

    method: Mapped[str]
    endpoint: Mapped[str]
    request_body: Mapped[dict | None] = mapped_column(JSON, nullable=True)

    user: Mapped[UserModel] = relationship(lazy="joined")
