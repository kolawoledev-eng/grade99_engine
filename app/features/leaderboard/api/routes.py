from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Header, HTTPException, Query

from app.core.db import get_supabase_client
from app.features.auth.service import AuthService

router = APIRouter(prefix="/api/leaderboard", tags=["leaderboard"])


def _week_start_utc() -> datetime:
    now = datetime.now(timezone.utc)
    d = now.date()
    monday = d - timedelta(days=d.weekday())
    return datetime.combine(monday, datetime.min.time()).replace(tzinfo=timezone.utc)


def _period_since_iso(period: str) -> Optional[str]:
    p = period.strip().lower()
    if p in ("all", "all_time", "all-time"):
        return None
    if p in ("week", "weekly"):
        return _week_start_utc().isoformat()
    raise HTTPException(status_code=400, detail="period must be 'week' or 'all'")


def _clamp_limit(limit: int) -> int:
    return max(1, min(limit, 100))


def _normalize_rpc_leaderboard(raw: Any) -> List[Dict[str, Any]]:
    if raw is None:
        return []
    if isinstance(raw, str):
        try:
            raw = json.loads(raw)
        except json.JSONDecodeError:
            return []
    if isinstance(raw, list):
        return [x for x in raw if isinstance(x, dict)]
    if isinstance(raw, dict):
        return [raw]
    return []


@router.get("")
async def leaderboard_list(
    exam: str = Query(..., description="National exam code e.g. JAMB, WAEC"),
    period: str = Query(default="week", description="week | all"),
    limit: int = Query(default=50),
) -> Dict[str, Any]:
    since = _period_since_iso(period)
    lim = _clamp_limit(limit)
    supabase = get_supabase_client()
    exu = exam.strip().upper()
    try:
        res = supabase.rpc(
            "leaderboard_top",
            {"p_exam": exu, "p_since": since, "p_limit": lim},
        ).execute()
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Leaderboard unavailable (run migration 025 and create function leaderboard_top): {exc}",
        ) from exc
    entries = _normalize_rpc_leaderboard(res.data)
    return {
        "status": "success",
        "exam": exu,
        "period": period.strip().lower(),
        "since": since,
        "entries": entries,
    }


@router.get("/me")
async def leaderboard_me(
    exam: str = Query(...),
    period: str = Query(default="week"),
    authorization: Optional[str] = Header(default=None),
) -> Dict[str, Any]:
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization required")
    parts = authorization.split(" ", 1)
    if len(parts) != 2 or parts[0].lower() != "bearer" or not parts[1].strip():
        raise HTTPException(status_code=401, detail="Invalid authorization")
    auth_svc = AuthService()
    user = auth_svc.user_from_token(parts[1].strip())
    if not user or not user.get("id"):
        raise HTTPException(status_code=401, detail="Invalid token")
    uid = str(user["id"])
    since = _period_since_iso(period)
    exu = exam.strip().upper()
    supabase = get_supabase_client()
    try:
        q = (
            supabase.table("practice_session_results")
            .select("correct_count,total_count")
            .eq("user_id", uid)
            .eq("exam", exu)
        )
        if since:
            q = q.gte("created_at", since)
        rows = q.execute().data or []
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    points = 0
    answered = 0
    sessions = 0
    for r in rows:
        sessions += 1
        c = int(r.get("correct_count") or 0)
        t = int(r.get("total_count") or 0)
        points += c
        answered += t
    acc = round(100.0 * points / answered, 1) if answered > 0 else 0.0
    return {
        "status": "success",
        "exam": exu,
        "period": period.strip().lower(),
        "since": since,
        "points": points,
        "sessions": sessions,
        "questions_answered": answered,
        "accuracy_pct": acc,
    }
