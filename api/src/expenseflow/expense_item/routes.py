"""Expense item routes."""

from uuid import UUID

from fastapi import APIRouter

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.expense_item.schemas import ExpenseItemRead

r = router = APIRouter()


@r.get("/{expense_id}/items")
async def get_items(
    db: DbSession, user: CurrentUser, expense_id: UUID
) -> list[ExpenseItemRead]:
    """Get all items in an expense."""
    return []
