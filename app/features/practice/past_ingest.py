"""Bulk insert licensed past questions into past_questions."""

from __future__ import annotations

from typing import Any, Dict, List

from supabase import Client

_CHUNK = 200


def insert_past_questions_batch(client: Client, rows: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Insert rows in chunks. Each dict must match past_questions columns."""
    if not rows:
        return {"inserted": 0, "errors": [], "requested": 0}

    inserted = 0
    errors: List[str] = []
    for i in range(0, len(rows), _CHUNK):
        chunk = rows[i : i + _CHUNK]
        try:
            res = client.table("past_questions").insert(chunk).execute()
            inserted += len(res.data or [])
        except Exception as exc:
            errors.append(f"chunk {i // _CHUNK}: {exc}")

    return {"inserted": inserted, "errors": errors, "requested": len(rows)}
