"""Tests for dynamic plugin values."""

import pytest
from expenseflow.plugin import DynamicValue, EnvironmentDynamicValue


@pytest.mark.asyncio
async def test_environment_dynamic_value(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setenv("TEST_ENV_VAR", "123")
    dv = EnvironmentDynamicValue("TEST_ENV_VAR")
    assert await dv.get_value() == "123"


@pytest.mark.asyncio
async def test_environment_dynamic_value_missing(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.delenv("MISSING_VAR", raising=False)
    dv = EnvironmentDynamicValue("MISSING_VAR")
    val = await dv.get_value()
    assert val == ""


@pytest.mark.asyncio
async def test_dynamic_value_factory_env(monkeypatch: pytest.MonkeyPatch):
    monkeypatch.setenv("FOO", "bar")
    dv = DynamicValue.create("env_FOO")
    assert isinstance(dv, EnvironmentDynamicValue)
    assert await dv.get_value() == "bar"
