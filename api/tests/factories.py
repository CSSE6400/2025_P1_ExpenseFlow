"""Factories module."""

from expenseflow.user.schemas import UserCreateSchema, UserSchema
from polyfactory.factories.pydantic_factory import ModelFactory


class UserFactory(ModelFactory[UserSchema]): ...


class UserCreateFactory(ModelFactory[UserCreateSchema]): ...
