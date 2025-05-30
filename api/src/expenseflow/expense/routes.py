"""Expense Routes."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.entity.service import get_entity
from expenseflow.enums import ExpenseStatus
from expenseflow.errors import NotFoundError, RoleError
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseCreate, ExpenseRead
from expenseflow.expense.service import (
    create_expense,
    get_expense,
    get_expense_status,
    get_uploaded_expenses,
    get_user_split_status,
    update_expense,
    update_split_status,
)

r = router = APIRouter()


@r.post("", response_model=ExpenseRead)
async def create(
    db: DbSession,
    user: CurrentUser,
    expense_in: ExpenseCreate,
    parent_id: UUID | None = None,
) -> ExpenseModel:
    """Create expense."""
    parent = user if parent_id is None else await get_entity(db, parent_id)
    if parent is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Parent under the id '{parent_id}' could not be found",
        )
    try:
        return await create_expense(db, user, expense_in, parent)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The total proportion of an expense item does not add to 1.",
        ) from e
    except NotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(e)
        ) from e


@r.put("/{expense_id}", response_model=ExpenseRead)
async def update(
    db: DbSession, user: CurrentUser, expense_id: UUID, expense_in: ExpenseCreate
) -> ExpenseModel:
    """Update an expense."""
    expense = await get_expense(db, user, expense_id)
    if expense is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Expense under the id '{expense_id}' could not be found",
        )
    try:
        return await update_expense(db, user, expense, expense_in)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="The total proportion of an expense item does not add to 1.",
        ) from e
    except NotFoundError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(e)
        ) from e
    except RoleError as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e)) from e


@r.get("/{expense_id}", response_model=ExpenseRead)
async def get(db: DbSession, user: CurrentUser, expense_id: UUID) -> ExpenseModel:
    """Get expense."""
    expense = await get_expense(db, user, expense_id)
    if expense is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Expense under the id '{expense_id}' could not be found",
        )
    return expense


@r.get("", response_model=list[ExpenseRead])
async def get_uploaded_by_me(db: DbSession, user: CurrentUser) -> list[ExpenseModel]:
    """Get expenses uploaded by me."""
    return await get_uploaded_expenses(db, user)


@r.get("/{expense_id}/my-status", response_model=ExpenseStatus)
async def get_my_status(
    db: DbSession, user: CurrentUser, expense_id: UUID
) -> ExpenseStatus:
    """Get status of an expense."""
    expense = await get_expense(db, user, expense_id)
    if expense is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Expense under the id '{expense_id}' could not be found",
        )
    return await get_user_split_status(db, expense, user)


@r.get("/{expense_id}/overall-status", response_model=ExpenseStatus)
async def get_overall_status(
    db: DbSession, user: CurrentUser, expense_id: UUID
) -> ExpenseStatus:
    """Get status of an expense."""
    expense = await get_expense(db, user, expense_id)
    if expense is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Expense under the id '{expense_id}' could not be found",
        )
    return await get_expense_status(db, expense)


@r.put("/{expense_id}/status", response_model=ExpenseRead)
async def update_stautus(
    db: DbSession, user: CurrentUser, expense_id: UUID, new_status: ExpenseStatus
) -> ExpenseModel:
    """Get status of an expense."""
    expense = await get_expense(db, user, expense_id)
    if expense is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Expense under the id '{expense_id}' could not be found",
        )
    await update_split_status(db, user, expense, new_status)

    return expense
