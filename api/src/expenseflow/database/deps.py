"""Database dependencies."""

from typing import Annotated

from expenseflow.database.core import AsyncSession, get_db

DbSession = Annotated[AsyncSession, get_db]
