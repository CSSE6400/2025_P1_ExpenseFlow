"""Test plugin module."""

from expenseflow.plugins import Plugin, PluginSettings, register_plugin


class TestPluginSettings(PluginSettings):
    """Test plugin settings."""

    print_value: str


@register_plugin("test_plugin")
class TestPlugin(Plugin[TestPluginSettings]):
    """Test plugin."""

    _settings_type = TestPluginSettings

    def _on_call(self) -> None:
        """Do this method on call."""

    def _on_init(self) -> None:
        print(  # noqa: T201
            f"This is the value from the test plugin: '{self._config.print_value}'",
        )

    def is_healthy(self) -> bool:
        """Check if plugin is healthy."""
        return True

    def shutdown(self) -> None:
        """Shutdown plugin."""
