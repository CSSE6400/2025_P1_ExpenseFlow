"""Base schema information."""

import datetime as dt
from typing import Any, ClassVar

from pydantic import BaseModel


# Serialize datetime values to local format
def _serialize_datetime(v: dt.datetime) -> str:
    v = v.astimezone(tz=None)
    return v.strftime("%Y-%m-%dT%H:%M:%SZ")


class ExpenseFlowBase(BaseModel):
    """Base pydantic model."""

    class Config:
        """Pydantic config."""

        json_encoders: ClassVar[dict[type, Any | None]] = {
            dt.datetime: _serialize_datetime,
        }
