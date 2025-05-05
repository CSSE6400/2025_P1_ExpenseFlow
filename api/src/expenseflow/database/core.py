"""Base database module."""

from collections.abc import AsyncGenerator

from loguru import logger
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from expenseflow.config import CONFIG

db_engine: AsyncEngine = create_async_engine(
    CONFIG.db_url,
    pool_pre_ping=True,
)
session_factory = async_sessionmaker(
    db_engine,
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
