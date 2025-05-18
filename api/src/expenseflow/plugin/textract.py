"""Plugin to automatically turn a receipt into an expense."""

import base64
from uuid import UUID

import boto3
from botocore.exceptions import ClientError
from fastapi import File, HTTPException, UploadFile, status

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.entity.service import get_entity
from expenseflow.enums import ExpenseCategory
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseCreate, ExpenseRead
from expenseflow.expense.service import create_expense
from expenseflow.expense_item.schemas import ExpenseItemCreate
from expenseflow.plugin import Plugin, PluginSettings, register_plugin


class TextractPluginSettings(PluginSettings):
    """Settings required for the textract plugin."""


@register_plugin("textract")
class TextractPlugin(Plugin[TextractPluginSettings]):
    """Textract check plugin."""

    _settings_type = TextractPluginSettings

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
        self, db: DbSession, user: CurrentUser, parent_id: UUID, file: UploadFile
    ) -> ExpenseModel:
        """Route to extract receipt info."""
        contents = await file.read()
        bytes64 = base64.b64encode(contents)
        if len(bytes64) > 5 * 1024 * 1024:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, detail="File greater than 5MB"
            )

        parent = await get_entity(db, parent_id)
        if parent is None:
            raise HTTPException(
                status.HTTP_404_NOT_FOUND,
                detail=f"Parent under the id '{parent_id}' could not be found",
            )
        try:
            response = self.textract_client.analyze_expense(
                Document={"Bytes": contents}
            )
        except ClientError as e:
            error_code = e.response["Error"]["Code"]
            error_message = e.response["Error"]["Message"]

            if error_code == "UnsupportedDocumentException":
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST,
                    detail="Unsupported document format. Please upload a PNG or JPEG image.",
                ) from e
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Textract error: {error_message}",
            ) from e
        summary_fields = response["ExpenseDocuments"][0].get("SummaryFields", [])
        item_groups = response["ExpenseDocument"][0].get("LineItemGroups", [])
        vendor_name = ""
        items: list[ExpenseItemCreate] = []
        for field in summary_fields:
            if field["Type"]["Text"] == "VENDOR_NAME":
                vendor_name = field.get("Value", "")
                break
        for item_list in item_groups:
            for item in item_list.get("LineItems", []):
                item_name = "Name not detected"
                item_quantity = -1
                item_price = -1.0
                for field in item.get("LineItemExpenseFields", []):
                    field_type = field.get("Type", []).get("Text", [])
                    if field_type == "ITEM":
                        item_name = field.get("ValueDetection", {}).get("Text")
                    elif field_type == "QUANTITY":
                        item_quantity = int(field.get("ValueDetection", {}).get("Text"))
                    elif field_type == "UNIT_PRICE":
                        item_price = float(field.get("ValueDetection", {}).get("Text"))

                items.append(
                    ExpenseItemCreate(
                        name=item_name, quantity=item_quantity, price=item_price
                    )
                )

        description = f"Auto-generated expense from receipt from {vendor_name}."
        expense_in = ExpenseCreate(
            name=vendor_name,
            description=description,
            category=ExpenseCategory.auto,
            items=items,
        )
        return await create_expense(db, user, expense_in, parent)
