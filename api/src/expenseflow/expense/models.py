"""Expense db module."""

from typing import TYPE_CHECKING
from uuid import UUID, uuid4

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from expenseflow.database.base import BaseDBModel
from expenseflow.database.mixins import TimestampMixin
from expenseflow.entity.models import EntityModel
from expenseflow.enums import ExpenseCategory
from expenseflow.user.models import UserModel

if TYPE_CHECKING:
    from expenseflow.expense_attachment.models import ExpenseAttachmentModel
    from expenseflow.expense_item.models import ExpenseItemModel


class ExpenseModel(BaseDBModel, TimestampMixin):
    """DB Model for expenses."""

    __tablename__ = "expense"

    expense_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    uploader_id: Mapped[UUID] = mapped_column(ForeignKey("user.user_id"))
    parent_id: Mapped[UUID] = mapped_column(ForeignKey("entity.entity_id"))

    name: Mapped[str]
    description: Mapped[str]
    category: Mapped[ExpenseCategory]

    # Relationships
    uploader: Mapped[UserModel] = relationship(
        foreign_keys=[uploader_id], lazy="joined"
    )
    parent: Mapped[EntityModel] = relationship(foreign_keys=[parent_id], lazy="joined")
    items: Mapped[list["ExpenseItemModel"]] = relationship(
        back_populates="expense", lazy="subquery"
    )
    attachments: Mapped[list["ExpenseAttachmentModel"]] = relationship(lazy="select")
