"""Factories module."""

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
from polyfactory.factories.pydantic_factory import ModelFactory
from polyfactory.factories.sqlalchemy_factory import SQLAlchemyFactory


# Users
class UserModelFactory(SQLAlchemyFactory[UserModel]): ...


class UserReadFactory(ModelFactory[UserRead]): ...


class UserCreateFactory(ModelFactory[UserCreate]): ...


class UserCreateInternalFactory(ModelFactory[UserCreateInternal]): ...


# Groups
class GroupModelFactory(SQLAlchemyFactory[GroupModel]): ...


class GroupCreateFactory(ModelFactory[GroupCreate]): ...


class GroupUpdateFactory(ModelFactory[GroupUpdate]): ...


class GroupReadFactory(ModelFactory[GroupRead]): ...


# Groups user membership
class GroupUserModelFactory(SQLAlchemyFactory[GroupUserModel]): ...


class UserGroupReadFactory(ModelFactory[UserGroupRead]): ...


class GroupUserReadFactory(ModelFactory[GroupUserRead]): ...
