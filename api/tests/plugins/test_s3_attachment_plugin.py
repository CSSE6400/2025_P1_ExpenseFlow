"""Tests S3 Attachment plugin"""

import pytest
from expenseflow.plugin import s3_attachment_plugin, PluginManager

@pytest.mark.asyncio()
async def test_attach_and_retrieve_valid(
    # determine what test needs
):
    # test valid UUID & valid image, and see if we get same image
    # test different types of images - png, jpeg, jpg?
    pass

@pytest.mark.asyncio()
async def test_attach_and_retrieve_invalid(
    # determine what test needs
):
    # test invalid UUID - although we would ideally want to call attach
    # after we have a valid UUID

    # invalid image. i.e. not png, not jpeg, etc
    pass
