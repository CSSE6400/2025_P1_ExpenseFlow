"""Enums module."""

from enum import Enum


class ExpenseFlowEnum(str, Enum):
    """Base enum."""


class EntityKind(ExpenseFlowEnum):
    """Enum for different entity kinds."""

    user = "user"
    group = "group"


class GroupRole(ExpenseFlowEnum):
    """Enum for group roles."""

    admin = "admin"
    user = "user"


class ExpenseCategory(ExpenseFlowEnum):
    """Enum for expense category."""

    takeaway = "takeaway"
    education = "education"
    entertainment = "entertainment"
    donations = "donations"
    groceries = "groceries"
    health = "health"
    home = "home"
    bills = "bills"
    insurance = "insurance"
    subscriptions = "subscriptions"
    transfers = "transfers"
    travel = "travel"
    utilities = "utilities"
    transport = "transport"
    other = "other"
    auto = "auto"


class FriendStatus(ExpenseFlowEnum):
    """Enum for friend status."""

    requested = "requested"
    accepted = "accepted"
