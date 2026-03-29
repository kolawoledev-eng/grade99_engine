"""Allow-list for diagram URLs embedded in classroom pages (public HTTPS only)."""

from __future__ import annotations

from urllib.parse import urlparse


def is_allowed_diagram_url(url: str) -> bool:
    """Accept direct Wikimedia Commons file URLs (stable for education)."""
    try:
        p = urlparse((url or "").strip())
        if p.scheme != "https":
            return False
        host = (p.hostname or "").lower()
        if host == "upload.wikimedia.org":
            return True
        # Rare: some tools return uppercase path-only; still require upload host
        return False
    except Exception:
        return False


def subject_supports_diagrams(subject: str) -> bool:
    s = (subject or "").casefold()
    return any(k in s for k in ("biology", "chemistry", "physics"))
