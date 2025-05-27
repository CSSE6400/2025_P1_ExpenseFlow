"""Group Expense routes."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseRead
from expenseflow.expense.service import get_owned_expenses
from expenseflow.group.service import get_group

r = router = APIRouter()


@r.get("/{group_id}", response_model=list[ExpenseRead])
async def get_group_expenses(
    db: DbSession, user: CurrentUser, group_id: UUID
) -> list[ExpenseModel]:
    """Get all group expenses."""
    group = await get_group(db, user, group_id)
    if group is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Group under the id '{group_id}' could not be found",
        )

    return await get_owned_expenses(db, group)
