"""Database dependencies."""

from typing import Annotated

from fastapi import Depends

from expenseflow.database.core import AsyncSession, get_db

DbSession = Annotated[AsyncSession, Depends(get_db)]
