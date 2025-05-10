"""Friend services."""

from sqlalchemy import and_, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.enums import FriendStatus
from expenseflow.friend.models import FriendModel
from expenseflow.user.models import UserModel


async def get_friends(session: AsyncSession, user: UserModel) -> list[UserModel]:
    """Get a user's friends."""
    models = (
        (
            await session.execute(
                select(FriendModel)
                .where(
                    or_(
                        FriendModel.sender_id == user.user_id,
                        FriendModel.receiver_id == user.user_id,
                    ),
                )
                .where(FriendModel.status == FriendStatus.accepted)
            )
        )
        .scalars()
        .all()
    )

    return [
        friend.receiver if friend.sender_id == user.user_id else friend.sender
        for friend in models
    ]


async def get_received_friend_requests(
    session: AsyncSession, user: UserModel
) -> list[UserModel]:
    """Get a user's received friend requests."""
    requests = (
        (
            await session.execute(
                select(FriendModel).where(FriendModel.receiver_id == user.user_id)
            )
        )
        .scalars()
        .all()
    )
    return [r.receiver for r in requests]


async def get_sent_friend_requests(
    session: AsyncSession, user: UserModel
) -> list[UserModel]:
    """Get a user's sent friend requests."""
    requests = (
        (
            await session.execute(
                select(FriendModel).where(FriendModel.sender_id == user.user_id)
            )
        )
        .scalars()
        .all()
    )
    return [r.receiver for r in requests]


async def create_accept_friend_request(
    session: AsyncSession, sender: UserModel, receiver: UserModel
) -> FriendModel:
    """Creates or accepts a friend request."""
    existing_request = (
        await session.execute(
            select(FriendModel).where(
                or_(
                    and_(
                        FriendModel.sender_id == sender.user_id,
                        FriendModel.receiver_id == receiver.user_id,
                    ),
                    and_(
                        FriendModel.receiver_id == sender.user_id,
                        FriendModel.sender_id == receiver.user_id,
                    ),
                )
            )
        )
    ).scalar_one_or_none()

    # Create a friend request
    if existing_request is None:
        friend_request = FriendModel(sender=sender, receiver=receiver)
        session.add(friend_request)
        await session.commit()
        return friend_request

    # Already accepted or already sent
    if (
        existing_request.status == FriendStatus.accepted
        or existing_request.sender_id == sender.user_id
    ):
        return existing_request

    existing_request.status = FriendStatus.accepted
    await session.commit()
    return existing_request


async def remove_friend(
    session: AsyncSession, actor: UserModel, other_friend: UserModel
) -> FriendModel | None:
    """Remove friend/friend request."""
    existing_request = (
        await session.execute(
            select(FriendModel).where(
                or_(
                    and_(
                        FriendModel.sender_id == actor.user_id,
                        FriendModel.receiver_id == other_friend.user_id,
                    ),
                    and_(
                        FriendModel.receiver_id == actor.user_id,
                        FriendModel.sender_id == other_friend.user_id,
                    ),
                )
            )
        )
    ).scalar_one_or_none()

    if existing_request is None:
        return None

    await session.delete(existing_request)
    await session.commit()
    return existing_request
