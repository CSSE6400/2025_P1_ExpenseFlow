"""Entity services."""

from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.entity.models import EntityModel


async def get_entity(session: AsyncSession, entity_id: UUID) -> EntityModel | None:
    """Get entity."""
    return await session.get(EntityModel, entity_id)
