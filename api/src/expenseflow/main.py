"""Main module."""

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from expenseflow.database import initialise_database
from expenseflow.routers import base_router


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncGenerator:
    """App lifespan."""
    await initialise_database()  # Creates tables in db if not already there
    yield


app = FastAPI(lifespan=lifespan)
app.include_router(base_router, prefix="/api/v1")
