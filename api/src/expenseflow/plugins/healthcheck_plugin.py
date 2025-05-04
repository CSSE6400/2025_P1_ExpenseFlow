"""Healthcheck plugin module."""

from typing import Literal

from expenseflow.plugins import Plugin, PluginSettings, register_plugin


@register_plugin("healthcheck")
class HealthCheckPlugin(Plugin[PluginSettings]):
    """Health check plugin."""

    _settings_type = PluginSettings

    from expenseflow.models import ExpenseFlowBase

    class HealthCheckModel(ExpenseFlowBase):
        """Response body for health check."""

        status: Literal["healthy"]

    def _on_call(self) -> None:
        """Do this method on call."""

    def _on_init(self) -> None:
        async def get_health() -> HealthCheckPlugin.HealthCheckModel:
            """Query the health of the service."""
            return HealthCheckPlugin.HealthCheckModel(status="healthy")

        self._app.add_api_route("/api/v1/health", get_health, methods=["GET"])

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""
