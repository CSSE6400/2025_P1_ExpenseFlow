"""Plugins core module. This contains all core classes used by other plugins."""

# Will need to work on a plugin 'registry' and also some abstract base classes for plugins.


from abc import ABC, abstractmethod
from collections.abc import Callable
from typing import Any, ClassVar, Generic, TypeVar

import pydantic_settings
from fastapi import FastAPI


class PluginError(Exception):
    """Base plugin error."""


class PluginSettings(pydantic_settings.BaseSettings):
    """Settings for each plugin."""

    # Maybe do something with yaml???
    model_config = pydantic_settings.SettingsConfigDict(
        env_prefix="",
        use_enum_values=True,
    )


SettingsType = TypeVar("SettingsType", bound=PluginSettings)


class Plugin(ABC, Generic[SettingsType]):
    """Base plugin class."""

    _app: FastAPI
    _settings: SettingsType

    def __init__(self, app: FastAPI, config: SettingsType) -> None:
        """Create plugin."""
        self._app = app
        self._config = config

        self._on_init()

    def __call__(self, *args, **kwargs):  # noqa: ANN002, ANN003, ANN204, D102
        return self._on_call(*args, **kwargs)

    @abstractmethod
    def _on_call(self) -> Any:  # noqa: ANN401
        """Call the plugin."""

    @abstractmethod
    def is_healthy(self) -> bool:
        """Determine whether plugin is healthy."""

    @abstractmethod
    def _on_init(self) -> None:
        """Initialise the plugin."""

    @abstractmethod
    def shutdown(self) -> None:
        """Shutdown the plugin."""


class PluginRegistry:
    """Plugin registry."""

    _registry: ClassVar[dict[str, type[Plugin[PluginSettings]]]] = {}

    @classmethod
    def register(cls, name: str, plugin_cls: type[Plugin[PluginSettings]]) -> None:
        """Register plugin."""
        cls._registry[name] = plugin_cls

    @classmethod
    def get(cls, name: str) -> type[Plugin[PluginSettings]]:
        """Get plugin."""
        return cls._registry[name]


def register_plugin(name: str) -> Callable:
    """Register plugin decorator."""

    def wrapper(cls: type[Plugin[PluginSettings]]) -> type[Plugin[PluginSettings]]:
        PluginRegistry.register(name, cls)
        return cls

    return wrapper
