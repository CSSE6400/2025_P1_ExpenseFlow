"""Group service."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.enums import GroupRole
from expenseflow.group.models import GroupModel, GroupUserModel
from expenseflow.group.schemas import GroupCreate, GroupUpdate
from expenseflow.user.models import UserModel


async def create_group(
    session: AsyncSession, group_creator: UserModel, group_in: GroupCreate
) -> GroupModel:
    """Create group and create owner."""
    group_model = GroupModel(name=group_in.name, description=group_in.description)

    # It will get the 'group' attribute automagically
    group_user = GroupUserModel(user=group_creator, role=GroupRole.admin)
    group_model.users.append(group_user)

    session.add(group_model)
    await session.commit()
    return group_model


async def get_groups(user: UserModel) -> list[GroupUserModel]:
    """Get a users groups."""
    return user.groups


async def get_user_group(
    session: AsyncSession, member: UserModel, group_id: UUID
) -> GroupModel | None:
    """Get a group if a user exists in the group."""
    return (
        await session.execute(
            select(GroupModel)
            .join(GroupUserModel)
            .where(GroupModel.group_id == group_id)
            .where(GroupModel.group_id == GroupUserModel.group_id)
            .where(GroupUserModel.user_id == member.user_id)
        )
    ).scalar_one_or_none()


async def update_group(
    session: AsyncSession,
    group: GroupModel,
    group_in: GroupUpdate,
) -> GroupModel:
    """Update group."""
    update_data = group_in.model_dump()

    for field in group.to_dict():
        if field in update_data:
            setattr(group, field, update_data[field])

    await session.commit()
    return group
