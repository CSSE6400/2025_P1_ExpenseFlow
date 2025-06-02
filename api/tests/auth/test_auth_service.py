"""Auth service tests."""

from unittest.mock import MagicMock, patch

import pytest
from expenseflow.auth.service import JWTError, JWTManager


@pytest.fixture
def jwt_manager():
    return JWTManager(jwt_audience="test-audience", domain="test.auth0.com")


@patch("expenseflow.auth.service.jwt.PyJWKClient")
@pytest.mark.asyncio
async def test_verify_jwk_client_error(
    mock_jwk_client: MagicMock, jwt_manager: JWTManager
):
    mock_jwk_client.return_value.get_signing_key_from_jwt.side_effect = Exception(
        "Key error"
    )
    token = "invalid.token"  # noqa: S105

    with pytest.raises(JWTError):
        await jwt_manager.verify(token)


@patch("expenseflow.auth.service.jwt.PyJWKClient")
@patch("expenseflow.auth.service.jwt.decode")
@pytest.mark.asyncio
async def test_verify_missing_sub(
    mock_decode: MagicMock, mock_jwk_client: MagicMock, jwt_manager: JWTManager
):
    mock_key = MagicMock()
    mock_jwk_client.return_value.get_signing_key_from_jwt.return_value.key = mock_key

    mock_decode.return_value = {"some": "data"}  # No 'sub'

    with pytest.raises(JWTError):
        await jwt_manager.verify("token-without-sub")


@patch("expenseflow.auth.service.jwt.PyJWKClient")
@patch("expenseflow.auth.service.jwt.decode")
@pytest.mark.asyncio
async def test_verify_invalid_signature(
    mock_decode: MagicMock, mock_jwk_client: MagicMock, jwt_manager: JWTManager
):
    mock_key = MagicMock()
    mock_jwk_client.return_value.get_signing_key_from_jwt.return_value.key = mock_key

    mock_decode.side_effect = Exception("Signature invalid")

    with pytest.raises(JWTError):
        await jwt_manager.verify("bad-token")
