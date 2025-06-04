"""Expense route tests."""

import pytest

from uuid import uuid4

from sqlalchemy.ext.asyncio import AsyncSession
from httpx import AsyncClient
from datetime import datetime, timedelta
from expenseflow.enums import ExpenseStatus

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
    uuid = response_json['expense_id']
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

    get_by_me_request = test_client.build_request(method="get",
                                                  url=base_url
                                                  )
    get_by_me_response = await test_client.send(get_by_me_request)
    get_by_me_response_json = get_by_me_response.json()
    assert len(get_by_me_response_json) == 1
    get_by_me_item = get_by_me_response_json[0]
    assert get_by_me_item['name'] == expense1.name
    assert get_by_me_item['description'] == expense1.description
    assert datetime.strptime(
        get_by_me_item['expense_date'], "%Y-%m-%dT%H:%M:%SZ") == \
        (datetime.strptime(
            datetime.strftime(expense1.expense_date, "%Y-%m-%dT%H:%M:%SZ"),
            "%Y-%m-%dT%H:%M:%SZ"
            # SQL timezone stuff
            ) + timedelta(hours=10))
    assert get_by_me_item['category'] == expense1.category
    assert get_by_me_item['items'][0]['name'] == expense1.items[0].name

    get_request = test_client.build_request(method="get",
                                            url=base_url+f"/{uuid}"
                                            )
    get_response = await test_client.send(get_request)
    get_item = get_response.json()
    assert get_item == get_by_me_item


