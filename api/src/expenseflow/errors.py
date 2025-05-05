"""Exceptions Module."""


class ExpenseFlowError(Exception):
    """Base expense flow error."""


class ExistsError(ExpenseFlowError):
    """Error raised when something already exists."""
