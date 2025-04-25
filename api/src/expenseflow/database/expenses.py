"""Expense db module."""

from uuid import UUID, uuid4

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from expenseflow.database.base import BaseDBModel, TimestampMixin
from expenseflow.database.entities import EntityModel, UserModel
from expenseflow.enums import ExpenseCategory


class ExpenseModel(BaseDBModel, TimestampMixin):
    """DB Model for expenses."""

    __tablename__ = "expense"

    expense_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    uploader_id: Mapped[UUID] = mapped_column(ForeignKey("user.user_id"))
    parent_id: Mapped[UUID] = mapped_column(ForeignKey("entity.entity_id"))

    name: Mapped[str]
    description: Mapped[str]
    category: Mapped[ExpenseCategory]
    # updated_at (automatic)
    # created_at (automatic)

    # Relationships
    uploader: Mapped[UserModel] = relationship(foreign_keys=[uploader_id])
    parent: Mapped[EntityModel] = relationship(foreign_keys=[parent_id])
    attachments: Mapped[list["ExpenseAttachmentModel"]] = relationship()
    items: Mapped[list["ExpenseItemModel"]] = relationship(back_populates="expense")


class ExpenseItemModel(BaseDBModel, TimestampMixin):
    """Db model for items in an expense."""

    __tablename__ = "expense_item"

    expense_item_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    expense_id: Mapped[UUID] = mapped_column(ForeignKey("expense.expense_id"))
    name: Mapped[str]
    quantity: Mapped[int]
    price: Mapped[float]
    # updated_at (automatic)
    # created_at (automatic)

    # relationships
    expense: Mapped[ExpenseModel] = relationship(back_populates="items")
    splits: Mapped[list["ExpenseItemSplitModel"]] = relationship(back_populates="item")


class ExpenseItemSplitModel(BaseDBModel, TimestampMixin):
    """Db model for expense item split."""

    __tablename__ = "expense_item_split"

    expense_item_id: Mapped[UUID] = mapped_column(
        ForeignKey("expense_item.expense_item_id"),
        primary_key=True,
    )
    user_id: Mapped[UUID] = mapped_column(ForeignKey("user.user_id"), primary_key=True)
    proportion: Mapped[float]
    # updated_at (automatic)
    # created_at (automatic)

    # Relationships
    item: Mapped[ExpenseItemModel] = relationship()
    user: Mapped[UserModel] = relationship()


class ExpenseAttachmentModel(BaseDBModel, TimestampMixin):
    """DB Model for expense attachments."""

    __tablename__ = "expense_attachment"

    attachment_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    expense_id: Mapped[UUID] = mapped_column(ForeignKey("expense.expense_id"))
    name: Mapped[str]
    # updated_at (automatic)
    # created_at (automatic)
