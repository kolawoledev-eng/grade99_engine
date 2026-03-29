"""Shared admin guard for protected maintenance APIs (header X-Admin-Key)."""

from __future__ import annotations

from fastapi import Header, HTTPException

from app.config import get_settings


async def verify_admin_key(x_admin_key: str | None = Header(default=None, alias="X-Admin-Key")) -> None:
    settings = get_settings()
    if not settings.admin_api_key:
        raise HTTPException(status_code=503, detail="Admin endpoint disabled (set ADMIN_API_KEY)")
    if not x_admin_key or x_admin_key != settings.admin_api_key:
        raise HTTPException(status_code=401, detail="Unauthorized")
