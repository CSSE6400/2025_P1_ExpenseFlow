"""Factories module."""

import random

from expenseflow.enums import EntityKind
from expenseflow.expense.models import (
    ExpenseItemModel,
    ExpenseItemSplitModel,
    ExpenseModel,
)
from expenseflow.expense.schemas import (
    ExpenseCreate,
    ExpenseItemCreate,
    ExpenseItemSplitCreate,
    SplitStatusInfo,
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
from polyfactory import Use
from polyfactory.factories.pydantic_factory import ModelFactory
from polyfactory.factories.sqlalchemy_factory import SQLAlchemyFactory


# Users
class UserModelFactory(SQLAlchemyFactory[UserModel]):
    kind = EntityKind.user


class UserCreateFactory(ModelFactory[UserCreate]): ...


class UserCreateInternalFactory(ModelFactory[UserCreateInternal]): ...


# Groups
class GroupModelFactory(SQLAlchemyFactory[GroupModel]):
    group = EntityKind.group


class GroupCreateFactory(ModelFactory[GroupCreate]): ...


class GroupUpdateFactory(ModelFactory[GroupUpdate]): ...


# Groups user membership
class GroupUserModelFactory(SQLAlchemyFactory[GroupUserModel]): ...


class UserGroupReadFactory(ModelFactory[UserGroupRead]): ...


class GroupUserReadFactory(ModelFactory[GroupUserRead]): ...


# Expenses item splits
class ExpenseItemSplitModelFactory(SQLAlchemyFactory[ExpenseItemSplitModel]): ...


class ExpenseItemSplitCreateFactory(ModelFactory[ExpenseItemSplitCreate]):
    """Generate splits with correct proportions."""

    @classmethod
    def generate_splits(cls, n: int = 2) -> list[ExpenseItemSplitCreate]:  # noqa: D102
        raw_weights = [random.random() for _ in range(n)]  # noqa: S311
        total = sum(raw_weights)
        proportions = [w / total for w in raw_weights]

        return [cls.build(proportion=round(p, 4)) for p in proportions]


class SplitStatusInfoFactory(ModelFactory[SplitStatusInfo]): ...


# Expense items


class ExpenseItemModelFactory(SQLAlchemyFactory[ExpenseItemModel]): ...


class ExpenseItemCreateFactory(ModelFactory[ExpenseItemCreate]):
    splits = Use(ExpenseItemSplitCreateFactory.generate_splits, n=2)


# Expenses
class ExpenseModelFactory(SQLAlchemyFactory[ExpenseModel]): ...


class ExpenseCreateFactory(ModelFactory[ExpenseCreate]):
    items = Use(ExpenseItemCreateFactory.batch, size=3)
