"""Base database module."""

import re
from collections.abc import AsyncGenerator
from typing import Any

from loguru import logger
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import (
    AsyncAttrs,
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.orm import DeclarativeBase

from expenseflow.config import CONFIG


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


engine: AsyncEngine = create_async_engine(
    CONFIG.db_url,
    pool_pre_ping=True,
)
session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Get generator to get database session.

    :return: generator for async db session.
    :rtype: AsyncGenerator[AsyncSession, None]
    :yield: db session generator.
    :rtype: Iterator[AsyncGenerator[AsyncSession, None]]
    """
    async with session_factory() as session:
        try:
            yield session
            await session.commit()
        except SQLAlchemyError as e:
            logger.error(e)
            await session.rollback()
            await session.close()
            raise


async def initialise_database() -> None:
    """Initialise database."""
    # Importing as now sqlalchemy will know about them when creating the schema
    from expenseflow.entity.models import EntityModel, GroupUserModel  # noqa: F401
    from expenseflow.expense.models import (  # noqa: F401
        ExpenseAttachmentModel,
        ExpenseItemModel,
        ExpenseItemSplitModel,
        ExpenseModel,
    )

    async with engine.begin() as conn:
        await conn.run_sync(BaseDBModel.metadata.create_all)

        logger.success("Initialising database was successful.")
