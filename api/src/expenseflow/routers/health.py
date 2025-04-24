"""Health router."""

from typing import Literal

from fastapi import APIRouter

from expenseflow.models import ExpenseFlowBase

r = router = APIRouter()


class HealthCheckModel(ExpenseFlowBase):
    """Response body for health check."""

    status: Literal["healthy"]


@r.get("")
async def get_health() -> HealthCheckModel:
    """Query the health of the service."""
    return HealthCheckModel(status="healthy")
