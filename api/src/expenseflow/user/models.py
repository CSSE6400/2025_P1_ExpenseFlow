"""User db models."""

from typing import TYPE_CHECKING, ClassVar
from uuid import UUID, uuid4

from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from expenseflow.entity.models import EntityModel
from expenseflow.enums import EntityKind
from expenseflow.user.schemas import UserSchema

if TYPE_CHECKING:
    from expenseflow.group.models import GroupUserModel


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
    email: Mapped[str] = mapped_column(unique=True, index=True)
    first_name: Mapped[str]
    last_name: Mapped[str]

    # Relationships
    groups: Mapped[list["GroupUserModel"]] = relationship(back_populates="user")

    def to_schema(self) -> UserSchema:
        """Convert model to schema."""
        return UserSchema(
            user_id=self.user_id,
            email=self.email,
            first_name=self.first_name,
            last_name=self.last_name,
        )
