"""Enums module."""

from enum import Enum


class ExpenseFlowEnum(str, Enum):
    """Base enum."""


class EntityKind(ExpenseFlowEnum):
    """Enum for different entity kinds."""

    user = "user"
    group = "group"
