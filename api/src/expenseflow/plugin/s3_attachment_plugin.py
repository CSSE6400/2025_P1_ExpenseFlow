"""S3 Attachment Plugin Module. This module could be extended to store attachments using other services."""

from uuid import UUID

import boto3
from botocore.exceptions import ClientError
from fastapi import HTTPException, UploadFile, status
from fastapi.responses import FileResponse
from loguru import logger
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
)

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseRead
from expenseflow.expense.service import get_expense
from expenseflow.plugin import Plugin, PluginSettings, plugin_registry


class S3AttachmentPluginSettings(PluginSettings):
    """Settings required for the s3 attachment plugin."""

    bucket_name: str


@plugin_registry.register("s3_attachment")
class S3AttachmentPlugin(Plugin[S3AttachmentPluginSettings]):
    """S3 Attachment check plugin."""

    _settings_type = S3AttachmentPluginSettings
    _db_engine: AsyncEngine
    _session_factory: async_sessionmaker[AsyncSession]

    from expenseflow.schemas import ExpenseFlowBase

    def _on_init(self) -> None:
        """Do this on init."""
        logger.success("Initialising database was successful.")

        self.s3_client = boto3.client("s3", region_name="us-east-1")
        response = self.s3_client.list_buckets()
        buckets = response["Buckets"]
        logger.debug(response)

        found = False
        for b in buckets:
            if b.get("Name", None) == self._config.bucket_name:
                found = True

        if not found:
            logger.debug("Bucket doesn't exist")
            self.create_bucket(self._config.bucket_name)
        else:
            logger.debug("Bucket exists")

        self._app.add_api_route(
            "/expenses/{expense_id}/attach",
            self.attach,
            methods=["POST"],
            response_model=ExpenseRead,
        )

        self._app.add_api_route(
            "/expenses/{expense_id}/attach",
            self.retrieve,
            methods=["GET"],
        )

    def _on_call(self) -> None:
        """Do this method on call."""

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""

    def create_bucket(self, bucket_name: str) -> None:
        """Create bucket."""
        try:
            self.s3_client.create_bucket(Bucket=bucket_name)
        except ClientError as e:
            error_message = e.response["Error"]["Message"]
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Creating bucket error: {error_message}",
            ) from e

    async def attach(
        self, file: UploadFile, user: CurrentUser, expense_id: UUID, db: DbSession
    ) -> ExpenseModel:
        """Add attachment to expense."""
        expense = await get_expense(db, user, expense_id)

        if expense is None:
            raise HTTPException(
                status.HTTP_404_NOT_FOUND,
                detail=f"Expense under the id '{expense_id}' could not be found",
            )
        try:
            # I think this will mean that we can only attach 1 attachment for
            # each expense - I think that's fine for MVP
            self.s3_client.upload_fileobj(
                file.file, self._config.bucket_name, f"{expense_id!s}-{file.filename}"
            )
        except ClientError as e:
            error_message = e.response["Error"]["Message"]
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Attaching item error: {error_message}",
            ) from e
        return expense

    def get_objects(self, expense_id: UUID) -> list[dict]:
        """Get objects."""
        objects_response = self.s3_client.list_objects(
            Bucket=self._config.bucket_name, Prefix=str(expense_id)
        )
        contents = objects_response.get("Contents", [])
        return [
            {
                "Key": c.get("Key"),
                "ETag": c.get("ETag"),
                "LastModifiedTime": c.get("LastModified"),
                "Size": c.get("Size"),
            }
            for c in contents
        ]

    async def retrieve(
        self, user: CurrentUser, expense_id: UUID, db: DbSession
    ) -> FileResponse:
        """Retrieve attachment for expense."""
        expense = await get_expense(db, user, expense_id)

        if expense is None:
            raise HTTPException(
                status.HTTP_404_NOT_FOUND,
                detail=f"Expense under the id '{expense_id}' could not be found",
            )

        try:
            contents = self.get_objects(expense_id)
            if len(contents) == 0:
                raise HTTPException(
                    status.HTTP_404_NOT_FOUND,
                    detail=(
                        f"Could not find attachment under the expense '{expense_id}'"
                    ),
                )
            key = contents[0]["Key"]
            self.s3_client.download_file(self._config.bucket_name, key, f"/tmp/{key}")
        except ClientError as e:
            logger.error(e)
            if e.response["Error"]["Code"] == "NoSuchKey":
                raise HTTPException(
                    status.HTTP_404_NOT_FOUND,
                    detail=(
                        f"Could not find attachment under the expense '{expense_id}'"
                    ),
                ) from e
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=("INTERNAL SERVER ERROR"),
            ) from e

        return FileResponse(f"/tmp/{key}")
