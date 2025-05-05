"""Expense Routes."""

from fastapi import APIRouter

r = router = APIRouter()


@r.get("")
async def get_all_expenses():
    pass
