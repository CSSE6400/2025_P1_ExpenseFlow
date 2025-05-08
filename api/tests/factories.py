"""Factories module."""

from expenseflow.user.models import UserModel  # noqa: I001
from expenseflow.group.models import GroupModel, GroupUserModel  # noqa: F401
from expenseflow.user.schemas import UserCreate, UserRead
from polyfactory.factories.pydantic_factory import ModelFactory
from polyfactory.factories.sqlalchemy_factory import SQLAlchemyFactory


# Users
class UserModelFactory(SQLAlchemyFactory[UserModel]): ...


class UserReadFactory(ModelFactory[UserRead]): ...


class UserCreateFactory(ModelFactory[UserCreate]): ...
