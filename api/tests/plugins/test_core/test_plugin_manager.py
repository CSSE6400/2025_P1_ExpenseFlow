"""Tests for plugin manager."""

import pathlib

import pytest
from expenseflow.plugin import (
    Plugin,
    PluginError,
    PluginManager,
    PluginRegistry,
    PluginSettings,
)
from fastapi import FastAPI


class DummySettings(PluginSettings):  # noqa: D101
    foo: str = "bar"


class DummyPlugin(Plugin[DummySettings]):  # noqa: D101
    _settings_type = DummySettings
    _initialized = False
    _called = False

    def _on_call(self) -> None:
        self._called = True

    def is_healthy(self):  # noqa: D102
        return True

    def _on_init(self) -> None:
        self._initialized = True

    def shutdown(self):  # noqa: D102
        self._called = False


@pytest.mark.asyncio
async def test_plugin_manager_lifecycle(tmp_path: pathlib.Path):

    file = tmp_path / "plugins.yaml"
    file.write_text("dummy:\n  foo: 'bar'")

    registry = PluginRegistry()
    registry.register("dummy")(DummyPlugin)

    manager = PluginManager.create_from_config_file(str(file), registry)
    await manager.start_plugins(FastAPI())

    await manager.call_plugins(lambda p: True)
    await manager.stop_plugins()

    # Ensure plugin was initialized and shut down properly
    assert isinstance(manager._plugins[0], DummyPlugin)  # noqa: SLF001
    assert not manager._plugins[0]._called  # shut down reset the flag  # noqa: SLF001


@pytest.mark.asyncio
async def test_plugin_manager_strict_missing_plugin():
    registry = PluginRegistry()
    manager = PluginManager({"unknown": {}}, registry)

    with pytest.raises(PluginError, match="does not exist in plugin registry"):
        await manager.start_plugins(FastAPI(), strict=True)
