"""Plugins core module. This contains all core classes used by other plugins."""

import importlib
import pkgutil
from abc import ABC, abstractmethod
from collections.abc import Callable
from pathlib import Path
from typing import Any, ClassVar, Generic, Self, TypeVar

import yaml
from fastapi import FastAPI
from loguru import logger
from pydantic import BaseModel


class PluginError(Exception):
    """Base plugin error."""


class PluginSettings(BaseModel):
    """Settings for each plugin."""


SettingsType = TypeVar("SettingsType", bound=PluginSettings)


class Plugin(ABC, Generic[SettingsType]):
    """Base plugin class."""

    _app: FastAPI
    _settings: SettingsType
    _settings_type: type[SettingsType]

    def __init__(self, app: FastAPI, config: SettingsType) -> None:
        """Create plugin."""
        self._app = app
        self._config = config

        self._on_init()

    def __call__(self, *args, **kwargs):  # noqa: ANN002, ANN003, ANN204
        """Call method."""
        return self._on_call(*args, **kwargs)

    @classmethod
    def get_settings_type(cls) -> type[SettingsType]:
        """Get type of plugin settings."""
        return cls._settings_type

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
    _config: dict[str, Any]
    _plugins: list[Plugin]

    def __init__(self, config: dict[str, Any]) -> None:
        """Construct plugin registry."""
        self._config = config
        self._plugins = []

    @classmethod
    def create_from_config_file(cls, config_file_path: str) -> Self:
        """Create a plugin registry from a config file path."""
        file_path = Path(config_file_path)
        try:
            with file_path.open("r") as f:
                config = yaml.safe_load(f)
        except OSError as e:
            msg = f"Failed to retrieve plugin config from '{config_file_path}'"
            raise PluginError(msg) from e
        for plugin_name, plugin_config in config.items():
            if type(plugin_config) is not dict and type(plugin_config) is not None:
                msg = f"Config for plugin '{plugin_name}' is invalid: {plugin_config}"
                raise PluginError(msg)
        return cls(config)

    def start_plugins(
        self,
        app: FastAPI,
        strict: bool = True,  # noqa: FBT001, FBT002
    ) -> None:
        """Start plugins in config."""
        for plugin_name, config_data in self._config.items():
            plugin_cls = self._registry.get(plugin_name, None)
            if plugin_cls is None:
                msg = (
                    f"Config file references plugin under name '{plugin_name}'",
                    " which does not exist in plugin registry.",
                )
                logger.warning(msg)
                if strict:
                    raise PluginError(msg)
                continue

            plugin_settings_cls = plugin_cls.get_settings_type()

            plugin = plugin_cls(
                app,
                plugin_settings_cls.model_validate(
                    config_data if config_data is not None else {},
                ),
            )

            self._plugins.append(plugin)

    def stop_plugins(self) -> None:
        """Stop active plugins."""
        for plugin in self._plugins:
            plugin.shutdown()

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
    logger.debug(f"Registering plugin under name '{name}'")

    def wrapper(cls: type[Plugin[PluginSettings]]) -> type[Plugin[PluginSettings]]:
        if not hasattr(cls, "_settings_type"):
            msg = f"Plugin class {cls.__name__} must define '_settings_type'"
            raise AttributeError(msg)

        PluginRegistry.register(name, cls)
        return cls

    return wrapper


# Auto-import all plugin modules to ensure they get registered

# Only run when base.py is imported as part of the app, not when running in isolation
if __name__ != "__main__":
    for module_info in pkgutil.iter_modules(__path__):
        if module_info.name != "base":
            importlib.import_module(f"{__package__}.{module_info.name}")
            logger.debug(f"Auto-imported plugin module: {module_info.name}")
