"""Entity models."""

from typing import ClassVar
from uuid import UUID, uuid4

from sqlalchemy.orm import Mapped, mapped_column

from expenseflow.database.base import BaseDBModel
from expenseflow.database.mixins import TimestampMixin
from expenseflow.enums import EntityKind


class EntityModel(BaseDBModel, TimestampMixin):
    """Entity DB Model."""

    __tablename__ = "entity"
    __mapper_args__: ClassVar[dict[str, str]] = {  # type: ignore[misc]
        "polymorphic_on": "kind",  # This is the field that is making the subclasses different
        "polymorphic_identity": "entity",  # Field that identifies each 'entity' if you will
    }

    entity_id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    kind: Mapped[EntityKind]  # either user or group

    def __repr__(self) -> str:
        """Representation of an entity - not useful."""
        return f"Entity: {self.entity_id} - {self.kind.value}"
