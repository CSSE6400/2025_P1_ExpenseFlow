"""Group routes."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.enums import GroupRole
from expenseflow.errors import ExistsError, RoleError
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseRead
from expenseflow.expense.service import get_owned_expenses
from expenseflow.group.models import GroupModel, GroupUserModel
from expenseflow.group.schemas import (
    GroupCreate,
    GroupRead,
    GroupReadWithMembers,
    GroupUpdate,
    GroupUserRead,
    UserGroupRead,
)
from expenseflow.group.service import (
    create_group,
    create_update_group_user_role,
    delete_user_from_group,
    get_group,
    get_group_users,
    get_groups_with_members,
    get_user_groups,
    update_group,
)
from expenseflow.user.service import get_user_by_id

r = router = APIRouter()


def to_group_user(model: GroupUserModel) -> GroupUserRead:
    """Converts to group user schema."""
    return GroupUserRead(
        group_id=model.group_id,
        name=model.group.name,
        description=model.group.name,
        role=model.role,
        joined_at=model.joined_at,
    )


def to_user_group(model: GroupUserModel) -> UserGroupRead:
    """Converts to user group schemal."""
    return UserGroupRead(
        user_id=model.user_id,
        first_name=model.user.first_name,
        last_name=model.user.last_name,
        nickname=model.user.nickname,
        role=model.role,
        joined_at=model.joined_at,
        budget=model.user.budget,
    )


@r.get("", response_model=list[GroupUserRead])
async def get_many(user: CurrentUser) -> list[GroupUserRead]:
    """Get user groups."""
    groups = await get_user_groups(user)
    return [to_group_user(g) for g in groups]


@r.get("/with-members", response_model=list[GroupReadWithMembers])
async def get_many_with_members(
    session: DbSession, user: CurrentUser
) -> list[GroupReadWithMembers]:
    """Get user groups."""
    return await get_groups_with_members(session, user)


@r.get("/{group_id}", response_model=GroupRead)
async def get(db: DbSession, user: CurrentUser, group_id: UUID) -> GroupModel:
    """Get a group."""
    result = await get_group(db, user, group_id)
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
    group = await get_group(db, user, group_id)
    if group is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Group under the id '{group_id}' could not be found",
        )
    return await update_group(db, group, group_in)


@r.get("/{group_id}/users", response_model=list[UserGroupRead])
async def get_users(
    db: DbSession, user: CurrentUser, group_id: UUID
) -> list[UserGroupRead]:
    """Get users in a group."""
    group = await get_group(db, user, group_id)
    if group is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Group under the id '{group_id}' could not be found",
        )

    users = await get_group_users(group)
    return [to_user_group(u) for u in users]


@r.put("/{group_id}/users/{user_id}")
async def create_update_group_user(
    db: DbSession, user: CurrentUser, group_id: UUID, role: GroupRole, user_id: UUID
) -> UserGroupRead:
    """Create or update a user's role in a group."""
    group = await get_group(db, user, group_id)
    if group is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Group under the id '{group_id}' could not be found",
        )

    new_user = await get_user_by_id(db, user_id)
    if new_user is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the id '{user_id}' could not be found",
        )
    try:
        result = await create_update_group_user_role(db, user, group, new_user, role)
    except RoleError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e),
        ) from e
    except ExistsError:
        raise

    return to_user_group(result)


@r.delete("/{group_id}/users/{user_id}")
async def delete_group_user(
    db: DbSession, current_user: CurrentUser, group_id: UUID, user_id: UUID
) -> UserGroupRead:
    """Delete a user in a group."""
    group = await get_group(db, current_user, group_id)
    if group is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"Group under the id '{group_id}' could not be found",
        )

    user_to_delete = await get_user_by_id(db, user_id)
    if user_to_delete is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=f"User under the id '{user_id}' could not be found",
        )

    try:
        result = await delete_user_from_group(db, current_user, group, user_to_delete)
    except RoleError as e:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=str(e),
        ) from e
    except ExistsError as e:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            detail=str(e),
        ) from e

    return to_user_group(result)


@r.get("/{group_id}/expenses", response_model=list[ExpenseRead])
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
