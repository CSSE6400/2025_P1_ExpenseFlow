"""Exceptions Module."""

from uuid import UUID


class ExpenseFlowError(Exception):
    """Base expense flow error."""

    def __init__(self, message: str) -> None:  # noqa: D107
        self.message = message
        super().__init__(message)


class ExistsError(ExpenseFlowError):
    """Error raised when something already exists."""


class NotFoundError(ExpenseFlowError):
    """Error raised when something can't be found."""

    def __init__(self, identifier: UUID, name: str) -> None:  # noqa: D107
        super().__init__(f"The {name} under id '{identifier}' cannot be found.")


class RoleError(ExpenseFlowError):
    """Error raised when a user doesn't have the required roles for something."""
