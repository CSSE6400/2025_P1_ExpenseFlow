"""Auth dependency tests."""

import pytest
from expenseflow.auth.deps import get_current_user, get_user_token_identifier
from expenseflow.auth.service import JWTError
from expenseflow.user.models import UserModel
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession


@pytest.mark.asyncio
async def test_get_user_token_identifier_success(monkeypatch: pytest.MonkeyPatch):
    mock_token = HTTPAuthorizationCredentials(
        scheme="Bearer", credentials="valid-token"
    )

    async def mock_verify(token: str) -> str:
        return "user123"

    monkeypatch.setattr("expenseflow.auth.deps.jwt_manager.verify", mock_verify)

    result = await get_user_token_identifier(mock_token)
    assert result == "user123"


@pytest.mark.asyncio
async def test_get_user_token_identifier_invalid(monkeypatch: pytest.MonkeyPatch):
    mock_token = HTTPAuthorizationCredentials(scheme="Bearer", credentials="bad-token")

    async def mock_verify(token: str) -> str:
        msg = "Invalid token"
        raise JWTError(msg)

    monkeypatch.setattr("expenseflow.auth.deps.jwt_manager.verify", mock_verify)

    with pytest.raises(HTTPException) as exc_info:
        await get_user_token_identifier(mock_token)

    assert exc_info.value.status_code == 401
    assert exc_info.value.detail == "Invalid token"


@pytest.mark.asyncio
async def test_get_current_user_success(
    monkeypatch: pytest.MonkeyPatch, user_model: UserModel, session: AsyncSession
):
    mock_user_token_id = "user123"  # noqa: S105

    async def mock_get_user_by_token_id(
        sess: AsyncSession, user_token_id: str
    ) -> UserModel:
        assert sess == session
        assert user_token_id == mock_user_token_id
        return user_model

    monkeypatch.setattr(
        "expenseflow.auth.deps.get_user_by_token_id", mock_get_user_by_token_id
    )

    result = await get_current_user(session, mock_user_token_id)
    assert result == user_model


@pytest.mark.asyncio
async def test_get_current_user_not_found(
    monkeypatch: pytest.MonkeyPatch, user_model: UserModel, session: AsyncSession
):
    mock_user_token_id = "user123"  # noqa: S105

    async def mock_get_user_by_token_id(
        session: AsyncSession, user_token_id: str
    ) -> UserModel | None:
        return None

    monkeypatch.setattr(
        "expenseflow.auth.deps.get_user_by_token_id", mock_get_user_by_token_id
    )

    with pytest.raises(HTTPException) as exc_info:
        await get_current_user(session, mock_user_token_id)

    assert exc_info.value.status_code == 401
    assert "Unable to match" in exc_info.value.detail
