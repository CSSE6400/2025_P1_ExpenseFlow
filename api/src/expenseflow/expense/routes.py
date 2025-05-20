"""Expense Routes."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.entity.service import get_entity
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseCreate, ExpenseRead
from expenseflow.expense.service import create_expense, get_uploaded_expenses

r = router = APIRouter()


@r.post("", response_model=ExpenseRead)
async def create(
    db: DbSession, user: CurrentUser, expense_in: ExpenseCreate, parent_id: UUID | None
) -> ExpenseModel:
    """Create expense."""
    parent = user if parent_id is None else await get_entity(db, parent_id)
    if parent is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Parent under the id '{parent_id}' could not be found",
        )
    return await create_expense(db, user, expense_in, parent)


@r.get("", response_model=list[ExpenseRead])
async def get_uploaded_by_me(db: DbSession, user: CurrentUser) -> list[ExpenseModel]:
    """Get expenses uploaded by me."""
    return await get_uploaded_expenses(db, user)
