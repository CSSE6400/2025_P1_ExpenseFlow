"""Auth Utils."""

import jwt
from loguru import logger

from expenseflow.utils import SingletonMeta

"""expenseflow.au.auth0.com"""


class JWTError(Exception):
    """Error with jwt."""


class JWTManager(metaclass=SingletonMeta):
    """JWT Manager."""

    _domain: str
    _jwt_audience: str
    _jwks_client: jwt.PyJWKClient

    def __init__(self, jwt_audience: str, domain: str) -> None:
        """Constructor for JWT manager."""
        logger.info("CREATING JWT MANAGER")
        jwks_url = f"https://{domain}/.well-known/jwks.json"
        logger.info(jwks_url)
        logger.error(jwks_url)
        self._jwt_audience = jwt_audience
        self._domain = domain
        self.jwks_client = jwt.PyJWKClient(jwks_url)

    async def verify(self, token: str) -> str:
        """Verify jwt token."""
        # This gets the 'kid' from the passed token
        try:
            signing_key: jwt.PyJWK = self.jwks_client.get_signing_key_from_jwt(
                token
            ).key
        except jwt.exceptions.PyJWKClientError as e:
            logger.error(f"Error with python JWK client: {e}")
            raise JWTError from e
        except jwt.exceptions.DecodeError as e:
            logger.error(f"Decode error when grabbing signing key token: {e}")
            raise JWTError from e

        try:
            payload: dict = jwt.decode(
                token,
                signing_key,
                ["RS256"],
                audience=self._jwt_audience,
                issuer=f"https://{self._domain}/",
            )
        except Exception as e:
            logger.error(f"Decode error with token: {e}")
            raise JWTError from e

        sub = payload.get("sub", None)  # noqa: SIM910

        if sub is None:
            logger.error(f"SUB is none - payload is: {payload}")
            raise JWTError
        return sub


def get_email_from_token(_: str) -> str:
    """Extract email from JWT token."""
    return "test@gmail.com"
