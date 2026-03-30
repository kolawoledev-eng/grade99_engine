"""Optional shared secret for public lazy-generate endpoints (cost protection)."""

from __future__ import annotations

from fastapi import Header, HTTPException

from app.config import get_settings


async def verify_optional_generate_key(
    x_generate_key: str | None = Header(default=None, alias="X-Generate-Key"),
) -> None:
    """If PUBLIC_GENERATE_KEY is set in env, require matching X-Generate-Key header."""
    settings = get_settings()
    expected = (settings.public_generate_key or "").strip()
    if not expected:
        return
    if not x_generate_key or x_generate_key.strip() != expected:
        raise HTTPException(status_code=401, detail="Invalid or missing X-Generate-Key")
