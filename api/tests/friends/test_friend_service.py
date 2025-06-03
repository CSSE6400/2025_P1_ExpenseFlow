"""Test Friend Service."""

import pytest # noqa: F401

from expenseflow.enums import FriendStatus
from expenseflow.friend.models import UserModel, FriendModel
from expenseflow.friend.schemas import FriendRead, UserRead
from expenseflow.friend.service import create_accept_friend_request, \
    get_sent_friend_requests, get_received_friend_requests, get_friends, \
    remove_friend
from sqlalchemy.ext.asyncio import AsyncSession
from expenseflow.errors import ExpenseFlowError

@pytest.mark.asyncio
async def test_add_friend(
    session: AsyncSession,
    user_model_factory
):
    sender = user_model_factory.build()
    receiver = user_model_factory.build()
    friend_model = await create_accept_friend_request(session,
                                                      sender,
                                                      receiver)
    assert friend_model
    assert friend_model.sender_id == sender.user_id
    assert friend_model.receiver_id == receiver.user_id
    
    requests = await get_sent_friend_requests(session, sender)
    assert len(requests) == 1
    request = requests[0]
    assert request.user_id == receiver.user_id
    empty_requests = await get_sent_friend_requests(session, receiver)
    assert len(empty_requests) == 0

    recv_requests = await get_received_friend_requests(session, receiver)
    assert len(recv_requests) == 1
    recv_request = recv_requests[0]
    assert recv_request.user_id == sender.user_id
    empty_recv_requests = await get_received_friend_requests(session, sender)
    assert len(empty_recv_requests) == 0

    accepted_friend_model = await create_accept_friend_request(session,
                                                               receiver,
                                                               sender)
    assert accepted_friend_model
    assert accepted_friend_model.status == FriendStatus.accepted
    
    send_friends = await get_friends(session, sender)
    assert len(send_friends) == 1
    assert send_friends[0].user_id == receiver.user_id
    recv_friends = await get_friends(session, receiver)
    assert len(recv_friends) == 1
    assert recv_friends[0].user_id == sender.user_id
    _ = await remove_friend(session, sender, receiver)

@pytest.mark.asyncio
async def test_accepted_request(
    session: AsyncSession,
    user_model_factory
):
    sender = user_model_factory.build()
    receiver = user_model_factory.build()
    friend_model = await create_accept_friend_request(session,
                                                      sender,
                                                      receiver)
    
    accepted_friend_model = await create_accept_friend_request(session,
                                                               receiver,
                                                               sender)

    requests = await get_sent_friend_requests(session, sender)
    assert len(requests) == 1
    assert requests[0].user_id == receiver.user_id
    empty_requests = await get_sent_friend_requests(session, receiver)
    assert len(empty_requests) == 0

    recv_requests = await get_received_friend_requests(session, receiver)
    assert len(recv_requests) == 1
    assert recv_requests[0].user_id == sender.user_id
    empty_recv_requests = await get_received_friend_requests(session, sender)
    assert len(empty_recv_requests) == 0

@pytest.mark.asyncio
async def test_remove_friend(
    session: AsyncSession,
    user_model_factory
):
    sender = user_model_factory.build()
    receiver = user_model_factory.build()
    friend_model = await create_accept_friend_request(session,
                                                      sender,
                                                      receiver)
    
    accepted_friend_model = await create_accept_friend_request(session,
                                                               receiver,
                                                               sender)
    
    
    send_friends = await get_friends(session, sender)
    assert len(send_friends) == 1
    assert send_friends[0].user_id == receiver.user_id
    recv_friends = await get_friends(session, receiver)
    assert len(recv_friends) == 1
    assert recv_friends[0].user_id == sender.user_id

    request = await remove_friend(session, sender, receiver)
    
    send_friends = await get_friends(session, sender)
    assert len(send_friends) == 0
    recv_friends = await get_friends(session, receiver)
    assert len(recv_friends) == 0

    other_request = await remove_friend(session, receiver, sender)
    assert other_request is None


@pytest.mark.asyncio
async def test_fuzz_create_friend(
    session: AsyncSession,
    user_model_factory
):
    sender = user_model_factory.build()
    receiver = user_model_factory.build()
    
    with pytest.raises(ExpenseFlowError) as eferror:
        await create_accept_friend_request(session, sender, sender)
    assert str(eferror.value) == \
        f"User '{sender.user_id}' cannot friend itself."
    
    with pytest.raises(ExpenseFlowError) as eferror:
        await create_accept_friend_request(session, receiver, receiver)
    assert str(eferror.value) == \
        f"User '{receiver.user_id}' cannot friend itself."
    
    requests = await get_sent_friend_requests(session, sender)
    assert len(requests) == 0
    recv_requests = await get_sent_friend_requests(session, receiver)
    assert len(recv_requests) == 0
