"""Group routes."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.group.models import GroupModel
from expenseflow.group.schemas import GroupCreate, GroupRead, GroupUpdate, UserGroupRead
from expenseflow.group.service import (
    create_group,
    get_groups,
    get_user_group,
    update_group,
)

r = router = APIRouter()


@r.get("", response_model=list[UserGroupRead])
async def get_many(user: CurrentUser) -> list[UserGroupRead]:
    """Get user groups."""
    groups = await get_groups(user)
    return [g.to_read() for g in groups]


@r.get("/{group_id}", response_model=GroupRead)
async def get(db: DbSession, user: CurrentUser, group_id: UUID) -> GroupModel:
    """Get a group."""
    result = await get_user_group(db, user, group_id)
    if result is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Group under the id '{group_id}' could not be found",
        )
    return result


@r.post("", response_model=GroupRead)
async def create(db: DbSession, user: CurrentUser, group_in: GroupCreate) -> GroupModel:
    """Create a group."""
    return await create_group(db, user, group_in)


@r.put("/{group_id}", response_model=GroupRead)
async def update(
    db: DbSession, user: CurrentUser, group_id: UUID, group_in: GroupUpdate
) -> GroupModel:
    """Update group."""
    group = await get_user_group(db, user, group_id)
    if group is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Group under the id '{group_id}' could not be found",
        )
    return await update_group(db, group, group_in)
