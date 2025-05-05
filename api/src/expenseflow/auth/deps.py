"""Auth dependencies."""

from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer

from expenseflow.auth.utils import get_email_from_token
from expenseflow.database.deps import DbSession
from expenseflow.user.schemas import UserSchema
from expenseflow.user.service import get_user_by_email

security_schema = HTTPBearer()


async def get_current_user(
    session: DbSession, token: Annotated[str, Depends(security_schema)]
) -> UserSchema:
    """Dependency to get current user.

    :param session: db session
    :type session: DbSession
    :param token: jwt token
    :type token: Annotated[str, Depends
    :raises HTTPException: Raised if current user could not be found
    :return: current user
    :rtype: UserSchema
    """
    email = get_email_from_token(token)
    user = await get_user_by_email(session, email)
    if user is None:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            detail="Unable to match the provided token with a user in the system.",
        )
    return user


CurrentUser = Annotated[UserSchema, get_current_user]
