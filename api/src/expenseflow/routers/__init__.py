"""Routers module."""

from fastapi import APIRouter

from .health import router as health_router

r = base_router = APIRouter()

# Continue to add routers here
r.include_router(health_router, prefix="/health")
