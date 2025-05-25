"""Sentry plugin to enable performance monitoring and error tracing."""

from typing import Literal

import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

from expenseflow.plugin import Plugin, PluginSettings, plugin_registry


class SentryPluginSettings(PluginSettings):
    """Settings required for the sentry plugin."""

    sentry_dsn: str
    sentry_send_default_pii: bool = True

    sentry_traces_sample_rate: float = 1.0

    sentry_profile_session_sample_rate: float = 1.0
    sentry_profile_lifecycle: Literal["manual", "trace"] = "trace"


@plugin_registry.register("sentry")
class SentryPlugin(Plugin[SentryPluginSettings]):
    """Sentry plugin."""

    _settings_type = SentryPluginSettings

    def _on_init(self) -> None:
        """Init sentry plugin."""
        sentry_sdk.init(
            dsn=self._config.sentry_dsn,
            send_default_pii=self._config.sentry_send_default_pii,
            # Tracing
            traces_sample_rate=self._config.sentry_traces_sample_rate,
            # Profiling
            profile_session_sample_rate=self._config.sentry_profile_session_sample_rate,
            profile_lifecycle=self._config.sentry_profile_lifecycle,
            # Integrations
            integrations=[
                FastApiIntegration(
                    transaction_style="endpoint",
                ),
            ],
        )

    def _on_call(self, *args, **kwargs) -> None:  # noqa: ANN002, ANN003
        """Do this method on call."""

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""
