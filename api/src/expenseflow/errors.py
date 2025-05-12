"""Exceptions Module."""


class ExpenseFlowError(Exception):
    """Base expense flow error."""


class ExistsError(ExpenseFlowError):
    """Error raised when something already exists."""


class RoleError(ExpenseFlowError):
    """Error raised when a user doesn't have the required roles for something."""
