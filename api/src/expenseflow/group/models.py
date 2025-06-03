"""Group DB Models."""

import datetime as dt
from typing import ClassVar
from uuid import UUID, uuid4

from sqlalchemy import DateTime as SQLDatetime
from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from expenseflow.database.base import BaseDBModel
from expenseflow.entity.models import EntityModel
from expenseflow.enums import EntityKind, GroupRole
from expenseflow.user.models import UserModel


class GroupModel(EntityModel):
    """Group DB Model."""

    __tablename__ = "group"
    __mapper_args__: ClassVar[dict[str, str]] = {  # type: ignore[misc]
        "polymorphic_identity": EntityKind.group.value,
    }

    group_id: Mapped[UUID] = mapped_column(
        ForeignKey("entity.entity_id", ondelete="CASCADE"),
        primary_key=True,
        default=uuid4,
    )
    name: Mapped[str]
    description: Mapped[str]

    # Relationships
    users: Mapped[list["GroupUserModel"]] = relationship(
        back_populates="group", lazy="select", cascade="all, delete-orphan"
    )


class GroupUserModel(BaseDBModel):
    """DB Model for associating users to groups."""

    __tablename__ = "group_user"

    # Identities
    group_id: Mapped[UUID] = mapped_column(
        ForeignKey("group.group_id", ondelete="CASCADE"),
        primary_key=True,
    )
    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("user.user_id", ondelete="CASCADE"),
        primary_key=True,
    )

    # Fields
    role: Mapped[GroupRole]
    joined_at: Mapped[dt.datetime] = mapped_column(
        SQLDatetime(timezone=True),
        server_default=func.now(),
    )

    # Relationships
    user: Mapped[UserModel] = relationship(back_populates="groups", lazy="joined")
    group: Mapped[GroupModel] = relationship(back_populates="users", lazy="joined")
