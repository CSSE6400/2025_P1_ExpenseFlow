"""Expense Attachment Manager."""

from typing import BinaryIO, Protocol
from uuid import UUID


class ExpenseAttachmentManager(Protocol):
    """Async expense attachment manager interface."""

    async def upload_attachment(
        self, expense_id: UUID, attachment_name: str, expense_attachment: BinaryIO
    ) -> str:
        """Upload expense attachment."""

    async def download_attachment(self, attachment_id: str) -> BinaryIO | None:
        """Download expense attachment."""
