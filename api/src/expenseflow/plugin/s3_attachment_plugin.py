"""S3 Attachment Plugin Module."""

from expenseflow.plugin import Plugin, PluginSettings, plugin_registry


class S3AttachmentPluginSettings(PluginSettings):
    """Settings required for the s3 attachment plugin."""


@plugin_registry.register("s3_attachment")
class S3AttachmentPlugin(Plugin[S3AttachmentPluginSettings]):
    """S3 Attachment check plugin."""

    _settings_type = S3AttachmentPluginSettings

    from expenseflow.schemas import ExpenseFlowBase

    def _on_call(self) -> None:
        """Do this method on call."""

    def _on_init(self) -> None:
        """Do this on init."""

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""
