"""App config module."""

from pydantic import Field
from pydantic_settings import BaseSettings


class GeneralSettings(BaseSettings):
    """General app settings."""

    db_url: str = Field()
    jwt_audience: str = Field()
    auth0_domain: str = Field()
    plugin_config_path: str = Field(default="plugin_config.yml")


CONFIG = GeneralSettings()  # type: ignore[call-arg]
