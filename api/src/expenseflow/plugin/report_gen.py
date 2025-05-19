"""Plugin to generate reports."""

from fastapi.responses import FileResponse

from expenseflow.auth.deps import CurrentUser
from expenseflow.database.deps import DbSession
from expenseflow.expense.service import get_expenses, get_uploaded_expenses
from expenseflow.plugin import Plugin, PluginSettings, register_plugin


@register_plugin("textract")
class TextractPlugin(Plugin[PluginSettings]):
    """Report generation plugin."""

    _settings_type = PluginSettings

    def _on_init(self) -> None:
        """Do this on init."""
        self._app.add_api_route(
            "/report",
            self.generate_report,
            methods=["GET"],
        )

    def _on_call(self, *args, **kwargs) -> None:  # noqa: ANN002, ANN003
        """Do this method on call."""

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""

    async def generate_report(self, db: DbSession, user: CurrentUser) -> FileResponse:
        """Route to generate reports for the user."""
        uploaded_expenses = await get_uploaded_expenses(db, user)
        expenses = await get_expenses(db, user)

        # Use these to generate the report

        return FileResponse("SOME_FILE_PATH")
