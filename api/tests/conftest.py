"""Config file to provide fixtures for test directory."""

import asyncio
import os
from collections.abc import AsyncGenerator

import pytest
import pytest_asyncio
from expenseflow.audit.models import AuditModel
from expenseflow.database.service import initialise_database
from expenseflow.expense.models import (
    ExpenseItemModel,
    ExpenseItemSplitModel,
    ExpenseModel,
)
from expenseflow.expense.schemas import (
    ExpenseCreate,
)
from expenseflow.group.models import GroupModel, GroupUserModel
from expenseflow.group.schemas import (
    GroupCreate,
    GroupUpdate,
    GroupUserRead,
    UserGroupRead,
)
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreate, UserCreateInternal
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient
from loguru import logger
from polyfactory.pytest_plugin import register_fixture
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy_utils import create_database, database_exists, drop_database

from tests.factories import (
    AuditModelFactory,
    ExpenseCreateFactory,
    ExpenseItemCreateFactory,
    ExpenseItemModelFactory,
    ExpenseItemSplitCreateFactory,
    ExpenseItemSplitModelFactory,
    ExpenseModelFactory,
    GroupCreateFactory,
    GroupModelFactory,
    GroupUpdateFactory,
    GroupUserModelFactory,
    GroupUserReadFactory,
    UserCreateFactory,
    UserCreateInternalFactory,
    UserGroupReadFactory,
    UserModelFactory,
)

# Hardcoded docker compose db so that no-one runs tests on prod db
TEST_DB_URL = "postgresql+asyncpg://admin:password@localhost:5432/expense_db"
SYNC_TEST_DB_URL = "postgresql://admin:password@localhost:5432/expense_db"


os.environ["FRONTEND_URL"] = ""
os.environ["DB_URL"] = TEST_DB_URL
os.environ["JWT_AUDIENCE"] = ""
os.environ["AUTH0_DOMAIN"] = ""


# Initialise db
test_engine: AsyncEngine = create_async_engine(
    TEST_DB_URL,
    pool_pre_ping=True,
)


@pytest.fixture(scope="session")
def event_loop():
    """Override default function scoped event loop."""
    policy = asyncio.get_event_loop_policy()
    loop = policy.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
def test_app() -> FastAPI:
    """FastAPI App fixture."""
    from expenseflow.main import app

    return app


@pytest_asyncio.fixture(scope="session")
async def db() -> AsyncGenerator[None]:
    """Database fixture."""
    if database_exists(SYNC_TEST_DB_URL):
        logger.warning(f"Already found db at {SYNC_TEST_DB_URL}. Dropping now...")
        drop_database(SYNC_TEST_DB_URL)

    # Create fresh new one
    create_database(SYNC_TEST_DB_URL)

    await initialise_database(test_engine)
    yield


@pytest_asyncio.fixture(scope="function", autouse=True)
async def session(db) -> AsyncGenerator[AsyncSession]:  # noqa: ANN001
    """Session fixture for test duration."""
    async_session_factory = async_sessionmaker(
        test_engine, class_=AsyncSession, expire_on_commit=False
    )

    async with async_session_factory() as session:
        yield session
        await session.rollback()


register_fixture(UserModelFactory)
register_fixture(GroupModelFactory)
register_fixture(GroupUserModelFactory)
register_fixture(ExpenseCreateFactory)
register_fixture(ExpenseItemCreateFactory)
register_fixture(ExpenseItemSplitCreateFactory)
register_fixture(ExpenseModelFactory)
register_fixture(ExpenseItemModelFactory)
register_fixture(ExpenseItemSplitModelFactory)
register_fixture(AuditModelFactory)


@pytest.fixture()
def default_user() -> UserModel:
    """Default user fixture."""
    return UserModelFactory.build()


@pytest_asyncio.fixture(scope="function")
async def test_client(
    test_app: FastAPI, session: AsyncSession, default_user: UserModel
) -> AsyncGenerator[AsyncClient, None]:
    """Test client fixture."""
    # Need to override

    from expenseflow.auth.deps import get_current_user, get_user_token_identifier
    from expenseflow.database.deps import get_db

    # Override dependencies
    test_app.dependency_overrides[get_current_user] = lambda: default_user
    test_app.dependency_overrides[get_user_token_identifier] = lambda: "token_id"
    test_app.dependency_overrides[get_db] = lambda: session

    async with AsyncClient(
        transport=ASGITransport(app=test_app), base_url="http://test"
    ) as client:
        yield client


## Factory fixtures


# User factories
@pytest.fixture()
def user_model() -> UserModel:
    return UserModelFactory.build()


@pytest.fixture()
def user_create() -> UserCreate:
    return UserCreateFactory.build()


@pytest.fixture()
def user_create_internal() -> UserCreateInternal:
    return UserCreateInternalFactory.build()


# Group factories


@pytest.fixture()
def group_model() -> GroupModel:
    return GroupModelFactory.build()


@pytest.fixture()
def group_create() -> GroupCreate:
    return GroupCreateFactory.build()


@pytest.fixture()
def group_update() -> GroupUpdate:
    return GroupUpdateFactory.build()


@pytest.fixture()
def group_user_model() -> GroupUserModel:
    return GroupUserModelFactory.build()


@pytest.fixture()
def user_group_read() -> UserGroupRead:
    return UserGroupReadFactory.build()


@pytest.fixture()
def group_user_read() -> GroupUserRead:
    return GroupUserReadFactory.build()


# Expense fixtures


@pytest.fixture()
def expense_model() -> ExpenseModel:
    return ExpenseModelFactory.build()


@pytest.fixture()
def expense_create() -> ExpenseCreate:
    return ExpenseCreateFactory.build()


# Expense item fixtures


@pytest.fixture()
def expense_item_model() -> ExpenseItemModel:
    return ExpenseItemModelFactory.build()


@pytest.fixture()
def expense_item_split_model() -> ExpenseItemSplitModel:
    return ExpenseItemSplitModelFactory.build()


# Audit fixtures


@pytest.fixture()
def audit_model() -> AuditModel:
    return AuditModelFactory.build()
