"""Base database module."""

import datetime as dt

from sqlalchemy import DateTime as SQLDatetime
from sqlalchemy.ext.asyncio import AsyncAttrs
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy.sql import func


class BaseDBModel(DeclarativeBase, AsyncAttrs):
    """Base model for db tables."""

    created_at: Mapped[dt.datetime] = mapped_column(
        SQLDatetime(timezone=True),
        server_default=func.now(),
        server_onupdate=func.now(),
        onupdate=lambda: dt.datetime.now(dt.UTC),
    )
    modified_at: Mapped[dt.datetime] = mapped_column(
        SQLDatetime(timezone=True),
        server_default=func.now(),
    )
