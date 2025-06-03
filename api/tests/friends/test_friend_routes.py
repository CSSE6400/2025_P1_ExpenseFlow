"""Test Friend Routes."""

import pytest  # noqa: F401

from fastapi import APIRouter, HTTPException, status

from uuid import uuid4

from expenseflow.enums import FriendStatus
from expenseflow.friend.models import UserModel, FriendModel
from expenseflow.friend.schemas import FriendRead, UserRead
from expenseflow.friend.service import create_accept_friend_request, \
    get_sent_friend_requests, get_received_friend_requests, get_friends, \
    remove_friend
from sqlalchemy.ext.asyncio import AsyncSession
from httpx import AsyncClient
from expenseflow.errors import ExpenseFlowError

# remove later
from expenseflow.user.service import get_user_by_id, get_user_by_nickname, get_all_users

base_url = "/friends"

@pytest.mark.asyncio
async def test_get_friends(session: AsyncSession,
                           test_client: AsyncClient, 
                           user_model_factory,
                           default_user):
    sender = default_user
    receiver = user_model_factory.build()
    
    request = test_client.build_request(method="get", url=base_url)
    
    response = await test_client.send(request)
    assert response.json() == []

    _ = await create_accept_friend_request(session,
                                           sender,
                                           receiver)
    
    _ = await create_accept_friend_request(session,
                                           receiver,
                                           sender)

    response = await test_client.send(request)

    assert response.status_code == 200
    assert len(response.json()) == 1

    

@pytest.mark.asyncio
async def test_get_requests(session: AsyncSession,
                            test_client: AsyncClient,
                            user_model_factory,
                            default_user):
    default = default_user
    receiver = user_model_factory.build()
    sender = user_model_factory.build()
    sent_request = test_client.build_request(method="get",
                                             url=base_url+"/requests",
                                             params={"sent": True})
    
    recv_request = test_client.build_request(method="get",
                                             url=base_url+"/requests",
                                             params={"sent": False})
    
    sent_response = await test_client.send(sent_request)
    recv_response = await test_client.send(recv_request)

    assert sent_response.status_code == 200
    assert sent_response.json() == []

    assert recv_response.status_code == 200
    assert recv_response.json() == []

    _ = await create_accept_friend_request(session,
                                           default,
                                           receiver)
    
    _ = await create_accept_friend_request(session,
                                           sender,
                                           default)
    
    sent_response = await test_client.send(sent_request)
    recv_response = await test_client.send(recv_request)

    assert sent_response.status_code == 200
    assert len(sent_response.json()) == 1

    assert recv_response.status_code == 200
    assert len(recv_response.json()) == 1

@pytest.mark.asyncio
async def test_create_by_nickname(session: AsyncSession,
                                  test_client: AsyncClient,
                                  user_model_factory,
                                  default_user):
    lucas_request = test_client.build_request(method="put",
                                              url=base_url,
                                              params={"nickname": "lucashicks1"})
    david_request = test_client.build_request(method="put",
                                              url=base_url,
                                              params={"nickname": "daqoblade"})
    tom_request = test_client.build_request(method="put",
                                            url=base_url,
                                            params={"nickname": "superstrooper"})
    bad_request = test_client.build_request(method="put",
                                            url=base_url,
                                            params={"nickname": "faker"})
    lucas = user_model_factory.build()
    david = user_model_factory.build()
    tom = user_model_factory.build()

    lucas.nickname = "lucashicks1"
    david.nickname = "daqoblade"
    tom.nickname = "superstrooper"
    
    session.add(lucas)
    session.add(david)
    session.add(tom)
    await session.commit()

    lucas_response = await test_client.send(lucas_request)
    david_response = await test_client.send(david_request)
    tom_response = await test_client.send(tom_request)

    friend_list = await get_sent_friend_requests(session, default_user)
    assert len(friend_list) == 3

    bad_response = await test_client.send(bad_request)

    assert bad_response.json()['detail'] == \
        "User under the nickname 'faker' could not be found"
    

@pytest.mark.asyncio
async def test_create(session: AsyncSession,
                      test_client: AsyncClient,
                      user_model_factory,
                      default_user):
    
    user = user_model_factory.build()
    nickname = "test_dummy_add"
    user.nickname = nickname

    session.add(user)
    await session.commit()
    
    user = await get_user_by_nickname(session, nickname)
    user_id = user.user_id

    friend_list = await get_sent_friend_requests(session, default_user)
    assert len(friend_list) == 0

    request = test_client.build_request(method="put",
                                        url=base_url+f"/{user_id}")
    bad_uuid = uuid4()
    bad_request = test_client.build_request(method="put",
                                            url=base_url+f"/{bad_uuid}")

    response = await test_client.send(request)

    friend_list = await get_sent_friend_requests(session, default_user)
    assert len(friend_list) == 1
    
    bad_response = await test_client.send(bad_request)

    assert bad_response.json()['detail'] == \
        f"User under the id '{bad_uuid}' could not be found"

@pytest.mark.asyncio
async def test_delete(session: AsyncSession,
                      test_client: AsyncClient,
                      user_model_factory,
                      default_user):
    
    user = user_model_factory.build()
    nickname = "test_dummy_del"
    user.nickname = nickname

    session.add(user)
    await session.commit()
    
    user = await get_user_by_nickname(session, nickname)
    user_id = user.user_id

    friend_list = await get_sent_friend_requests(session, default_user)
    assert len(friend_list) == 0

    response = await test_client.put(url=base_url+f"/{user_id}")

    friend_list = await get_sent_friend_requests(session, default_user)
    assert len(friend_list) == 1

    request = test_client.build_request(method="delete",
                                        url=base_url+f"/{user_id}")
    bad_uuid = uuid4()
    bad_request = test_client.build_request(method="delete",
                                            url=base_url+f"/{bad_uuid}")

    response = await test_client.send(request)

    friend_list = await get_sent_friend_requests(session, default_user)
    assert len(friend_list) == 0
    
    bad_response = await test_client.send(bad_request)

    assert bad_response.json()['detail'] == \
        f"User under the id '{bad_uuid}' could not be found"