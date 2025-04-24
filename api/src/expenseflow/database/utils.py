"""Database utils."""

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
from expenseflow.database.base import BaseDBModel

engine: AsyncEngine = create_async_engine(
    CONFIG.db_url,
    pool_pre_ping=True,
)
session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def initialise_database() -> None:
    """Create tables if they don't exist already."""
    async with engine.begin() as conn:
        await conn.run_sync(BaseDBModel.metadata.create_all)

        logger.success("Initialising database was successful.")


async def get_session() -> AsyncGenerator[AsyncSession, None]:
    """Get Database session."""
    async with session_factory() as session:
        try:
            yield session
            logger.info("Commit to the session")
            await session.commit()
        except SQLAlchemyError as e:
            logger.error(e)
            await session.rollback()
            await session.close()
            raise
