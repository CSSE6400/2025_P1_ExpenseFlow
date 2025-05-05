"""Main module."""

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from expenseflow.config import CONFIG
from expenseflow.database.core import initialise_database
from expenseflow.expense.routes import router as expense_router
from expenseflow.plugin import PluginRegistry


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator:
    """App lifespan."""
    await initialise_database()  # Creates tables in db if not already there
    plugins_reg = PluginRegistry.create_from_config_file(CONFIG.plugin_config_path)
    plugins_reg.start_plugins(app)
    yield
    plugins_reg.stop_plugins()


app = FastAPI(lifespan=lifespan)
app.include_router(expense_router, prefix="/v1/expenses")
