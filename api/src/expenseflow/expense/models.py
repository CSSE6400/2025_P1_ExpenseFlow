"""Expense db module."""

import datetime as dt
from uuid import UUID, uuid4

from sqlalchemy import DateTime as SQLDatetime
from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from expenseflow.database.base import BaseDBModel
from expenseflow.database.mixins import TimestampMixin
from expenseflow.entity.models import EntityModel
from expenseflow.enums import ExpenseCategory, ExpenseStatus
from expenseflow.user.models import UserModel


class ExpenseModel(BaseDBModel, TimestampMixin):
    """DB Model for expenses."""

    __tablename__ = "expense"

    expense_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    uploader_id: Mapped[UUID] = mapped_column(ForeignKey("user.user_id"))
    parent_id: Mapped[UUID] = mapped_column(ForeignKey("entity.entity_id"))

    name: Mapped[str]
    description: Mapped[str]
    category: Mapped[ExpenseCategory]
    expense_date: Mapped[dt.datetime] = mapped_column(SQLDatetime(timezone=True))

    # Relationships
    uploader: Mapped[UserModel] = relationship(
        foreign_keys=[uploader_id], lazy="joined"
    )
    parent: Mapped[EntityModel] = relationship(foreign_keys=[parent_id], lazy="joined")
    items: Mapped[list["ExpenseItemModel"]] = relationship(
        lazy="subquery", cascade="all, delete-orphan"
    )


class ExpenseItemModel(BaseDBModel, TimestampMixin):
    """Db model for items in an expense."""

    __tablename__ = "expense_item"

    expense_item_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    expense_id: Mapped[UUID] = mapped_column(
        ForeignKey("expense.expense_id", ondelete="CASCADE")
    )
    name: Mapped[str]
    quantity: Mapped[int]
    price: Mapped[float]

    # relationships
    splits: Mapped[list["ExpenseItemSplitModel"]] = relationship(
        back_populates="item", lazy="joined", cascade="all, delete-orphan"
    )


class ExpenseItemSplitModel(BaseDBModel, TimestampMixin):
    """Db model for expense item split."""

    __tablename__ = "expense_item_split"

    expense_item_id: Mapped[UUID] = mapped_column(
        ForeignKey("expense_item.expense_item_id", ondelete="CASCADE"),
        primary_key=True,
    )
    user_id: Mapped[UUID] = mapped_column(ForeignKey("user.user_id"), primary_key=True)
    proportion: Mapped[float]

    # Relationships
    item: Mapped[ExpenseItemModel] = relationship(back_populates="splits")
    user: Mapped[UserModel] = relationship(lazy="joined")
    status: Mapped[ExpenseStatus]

    @property
    def user_fullname(self) -> str:
        """Name of person splitting."""
        return self.user.first_name + " " + self.user.last_name
