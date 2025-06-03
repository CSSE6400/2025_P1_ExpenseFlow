"""Friends db models."""

from uuid import uuid4

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from expenseflow.database.base import BaseDBModel
from expenseflow.database.mixins import TimestampMixin
from expenseflow.enums import FriendStatus
from expenseflow.user.models import UserModel


class FriendModel(BaseDBModel, TimestampMixin):
    """DB Model for friends."""

    __tablename__ = "friend"

    sender_id: Mapped[UserModel] = mapped_column(
        ForeignKey("user.user_id", ondelete="CASCADE"), primary_key=True, default=uuid4
    )
    receiver_id: Mapped[UserModel] = mapped_column(
        ForeignKey("user.user_id", ondelete="CASCADE"), primary_key=True, default=uuid4
    )
    status: Mapped[FriendStatus] = mapped_column(default=FriendStatus.requested)

    # Relationships
    sender: Mapped[UserModel] = relationship(foreign_keys=[sender_id], lazy="joined")
    receiver: Mapped[UserModel] = relationship(
        foreign_keys=[receiver_id], lazy="joined"
    )
