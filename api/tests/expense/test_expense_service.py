"""Expense Service Tests."""

from enum import Enum

import pytest
from expenseflow.enums import ExpenseStatus
from expenseflow.errors import InvalidStateError
from expenseflow.expense.service import is_valid_expense_change


class _TestResult(Enum):
    true = 1
    false = 2
    invalid_state = 3


r = ExpenseStatus.requested
a = ExpenseStatus.accepted
p = ExpenseStatus.paid

t = _TestResult.true
f = _TestResult.false
i = _TestResult.invalid_state


@pytest.mark.parametrize(
    (
        "user_input",
        "current_user_status",
        "current_expense_status",
        "outcome",
    ),
    [
        # R combos
        (r, r, r, t),
        (r, r, a, i),
        (r, r, p, i),
        (r, a, r, t),
        (r, a, a, f),
        (r, a, p, i),
        (r, p, r, i),
        (r, p, a, f),
        (r, p, p, f),
        # A combos
        (a, r, r, t),
        (a, r, a, i),
        (a, r, p, i),
        (a, a, r, t),
        (a, a, a, t),
        (a, a, p, i),
        (a, p, r, i),
        (a, p, a, t),
        (a, p, p, f),
        # P combos
        (p, r, r, f),
        (p, r, a, i),
        (p, r, p, i),
        (p, a, r, f),
        (p, a, a, t),
        (p, a, p, i),
        (p, p, r, i),
        (p, p, a, t),
        (p, p, p, t),
    ],
)
def test_is_valid_expense_change(
    user_input: ExpenseStatus,
    current_user_status: ExpenseStatus,
    current_expense_status: ExpenseStatus,
    outcome: _TestResult,
):
    if outcome == _TestResult.true:  # Is valid state change
        assert (
            is_valid_expense_change(
                user_input, current_user_status, current_expense_status
            )
            is True
        )
    elif outcome == _TestResult.false:  # Not valid state change
        assert (
            is_valid_expense_change(
                user_input, current_user_status, current_expense_status
            )
            is False
        )
    elif outcome == _TestResult.invalid_state:  # Invalid state to begin with
        with pytest.raises(InvalidStateError):
            is_valid_expense_change(
                user_input, current_user_status, current_expense_status
            )
    else:
        raise Exception  # noqa: TRY002
