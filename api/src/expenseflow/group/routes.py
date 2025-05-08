"""Group routes."""

from uuid import UUID

from fastapi import APIRouter

r = router = APIRouter()


@r.get("")
def get_user_groups():
    pass


@r.get("/{group_id}")
def get_group(group_id: UUID):
    pass


@r.post("")
def create_group():
    pass


@r.put("")
def update_group():
    pass
