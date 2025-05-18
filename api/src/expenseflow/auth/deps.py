"""Auth dependencies."""

from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from loguru import logger

from expenseflow.auth.service import JWTError, JWTManager
from expenseflow.config import CONFIG
from expenseflow.database.deps import DbSession
from expenseflow.user.models import UserModel
from expenseflow.user.service import get_user_by_token_id

security_schema = HTTPBearer()

jwt_manager = JWTManager(jwt_audience=CONFIG.jwt_audience, domain=CONFIG.auth0_domain)


async def get_user_token_identifier(
    token: Annotated[HTTPAuthorizationCredentials, Depends(security_schema)]
) -> str:
    """Get user identifier from token."""
    try:
        new_user_identifier = await jwt_manager.verify(token.credentials)
    except JWTError as e:
        logger.info(f"Encountered error with provided token: {e}")
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        ) from e

    return new_user_identifier


CurrentUserTokenID = Annotated[str, Depends(get_user_token_identifier)]


async def get_current_user(
    session: DbSession, user_token_id: CurrentUserTokenID
) -> UserModel:
    """Dependency to get current user."""
    user = await get_user_by_token_id(session, user_token_id)
    if user is None:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            detail="Unable to match the provided token with a user in the system.",
        )
    return user


CurrentUser = Annotated[UserModel, Depends(get_current_user)]
