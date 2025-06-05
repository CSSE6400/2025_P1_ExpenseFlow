"""Entity schemas."""

from uuid import UUID

from expenseflow.enums import EntityKind
from expenseflow.schemas import ExpenseFlowBase


class EntityRead(ExpenseFlowBase):
    """Entity read schema."""

    entity_id: UUID
    kind: EntityKind
