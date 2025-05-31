"""S3 Attachment Plugin Module. This module could be extended to store attachments using other services."""

from uuid import UUID
import boto3
from botocore.exceptions import ClientError
from expenseflow.expense.schemas import ExpenseRead
from fastapi import HTTPException, UploadFile, status
from expenseflow.entity.service import get_entity

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.plugin import Plugin, PluginSettings, plugin_registry


class S3AttachmentPluginSettings(PluginSettings):
    """Settings required for the s3 attachment plugin."""



@plugin_registry.register("s3_attachment")
class S3AttachmentPlugin(Plugin[S3AttachmentPluginSettings]):
    """S3 Attachment check plugin."""

    _settings_type = S3AttachmentPluginSettings

    from expenseflow.schemas import ExpenseFlowBase

    def _on_init(self) -> None:
        """Do this on init."""
        self.s3_client = boto3.client("s3", region_name="us-east-1")
        response = self.s3_client.list_buckets()
        if not response['Buckets']:
            print("no buckets")
            self.create_bucket("Attachments")
        else:
            print("yes buckets")
        self._app.add_api_route(
            "/expenses/attach",
            self.attach,
            methods=["POST"],
            response_model=ExpenseRead,
        )

    def _on_call(self) -> None:
        """Do this method on call."""

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        # Do some check with boto3
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""

    def create_bucket(self, bucket_name):
        try:
            location = {'LocationConstraint': "us-east-1"}
            self.s3_client.create_bucket(Bucket=bucket_name, CreateBucketConfiguration=location)
        except ClientError as e:
            error_message = e.response["Error"]["Message"]
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Creating bucket error: {error_message}"
            ) from e

    async def attach(
            self,
            file: UploadFile,
            expense_id: UUID | None = None):
        if expense_id is None:
            raise HTTPException(
                status.HTTP_404_NOT_FOUND,
                detail=f"Expense under the id '{expense_id}' could not be found",
            )
        try:
            # I think this will mean that we can only attach 1 attachment for 
            # each expense - I think that's fine for MVP
            self.s3_client.upload_fileobj(file.file, "Attachments", expense_id)
        except ClientError as e:
            error_message = e.response["Error"]["Message"]
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Attaching item error: {error_message}"
            ) from e
        
    async def retrieve(
            self,
            expense_id: UUID | None = None):
        if expense_id is None:
            raise HTTPException(
                status.HTTP_404_NOT_FOUND,
                detail=f"Expense under the id '{expense_id}' could not be found",
            )
        try:
            self.s3_client.download_file("Attachments", 
                                         expense_id, 
                                         f"{expense_id}.png")
        except ClientError as e:
            if e.response['Error']['Code'] == "NoSuchKey":
                raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Could not find item error: " +
                            f"{e.response["Error"]["Message"]}"
                ) from e
        try:
            with open(f"{expense_id}.png", "r") as file:
                return file.read()
        except:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Could read downloaded file, {expense_id}.png"
                ) from e