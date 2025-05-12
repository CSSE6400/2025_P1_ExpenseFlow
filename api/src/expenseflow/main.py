"""Main module."""

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from expenseflow.database.core import db_engine
from expenseflow.database.service import initialise_database
from expenseflow.expense.routes import router as expense_router
from expenseflow.group.routes import router as group_router
from expenseflow.plugin import PluginRegistry
from expenseflow.user.routes import router as user_router


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator:
    """App lifespan."""
    from expenseflow.config import CONFIG

    await initialise_database(db_engine)  # Creates tables in db if not already there
    plugins_reg = PluginRegistry.create_from_config_file(CONFIG.plugin_config_path)
    plugins_reg.start_plugins(app)
    yield
    plugins_reg.stop_plugins()


app = FastAPI(lifespan=lifespan)
app.include_router(expense_router, prefix="/expenses")
app.include_router(user_router, prefix="/users")
app.include_router(group_router, prefix="/groups")


@app.get("/health")
def get_health() -> dict:
    """Health status endpoint."""
    return {"status": "healthy"}
