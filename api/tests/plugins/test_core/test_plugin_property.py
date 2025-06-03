"""Tests for plugin properties."""

import pytest
from expenseflow.plugin import PluginProperty


@pytest.mark.asyncio
async def test_plugin_property_static():
    pp = PluginProperty("Hello")
    val = await pp.to_value()
    assert val == "Hello"


@pytest.mark.asyncio
async def test_plugin_property_mixed(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setenv("DYNAMIC", "world")
    pp = PluginProperty("Hello {{env_DYNAMIC}}!")
    val = await pp.to_value()
    assert val == "Hello world!"
