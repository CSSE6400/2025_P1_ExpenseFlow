"""Expense items db module."""

from uuid import UUID, uuid4

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from expenseflow.database.base import BaseDBModel
from expenseflow.database.mixins import TimestampMixin
from expenseflow.expense.models import ExpenseModel
from expenseflow.user.models import UserModel


class ExpenseItemModel(BaseDBModel, TimestampMixin):
    """Db model for items in an expense."""

    __tablename__ = "expense_item"

    expense_item_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    expense_id: Mapped[UUID] = mapped_column(ForeignKey("expense.expense_id"))
    name: Mapped[str]
    quantity: Mapped[int]
    price: Mapped[float]

    # relationships
    expense: Mapped[ExpenseModel] = relationship(back_populates="items", lazy="select")
    splits: Mapped[list["ExpenseItemSplitModel"]] = relationship(
        back_populates="item", lazy="select"
    )


class ExpenseItemSplitModel(BaseDBModel, TimestampMixin):
    """Db model for expense item split."""

    __tablename__ = "expense_item_split"

    expense_item_id: Mapped[UUID] = mapped_column(
        ForeignKey("expense_item.expense_item_id"),
        primary_key=True,
    )
    user_id: Mapped[UUID] = mapped_column(ForeignKey("user.user_id"), primary_key=True)
    proportion: Mapped[float]

    # Relationships
    item: Mapped[ExpenseItemModel] = relationship()
    user: Mapped[UserModel] = relationship()
