"""Middleware module."""

from fastapi import status
from fastapi.responses import JSONResponse, Response
from loguru import logger
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request

from expenseflow.errors import ExpenseFlowError


class ExceptionMiddleware(BaseHTTPMiddleware):
    """Middleware to catch any uncaught exceptions that should be caught."""

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response | JSONResponse:
        """Exception middleware handler.

        :param request: intercepted request
        :type request: Request
        :param call_next: what to call next
        :type call_next: RequestResponseEndpoint
        :return: API response
        :rtype: Response | JSONResponse
        """
        try:
            response = await call_next(request)
        except ExpenseFlowError as e:
            logger.error(e)
            logger.warning(
                f"Had to auto catch {type(e).__qualname__}. This should have been caught manually."
            )
            response = JSONResponse(
                status_code=status.HTTP_400_BAD_REQUEST, content={"detail": str(e)}
            )

        return response
