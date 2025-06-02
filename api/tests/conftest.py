"""Config file to provide fixtures for test directory."""

import asyncio
import os
from collections.abc import AsyncGenerator

import pytest
import pytest_asyncio
from expenseflow.database.service import initialise_database
from expenseflow.group.models import GroupModel, GroupUserModel
from expenseflow.group.schemas import (
    GroupCreate,
    GroupRead,
    GroupUpdate,
    GroupUserRead,
    UserGroupRead,
)
from expenseflow.user.models import UserModel
from expenseflow.user.schemas import UserCreate, UserCreateInternal, UserRead
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
    GroupCreateFactory,
    GroupModelFactory,
    GroupReadFactory,
    GroupUpdateFactory,
    GroupUserModelFactory,
    GroupUserReadFactory,
    UserCreateFactory,
    UserCreateInternalFactory,
    UserGroupReadFactory,
    UserModelFactory,
    UserReadFactory,
)


# Test DB URL
TEST_DB_URL = "postgresql+asyncpg://admin:password@localhost:5432/expense_db"
SYNC_TEST_DB_URL = "postgresql://admin:password@localhost:5432/expense_db"

# Set environment variables
os.environ["FRONTEND_URL"] = ""
os.environ["DB_URL"] = TEST_DB_URL
os.environ["JWT_AUDIENCE"] = ""
os.environ["AUTH0_DOMAIN"] = ""

# Create test engine
test_engine: AsyncEngine = create_async_engine(
    TEST_DB_URL,
    pool_pre_ping=True,
)

# Use pytest-asyncio's built-in event_loop (default is function-scoped)
# Do NOT override unless necessary
# If you need session-scoped event_loop, use this:
# @pytest.fixture(scope="session")
# def event_loop():
#     loop = asyncio.get_event_loop()
#     yield loop


# Database setup
@pytest.fixture(scope="session")
def test_app() -> FastAPI:
    from expenseflow.main import app
    return app


@pytest.fixture(scope="session")
def db_url() -> str:
    return TEST_DB_URL


@pytest_asyncio.fixture(scope="function")
async def db() -> AsyncGenerator[None]:
    """Database fixture."""
    if database_exists(SYNC_TEST_DB_URL):
        logger.warning(f"Already found db at {SYNC_TEST_DB_URL}. Dropping now...")
        drop_database(SYNC_TEST_DB_URL)

    # Create fresh new one
    create_database(SYNC_TEST_DB_URL)

    await initialise_database(test_engine)
    yield


@pytest_asyncio.fixture(scope="function")
async def session(db) -> AsyncGenerator[AsyncSession, None]:
    async_session_factory = async_sessionmaker(
        test_engine, class_=AsyncSession, expire_on_commit=False
    )

    async with async_session_factory() as session:
        yield session
        await session.rollback()


@pytest_asyncio.fixture(scope="function")
async def test_client(test_app: FastAPI, session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    from expenseflow.auth.deps import get_current_user, get_user_token_identifier
    from expenseflow.database.deps import get_db

    test_app.dependency_overrides[get_current_user] = lambda: UserModelFactory.build()
    test_app.dependency_overrides[get_user_token_identifier] = lambda: "token_id"
    test_app.dependency_overrides[get_db] = lambda: session

    async with AsyncClient(transport=ASGITransport(app=test_app), base_url="http://test") as client:
        yield client


# Factories
from tests.factories import (
    GroupModelFactory,
    GroupUserModelFactory,
    UserCreateFactory,
    UserCreateInternalFactory,
    UserModelFactory,
    UserReadFactory,
)

register_fixture(UserModelFactory)
register_fixture(GroupModelFactory)
register_fixture(GroupUserModelFactory)

# Fixtures
@pytest.fixture(scope="session")
def default_user() -> UserModel:
    return UserModelFactory.build()

@pytest.fixture()
def user_create() -> UserCreate:
    return UserCreateFactory.build()

@pytest.fixture()
def user_read() -> UserRead:
    return UserReadFactory.build()

@pytest.fixture()
def user_create_internal() -> UserCreateInternal:
    return UserCreateInternalFactory.build()
