"""App config module."""

from pydantic import Field
from pydantic_settings import BaseSettings


class GeneralSettings(BaseSettings):
    """General app settings."""

    db_url: str = Field()


CONFIG = GeneralSettings()  # type: ignore[call-arg]
