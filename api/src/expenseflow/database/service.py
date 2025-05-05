"""Database services."""

from loguru import logger
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
)


async def initialise_database(engine: AsyncEngine) -> None:
    """Initialise database."""
    # Importing as now sqlalchemy will know about them when creating the schema
    from expenseflow.database.base import BaseDBModel
    from expenseflow.entity.models import (
        EntityModel,  # noqa: F401
        GroupUserModel,  # noqa: F401
    )
    from expenseflow.expense.models import (  # noqa: F401
        ExpenseAttachmentModel,
        ExpenseItemModel,
        ExpenseItemSplitModel,
        ExpenseModel,
    )

    async with engine.begin() as conn:
        await conn.run_sync(BaseDBModel.metadata.create_all)

    logger.success("Initialising database was successful.")
