"""Factories module."""

from polyfactory.factories.pydantic_factory import ModelFactory

from expenseflow.user.schemas import UserCreateSchema, UserSchema


class UserFactory(ModelFactory[UserSchema]): ...


class UserCreateFactory(ModelFactory[UserCreateSchema]): ...
