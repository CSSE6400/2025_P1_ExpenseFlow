"""API Dependencies module."""

from typing import Annotated

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from expenseflow.database import get_session

# Database dependency to put into routers
DbSession = Annotated[AsyncSession, Depends(get_session)]