@pytest.mark.asyncio
async def test_bad_parent_create(session: AsyncSession,
                                 test_client: AsyncClient,
                                 expense_create_factory,
                                 expense_item_create_factory,
                                 expense_item_split_create_factory,
                                 default_user):
    expense = expense_create_factory.build()
    expense.name = "Test1"
    bad_parent_id = uuid4()
    bad_parent_request = test_client.build_request(method="post",
                                                   url=base_url,
                                                   json=expense.model_dump(
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

@pytest.mark.asyncio
async def test_bad_expense_create(session: AsyncSession,
                                 test_client: AsyncClient,
                                 expense_create_factory,
                                 expense_item_create_factory,
                                 expense_item_split_create_factory,
                                 default_user):
    expense = expense_create_factory.build()
    item2 = expense_item_create_factory.build()
    for split_item in item2.splits:
        split_item.proportion = 1.5
    expense.items = [item2]
    bad_expense_request = test_client.build_request(method="post",
                                                    url=base_url,
                                                    json=expense.model_dump(
                                                        mode="json"
                                                        )
                                                    )

    bad_expense_response = await test_client.send(bad_expense_request)

    assert bad_expense_response.status_code == 400
    assert bad_expense_response.json()['detail'] == \
        "The total proportion of an expense item does not add to 1."

@pytest.mark.asyncio
async def test_bad_user_create(session: AsyncSession,
                               test_client: AsyncClient,
                               expense_create_factory,
                               expense_item_create_factory,
                               expense_item_split_create_factory,
                               default_user):
    expense3 = expense_create_factory.build()
    bad_user_id = uuid4()
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

    uuid = response.json()['expense_id']
    expense2 = expense_create_factory.build()
    
    expense2.items = [item1]
    put_request = test_client.build_request(method="put",
                                        url=base_url+f"/{uuid}",
                                        json=expense2.model_dump(mode="json")
                                        )
    
    response = await test_client.send(put_request)

    get_request = test_client.build_request(method="get",
                                            url=base_url
                                            )
    get_response = await test_client.send(get_request)
    get_response_json = get_response.json()
    assert len(get_response_json) == 1
    get_item = get_response_json[0]
    assert get_item['name'] == expense2.name
    assert get_item['description'] == expense2.description
    assert datetime.strptime(
        get_item['expense_date'], "%Y-%m-%dT%H:%M:%SZ") == \
        (datetime.strptime(
            datetime.strftime(expense2.expense_date, "%Y-%m-%dT%H:%M:%SZ"),
            "%Y-%m-%dT%H:%M:%SZ"
            # SQL timezone stuff
            ) + timedelta(hours=10))
    assert get_item['category'] == expense2.category
    assert get_item['items'][0]['name'] == expense1.items[0].name

@pytest.mark.asyncio
async def test_nonexistent_update(session: AsyncSession,
                                  test_client: AsyncClient,
                                  expense_create_factory,
                                  expense_item_create_factory,
                                  default_user):
    expense1 = expense_create_factory.build()
    bad_uuid = uuid4()
    request = test_client.build_request(method="put",
                                        url=base_url+f"/{bad_uuid}",
                                        json=expense1.model_dump(mode="json")
                                        )
    response = await test_client.send(request)
    assert response.status_code == 404
    assert response.json()['detail'] == \
        f"Expense under the id '{bad_uuid}' could not be found"

@pytest.mark.asyncio
async def test_nonexistent_user_split_update(session: AsyncSession,
                                             test_client: AsyncClient,
                                             expense_create_factory,
                                             expense_item_create_factory,
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

    uuid = response.json()['expense_id']
    # uuid of splits here will be bad
    expense2 = expense_create_factory.build()
    
    put_request = test_client.build_request(method="put",
                                        url=base_url+f"/{uuid}",
                                        json=expense2.model_dump(mode="json")
                                        )
    
    put_response = await test_client.send(put_request)
    assert put_response.status_code == 400

    get_request = test_client.build_request(method="get",
                                            url=base_url
                                            )
    get_response = await test_client.send(get_request)
    get_response_json = get_response.json()
    assert len(get_response_json) == 1
    get_item = get_response_json[0]
    assert get_item['name'] == expense1.name

@pytest.mark.asyncio
async def test_bad_split_update(session: AsyncSession,
                                test_client: AsyncClient,
                                expense_create_factory,
                                expense_item_create_factory,
                                default_user):
    expense1 = expense_create_factory.build()
    item1 = expense_item_create_factory.build()
    item1.splits = None
    expense1.items = [item1]

    request = test_client.build_request(method="post",
                                        url=base_url,
                                        json=expense1.model_dump(mode="json")
                                        )

    response = await test_client.send(request)
    uuid = response.json()['expense_id']

    expense2 = expense_create_factory.build()
    item2 = expense_item_create_factory.build()
    for split_item in item2.splits:
        split_item.proportion = 1.5
    expense2.items = [item2]

    put_request = test_client.build_request(method="put",
                                            url=base_url+f"/{uuid}",
                                            json=expense2.model_dump(
                                                mode="json"
                                                )
                                            )
    
    put_response = await test_client.send(put_request)
    assert put_response.status_code == 400
    assert put_response.json()['detail'] == \
        "The total proportion of an expense item does not add to 1."
    
@pytest.mark.asyncio
async def test_get_empty_overview(session: AsyncSession,
                                  test_client: AsyncClient,
                                  expense_create_factory,
                                  expense_item_create_factory,
                                  default_user):
    request = test_client.build_request(method="get",
                                        url=base_url+"/overview"
                                        )
    response = await test_client.send(request)
    assert response.status_code == 200
    response_json = response.json()
    assert response_json['total'] == 0
    assert response_json['categories'] == []

@pytest.mark.asyncio
async def test_get_non_empty_overview(session: AsyncSession,
                                      test_client: AsyncClient,
                                      expense_create_factory,
                                      expense_item_create_factory,
                                      default_user):
    expense1 = expense_create_factory.build()
    item1 = expense_item_create_factory.build()
    item1.splits = None
    expense1.items = [item1]

    request = test_client.build_request(method="post",
                                        url=base_url,
                                        json=expense1.model_dump(mode="json")
                                        )
    response = await test_client.send(request)
    request = test_client.build_request(method="get",
                                        url=base_url+"/overview"
                                        )
    response = await test_client.send(request)
    assert response.status_code == 200
    response_json = response.json()
    totalsum = item1.quantity * item1.price
    assert response_json['total'] == round(totalsum, 2)
    assert response_json['categories'] != []
    
@pytest.mark.asyncio
async def test_get_status(session: AsyncSession,
                          test_client: AsyncClient,
                          expense_create_factory,
                          expense_item_create_factory,
                          default_user):
    expense1 = expense_create_factory.build()
    item1 = expense_item_create_factory.build()
    item1.splits = None
    expense1.items = [item1]

    request = test_client.build_request(method="post",
                                        url=base_url,
                                        json=expense1.model_dump(mode="json")
                                        )

    response = await test_client.send(request)
    uuid = response.json()['expense_id']
    
    request = test_client.build_request(method="get",
                                        url=base_url+f"/{uuid}/my-status"
                                        )
    response = await test_client.send(request)
    assert response.status_code == 200
    assert response.json() == "paid"

@pytest.mark.asyncio
async def test_get_empty_status(session: AsyncSession,
                                test_client: AsyncClient,
                                expense_create_factory,
                                expense_item_create_factory,
                                default_user):
    uuid = uuid4()
    request = test_client.build_request(method="get",
                                        url=base_url+f"/{uuid}/my-status"
                                        )
    response = await test_client.send(request)
    assert response.status_code == 404
    assert response.json()['detail'] == \
        f"Expense under the id '{uuid}' could not be found"

@pytest.mark.asyncio
async def test_get_all_status(session: AsyncSession,
                          test_client: AsyncClient,
                          expense_create_factory,
                          expense_item_create_factory,
                          default_user):
    expense1 = expense_create_factory.build()
    item1 = expense_item_create_factory.build()
    item1.splits = None
    expense1.items = [item1]

    request = test_client.build_request(method="post",
                                        url=base_url,
                                        json=expense1.model_dump(mode="json")
                                        )

    response = await test_client.send(request)
    uuid = response.json()['expense_id']
    
    request = test_client.build_request(method="get",
                                        url=base_url+f"/{uuid}/all-status"
                                        )
    response = await test_client.send(request)
    assert response.status_code == 200
    assert response.json()[0]['user_id'] == str(default_user.user_id)

@pytest.mark.asyncio
async def test_update_nonexistent_status(session: AsyncSession,
                          test_client: AsyncClient,
                          expense_create_factory,
                          expense_item_create_factory,
                          default_user):
    new_status = ExpenseStatus.accepted
    uuid = uuid4()
    request = test_client.build_request(method="put",
                                        url=base_url+f"/{uuid}/status",
                                        params={"status":
                                                new_status.value}
                                        )
    response = await test_client.send(request)
    assert response.status_code == 404
    assert response.json()['detail'] == \
        f"Expense under the id '{uuid}' could not be found"
    
@pytest.mark.asyncio
async def test_update_status(session: AsyncSession,
                          test_client: AsyncClient,
                          expense_create_factory,
                          expense_item_create_factory,
                          default_user,
                          user_model_factory):
    other_user = user_model_factory.build()
    expense1 = expense_create_factory.build()
    item1 = expense_item_create_factory.build()

    session.add(default_user)
    session.add(other_user)
    await session.commit()

    item1.splits[0].user_id = default_user.user_id
    item1.splits[1].user_id = other_user.user_id
    expense1.items = [item1]

    request = test_client.build_request(
        method="post",
        url=base_url,
        json=expense1.model_dump(mode="json"),
        params={"parent_id": other_user.user_id}
        )
    
    make = await test_client.send(request)
    
    from expenseflow.auth.deps import get_current_user
    
    test_client._transport.app.dependency_overrides[get_current_user] \
        = lambda: other_user

    uuid = make.json()['expense_id']
    new_status = ExpenseStatus.accepted
    request = test_client.build_request(method="put",
                                        url=base_url+f"/{uuid}/status",
                                        params={"status":
                                                new_status.value}
                                        )
    response = await test_client.send(request)
    assert response.status_code == 200
    assert response.json()['items'][0]['splits'][1]['status'] == 'accepted'
    assert response.json()['items'][0]['splits'][1]['status'] == \
        ExpenseStatus.accepted