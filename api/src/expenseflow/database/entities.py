"""Entity models."""

import datetime as dt
from typing import ClassVar
from uuid import UUID, uuid4

from sqlalchemy import DateTime as SQLDatetime
from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func

from expenseflow.database.base import BaseDBModel, TimestampMixin
from expenseflow.enums import EntityKind, GroupRole


class EntityModel(BaseDBModel, TimestampMixin):
    """Entity DB Model."""

    __tablename__ = "entity"
    __mapper_args__: ClassVar[dict[str, str]] = {  # type: ignore[misc]
        "polymorphic_on": "kind",  # This is the field that is making the subclasses different
        "polymorphic_identity": "entity",  # Field that identifies each 'entity' if you will
    }

    entity_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    kind: Mapped[EntityKind]

    def __repr__(self) -> str:
        """Representation of an entity - not useful."""
        return f"Entity: {self.entity_id} - {self.kind.value}"


class UserModel(EntityModel):
    """User DB Model."""

    __tablename__ = "user"
    __mapper_args__: ClassVar[dict[str, str]] = {  # type: ignore[misc]
        "polymorphic_identity": EntityKind.user.value,
    }

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("entity.entity_id"),
        primary_key=True,
        default=uuid4,
    )
    username: Mapped[str] = mapped_column(unique=True)
    first_name: Mapped[str]
    last_name: Mapped[str]

    # Relationships
    groups: Mapped[list["GroupUserModel"]] = relationship(back_populates="user")


class GroupModel(EntityModel):
    """Group DB Model."""

    __tablename__ = "group"
    __mapper_args__: ClassVar[dict[str, str]] = {  # type: ignore[misc]
        "polymorphic_identity": EntityKind.group.value,
    }

    group_id: Mapped[UUID] = mapped_column(
        ForeignKey("entity.entity_id"),
        primary_key=True,
        default=uuid4,
    )
    name: Mapped[str]
    description: Mapped[str]

    # Relationships
    users: Mapped[list["GroupUserModel"]] = relationship(back_populates="group")


class GroupUserModel(BaseDBModel):
    """DB Model for associating users to groups."""

    __tablename__ = "group_user"

    # Identities
    group_id: Mapped[UUID] = mapped_column(
        ForeignKey("group.group_id"),
        primary_key=True,
    )
    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("user.user_id"),
        primary_key=True,
    )

    # Fields
    role: Mapped[GroupRole]
    joined_at: Mapped[dt.datetime] = mapped_column(
        SQLDatetime(timezone=True),
        server_default=func.now(),
    )

    # Relationships
    user: Mapped[UserModel] = relationship(back_populates="groups")
    group: Mapped[GroupModel] = relationship(back_populates="users")
