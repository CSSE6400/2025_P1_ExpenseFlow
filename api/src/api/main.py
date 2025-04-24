"""Main module."""

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from fastapi import FastAPI


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncGenerator:
    """App lifespan."""
    yield


app = FastAPI(lifespan=lifespan)


@app.get("/api/v1/health")
async def get_health() -> dict:
    """Query the health of the service."""
    return {
        "status": "healthy",
    }
