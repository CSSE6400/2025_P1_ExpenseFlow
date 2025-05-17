"""Plugin to automatically turn a receipt into an expense."""

from uuid import UUID

import boto3
from fastapi import HTTPException, status, File, UploadFile

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.entity.service import get_entity
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseCreate, ExpenseRead  # noqa: F401
from expenseflow.expense.service import create_expense  # noqa: F401
from expenseflow.expense_item.schemas import ExpenseItemCreate  # noqa: F401
from expenseflow.plugin import Plugin, PluginSettings, register_plugin

import base64
from botocore.exceptions import ClientError


class TextractPluginSettings(PluginSettings):
    """Settings required for the textract plugin."""


@register_plugin("textract")
class TextractPlugin(Plugin[PluginSettings]):
    """Textract check plugin."""

    _settings_type = TextractPluginSettings

    from expenseflow.schemas import ExpenseFlowBase

    def _on_init(self) -> None:
        """Do this on init."""
        self.textract_client = boto3.client("textract")
        self._app.add_api_route(
            "/expenses/auto",
            self.handle_receipt,
            methods=["POST"],
            response_model=ExpenseRead,
        )
        # self.s3_connection = None

    def _on_call(self, *args, **kwargs) -> None:  # noqa: ANN002, ANN003
        """Do this method on call."""

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        # Do some check with boto3
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""
        # Close boto3 client

    async def handle_receipt(
        self, db: DbSession, user: CurrentUser, parent_id: UUID, file: UploadFile | None = None
    ) -> ExpenseModel:
        """Route to extract receipt info."""
        if not file:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="No file provided")
        contents = await file.read()
        bytes64 = base64.b64encode(contents)
        if (len(bytes64) > 5 * 1024 * 1024):
            raise HTTPException(status.HTTP_400_BAD_REQUEST, detail="File greater than 5MB")
        
        parent = await get_entity(db, parent_id)
        if parent is None:
            raise HTTPException(
                status.HTTP_404_NOT_FOUND,
                detail=f"Parent under the id '{parent_id}' could not be found",
            )
        try:
            response = self.textract_client.analyze_expense(
                Document={
                    'Bytes': contents
                }
            )
        except ClientError as e:
            error_code = e.response['Error']['Code']
            error_message = e.response['Error']['Message']

            if error_code == 'UnsupportedDocumentException':
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST,
                    detail="Unsupported document format. Please upload a PNG or JPEG image."
                )
            else:
                raise HTTPException(
                    status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Textract error: {error_message}"
                )

        # Do some crazy analysis stuff

        # expense_in = ExpenseCreate(........)
        # return await create_expense(db, user, expense_in, parent)
