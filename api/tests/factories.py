"""Factories module."""

from expenseflow.enums import EntityKind
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
from polyfactory.pytest_plugin import register_fixture


# Users
@register_fixture
class UserModelFactory(SQLAlchemyFactory[UserModel]):
    kind = EntityKind.user


class UserReadFactory(ModelFactory[UserRead]): ...


class UserCreateFactory(ModelFactory[UserCreate]): ...


class UserCreateInternalFactory(ModelFactory[UserCreateInternal]): ...


# Groups
@register_fixture
class GroupModelFactory(SQLAlchemyFactory[GroupModel]):
    group = EntityKind.group


class GroupCreateFactory(ModelFactory[GroupCreate]): ...


class GroupUpdateFactory(ModelFactory[GroupUpdate]): ...


class GroupReadFactory(ModelFactory[GroupRead]): ...


# Groups user membership
@register_fixture
class GroupUserModelFactory(SQLAlchemyFactory[GroupUserModel]): ...


class UserGroupReadFactory(ModelFactory[UserGroupRead]): ...


class GroupUserReadFactory(ModelFactory[GroupUserRead]): ...
