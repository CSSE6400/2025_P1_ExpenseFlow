"""Expense route tests."""

import pytest

from uuid import uuid4

from sqlalchemy.ext.asyncio import AsyncSession
from httpx import AsyncClient
from datetime import datetime, timedelta

base_url = "/expenses"

@pytest.mark.asyncio
async def test_create(session: AsyncSession,
                      test_client: AsyncClient,
                      expense_create_factory,
                      expense_item_create_factory,
                      expense_item_split_create_factory,
                      default_user):
    expense1 = expense_create_factory.build()
    expense1.name = "Test1"

    item1 = expense_item_create_factory.build()
    item1.splits = None
    expense1.items = [item1]

    request = test_client.build_request(method="post",
                                        url=base_url,
                                        json=expense1.model_dump(mode="json")
                                        )
    
    response = await test_client.send(request)

    assert response.status_code == 200
    response_json = response.json()
    assert response_json['name'] == expense1.name
    assert response_json['description'] == expense1.description
    assert datetime.strptime(
        response_json['expense_date'], "%Y-%m-%dT%H:%M:%SZ") == \
        (datetime.strptime(
            datetime.strftime(expense1.expense_date, "%Y-%m-%dT%H:%M:%SZ"),
            "%Y-%m-%dT%H:%M:%SZ"
            # SQL timezone stuff
            ) + timedelta(hours=10))
    assert response_json['category'] == expense1.category
    assert response_json['items'][0]['name'] == expense1.items[0].name

    bad_parent_id = uuid4()
    bad_parent_request = test_client.build_request(method="post",
                                                   url=base_url,
                                                   json=expense1.model_dump(
                                                       mode="json"
                                                       ),
                                                       params={
                                                           "parent_id":
                                                           bad_parent_id
                                                           })

    bad_parent_response = await test_client.send(bad_parent_request)

    assert bad_parent_response.status_code == 404
    assert bad_parent_response.json()['detail'] == \
        f"Parent under the id '{bad_parent_id}' could not be found"
    
    expense2 = expense_create_factory.build()
    item2 = expense_item_create_factory.build()
    for split_item in item2.splits:
        split_item.proportion = 1.5
    expense2.items = [item2]
    bad_expense_request = test_client.build_request(method="post",
                                                    url=base_url,
                                                    json=expense2.model_dump(
                                                        mode="json"
                                                        )
                                                    )
    
    bad_expense_response = await test_client.send(bad_expense_request)

    assert bad_expense_response.status_code == 400
    assert bad_expense_response.json()['detail'] == \
        "The total proportion of an expense item does not add to 1."
    
    expense3 = expense_create_factory.build()
    bad_user_id = bad_parent_id
    item3 = expense_item_create_factory.build()
    item3.splits = expense_item_split_create_factory.generate_splits()
    item3.splits[0].user_id = bad_user_id
    expense3.items = [item3]
    bad_user_request = test_client.build_request(method="post",
                                                 url=base_url,
                                                 json=expense3.model_dump(
                                                     mode="json"
                                                     )
                                                 )
    
    bad_user_response = await test_client.send(bad_user_request)

    assert bad_user_response.status_code == 400
    assert bad_user_response.json()['detail'] != \
        "The total proportion of an expense item does not add to 1."
    

@pytest.mark.asyncio
async def test_update(session: AsyncSession,
                      test_client: AsyncClient,
                      expense_create_factory,
                      expense_item_create_factory,
                      default_user):
    pass