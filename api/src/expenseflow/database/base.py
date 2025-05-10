"""Base DB Model."""

import datetime as dt
import re
from decimal import Decimal
from typing import Any
from uuid import UUID

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

        def _serialize(value):  # noqa: ANN001, ANN202
            if isinstance(value, UUID | dt.datetime | Decimal):
                return str(value)
            return value

        return {
            c.name: _serialize(getattr(self, c.name)) for c in self.__table__.columns
        }
