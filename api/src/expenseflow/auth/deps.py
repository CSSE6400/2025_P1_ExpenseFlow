"""Auth dependencies."""

from typing import Annotated

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from loguru import logger

from expenseflow.audit.schemas import AuditCreate
from expenseflow.audit.service import create_audit
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
    session: DbSession, user_token_id: CurrentUserTokenID, request: Request
) -> UserModel:
    """Dependency to get current user."""
    user = await get_user_by_token_id(session, user_token_id)
    if user is None:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            detail="Unable to match the provided token with a user in the system.",
        )

    request_body: dict | None = None
    try:
        request_body = await request.json()
    except Exception as e:  # noqa: BLE001
        logger.warning(
            f"Request body could not be parsed as JSON, proceeding with None. - {e}"
        )

    audit_create = AuditCreate(
        method=request.method, endpoint=request.url.path, request_body=request_body
    )
    await create_audit(session, user, audit_create)

    return user


CurrentUser = Annotated[UserModel, Depends(get_current_user)]
