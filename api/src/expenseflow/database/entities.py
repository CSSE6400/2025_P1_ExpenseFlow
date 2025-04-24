"""Entity models."""

from typing import ClassVar
from uuid import UUID, uuid4

from sqlalchemy.orm import Mapped, mapped_column

from expenseflow.database.base import BaseDBModel
from expenseflow.enums import EntityKind


class Entity(BaseDBModel):
    """Entity DB Model."""

    __tablename__ = "entity"

    entity_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    kind: Mapped[EntityKind]

    __mapper_args__: ClassVar[dict[str, str]] = {  # type: ignore[misc]
        "polymorphic_on": "kind",
        "polymorphic_identity": "entity",
    }

    def __repr__(self) -> str:
        """Representation of an entity - not useful."""
        return f"Entity: {self.entity_id} - {self.kind.value}"


class User(Entity):
    """User DB Model."""

    __tablename__ = "user"
    user_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    username: Mapped[str] = mapped_column(unique=True)
    first_name: Mapped[str]
    last_name: Mapped[str]

    __mapper_args__: ClassVar[dict[str, str]] = {  # type: ignore[misc]
        "polymorphic_identity": EntityKind.user.value,
    }


class Group(Entity):
    """Group DB Model."""

    __tablename__ = "group"
    group_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    name: Mapped[str]
    description: Mapped[str]

    __mapper_args__: ClassVar[dict[str, str]] = {  # type: ignore[misc]
        "polymorphic_identity": EntityKind.group.value,
    }
