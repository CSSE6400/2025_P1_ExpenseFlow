import boto3

from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.entity.models import EntityModel
from expenseflow.expense.models import ExpenseModel
from expenseflow.expense.schemas import ExpenseCreate
from expenseflow.expense_item.models import ExpenseItemModel
from expenseflow.user.models import UserModel

"""Textract module for image recognition"""

from expenseflow.plugin import Plugin, PluginSettings, register_plugin

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
        # self._app.add_api_route("/textract", )
        # self.s3_connection = None

    def _on_call(self, *args, **kwargs) -> None:
        """Do this method on call."""

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""
        pass