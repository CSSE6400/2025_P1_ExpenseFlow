"""Tests for plugin registry."""

import pytest
from expenseflow.plugin import Plugin, PluginRegistry, PluginSettings


class DummySettings(PluginSettings):  # noqa: D101
    foo: str = "bar"


class DummyPlugin(Plugin[DummySettings]):  # noqa: D101
    _settings_type = DummySettings

    def _on_call(self) -> str:
        return "called"

    def is_healthy(self):  # noqa: D102
        return True

    def _on_init(self) -> None:
        pass

    def shutdown(self):  # noqa: D102
        pass


def test_plugin_registry_register_and_get():
    registry = PluginRegistry()
    registry.register("dummy")(DummyPlugin)
    cls = registry.get_plugin("dummy")
    assert cls is DummyPlugin


def test_plugin_registry_duplicate():
    registry = PluginRegistry()
    registry.register("dummy")(DummyPlugin)
    with pytest.raises(AttributeError, match="already used by plugin"):
        registry.register("dummy")(DummyPlugin)


def test_plugin_registry_missing_settings_type():
    class IncompletePlugin(Plugin):
        def _on_call(self) -> None:
            pass

        def is_healthy(self) -> bool:
            return True

        def _on_init(self) -> None:
            pass

        def shutdown(self) -> None:
            pass

    registry = PluginRegistry()
    with pytest.raises(AttributeError, match="_settings_type"):
        registry.register("bad")(IncompletePlugin)
