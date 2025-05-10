"""Group service."""

from uuid import UUID

from loguru import logger
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.enums import GroupRole
from expenseflow.errors import ExistsError, RoleError
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


async def get_user_groups(user: UserModel) -> list[GroupUserModel]:
    """Get a users groups."""
    return user.groups


async def get_group_users(group: GroupModel) -> list[GroupUserModel]:
    """Get a users groups."""
    return group.users


async def get_group(
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


async def get_group_user(
    session: AsyncSession, user: UserModel, group: GroupModel
) -> GroupUserModel | None:
    """Get group user membership."""
    return (
        await session.execute(
            select(GroupUserModel)
            .where(GroupUserModel.group_id == group.group_id)
            .where(GroupUserModel.user_id == user.user_id)
        )
    ).scalar_one_or_none()


async def create_update_group_user_role(
    session: AsyncSession,
    creator: UserModel,
    group: GroupModel,
    new_user: UserModel,
    new_role: GroupRole,
) -> GroupUserModel:
    """Create or update a user's role in a group.

    Args:
        session (AsyncSession): db session
        creator (UserModel): user creating role
        group (GroupModel): group that the role is created in
        new_user (UserModel): new user to get role
        new_role (GroupRole): new role that user is getting

    Raises:
        ExistsError: Raised if the creator doesn't exist in the group
        RoleError: Raised if the creator doesn't have the sufficient roles to add people

    Returns:
        GroupUserModel: group membership
    """
    # Get adding user's role
    creator_membership = await get_group_user(session, creator, group)
    if creator_membership is None:
        raise ExistsError  # This should not occur

    if creator_membership.role != GroupRole.admin:
        raise RoleError

    # See if user already exists in the group
    new_user_membership = await get_group_user(session, new_user, group)
    if new_user_membership is not None:
        new_user_membership.role = (
            new_role  # Simply updates role (note: Admin -> Member is fine)
        )
        return new_user_membership

    new_user_membership = GroupUserModel(user=new_user, group=group, role=new_role)
    await session.commit()

    return new_user_membership


async def delete_user_from_group(
    session: AsyncSession,
    actor: UserModel,
    group: GroupModel,
    user_to_delete: UserModel,
) -> GroupUserModel:
    """Delete a user from a group.

    Args:
        session (AsyncSession): db session
        actor (UserModel): actor who is deleting user - they should belong to the group
        group (GroupModel): group
        user_to_delete (UserModel): user to be deleted

    Raises:
        ValueError: Raised if the actor is not a part of the group (INVALID)
        RoleError: Raised if the actor is not an admin
        ExistsError: Raised if the user to be deleted doesn't exist in the group

    Returns:
        GroupUserModel: _description_
    """
    # Get adding user's role
    actor_membership = await get_group_user(session, actor, group)
    if actor_membership is None:
        logger.error(
            "Invalid state: Actor that is deleting user from group should be a part of the group."
        )
        raise ValueError

    if actor_membership.role != GroupRole.admin:
        raise RoleError

    deleted_user_membership = await get_group_user(session, user_to_delete, group)
    if deleted_user_membership is None:
        raise ExistsError

    await session.delete(deleted_user_membership)
    await session.commit()
    return deleted_user_membership
