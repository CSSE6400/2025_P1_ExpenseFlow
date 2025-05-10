"""Expense Attachment db module."""

from uuid import UUID, uuid4

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from expenseflow.database.base import BaseDBModel
from expenseflow.database.mixins import TimestampMixin


class ExpenseAttachmentModel(BaseDBModel, TimestampMixin):
    """DB Model for expense attachments."""

    __tablename__ = "expense_attachment"

    attachment_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    expense_id: Mapped[UUID] = mapped_column(ForeignKey("expense.expense_id"))
    name: Mapped[str]
