"""Base DB Model."""

import re
from typing import Any

from sqlalchemy.ext.asyncio import (
    AsyncAttrs,
)
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.orm import DeclarativeBase


# Base database model/table
class BaseDBModel(DeclarativeBase, AsyncAttrs):
    """Base model for db tables."""

    @declared_attr
    def __tablename__(self):  # noqa: ANN204
        """Automatically get table name."""
        names = re.split("(?=[A-Z])", self.__name__)
        return "_".join([x.lower() for x in names if x])

    def to_dict(self) -> dict[Any, Any]:
        """Return dict representation of a model."""
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}
