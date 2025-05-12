"""Expense Attachment Dependencies."""

from typing import Annotated

from api.src.expenseflow.expense_attachment.manager import (
    ExpenseAttachmentManager,
    InfileExpenseAttachmentManager,
)
from fastapi import Depends


def get_expense_attachment_manager() -> ExpenseAttachmentManager:
    """Get expense attachment manager."""
    return InfileExpenseAttachmentManager()


ExpenseManager = Annotated[
    ExpenseAttachmentManager, Depends(get_expense_attachment_manager)
]
