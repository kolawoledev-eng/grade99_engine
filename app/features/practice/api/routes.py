from __future__ import annotations

import os
import random
from typing import Any, Dict, List, Optional, Set, Tuple

from fastapi import APIRouter, HTTPException, Query

from app.core.db import get_supabase_client
from app.features.practice.backfill import run_download_pack_backfill

router = APIRouter(prefix="/api/practice", tags=["practice"])

_FIELDS = "id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,topic,year,difficulty"

# Default off to avoid mobile timeouts and surprise Claude cost. Set DOWNLOAD_PACK_BACKFILL_DEFAULT=true on the host to opt in.
_download_bf_env = os.getenv("DOWNLOAD_PACK_BACKFILL_DEFAULT", "").strip().lower()
DOWNLOAD_PACK_BACKFILL_DEFAULT: bool = _download_bf_env in ("1", "true", "yes")


def _collect_bucket(
    supabase: Any,
    exam: str,
    year: int,
    subject: str,
    difficulty: str,
    limit: int,
    topic: Optional[str] = None,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    past: List[Dict[str, Any]] = []
    try:
        q = (
            supabase.table("past_questions")
            .select(_FIELDS + ",source_label")
            .eq("exam", exam.upper())
            .eq("year", year)
            .eq("subject", subject)
            .eq("difficulty", difficulty)
        )
        if topic and topic.lower() != "all topics":
            q = q.eq("topic", topic)
        past = q.limit(limit).execute().data or []
    except Exception:
        past = []

    need = limit - len(past)
    gen: List[Dict[str, Any]] = []
    if need > 0:
        try:
            q2 = (
                supabase.table("generated_questions")
                .select(_FIELDS)
                .eq("exam", exam.upper())
                .eq("year", year)
                .eq("subject", subject)
                .eq("difficulty", difficulty)
            )
            if topic and topic.lower() != "all topics":
                q2 = q2.eq("topic", topic)
            gen = q2.limit(need).execute().data or []
        except Exception:
            gen = []

    for p in past:
        p["source"] = "past"
    for g in gen:
        g["source"] = "generated"
    return past, gen


def _merge_jamb_use_of_english_bucket(
    supabase: Any,
    exam: str,
    year: int,
    subject: str,
    difficulty: str,
    limit: int,
    topic: Optional[str] = None,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """
    If packs were ingested as legacy JAMB subject name \"English\", merge them into Use of English.
    """
    past, gen = _collect_bucket(supabase, exam, year, subject, difficulty, limit, topic=topic)
    if exam.upper() != "JAMB" or subject != "Use of English":
        return past, gen
    total = len(past) + len(gen)
    if total >= limit:
        return past, gen
    need = limit - total
    past2, gen2 = _collect_bucket(supabase, exam, year, "English", difficulty, need, topic=topic)
    seen = {str(x.get("id", "")) for x in past + gen if x.get("id")}
    for row in past2:
        if len(past) + len(gen) >= limit:
            break
        uid = str(row.get("id", ""))
        if uid and uid in seen:
            continue
        if uid:
            seen.add(uid)
        past.append(row)
    for row in gen2:
        if len(past) + len(gen) >= limit:
            break
        uid = str(row.get("id", ""))
        if uid and uid in seen:
            continue
        if uid:
            seen.add(uid)
        gen.append(row)
    return past, gen


@router.get("/session")
async def practice_session(
    exam: str = Query(...),
    year: int = Query(...),
    subject: str = Query(...),
    difficulty: str = Query(...),
    topic: Optional[str] = Query(default=None),
    limit: int = Query(default=20, ge=1, le=100),
) -> Dict[str, Any]:
    """
    Build a practice set: prefer rows from past_questions, then generated_questions.
    """
    try:
        supabase = get_supabase_client()
        exu = exam.upper()
        past, gen = _merge_jamb_use_of_english_bucket(
            supabase, exu, year, subject, difficulty, limit, topic=topic
        )

        combined = past + gen
        random.shuffle(combined)
        return {
            "status": "success",
            "count": len(combined),
            "past_count": len(past),
            "generated_count": len(gen),
            "questions": combined[:limit],
        }
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/download-pack")
async def download_pack(
    exam: str = Query(..., description="National exam code e.g. JAMB, WAEC"),
    subject: str = Query(...),
    years: str = Query(default="2024,2025,2026", description="Comma-separated years"),
    limit_per_year_difficulty: int = Query(default=120, ge=1, le=400),
    backfill: bool = Query(
        default=DOWNLOAD_PACK_BACKFILL_DEFAULT,
        description="If true and ANTHROPIC_API_KEY is set, generate questions via Claude when a bucket is below limit_per_year_difficulty. "
        "Server default from DOWNLOAD_PACK_BACKFILL_DEFAULT env (else false).",
    ),
    backfill_max_per_bucket: int = Query(
        default=10,
        ge=0,
        le=100,
        description="Max new questions to generate per (year × difficulty) in this request; 0 disables backfill.",
    ),
    backfill_total_cap: int = Query(
        default=60,
        ge=0,
        le=300,
        description="Stop generating after this many new questions total (across all buckets) in one request.",
    ),
) -> Dict[str, Any]:
    """
    Bulk-fetch questions for offline practice: easy, medium, hard × each year (past + generated).
    Optionally backfills sparse buckets with Claude before reading (see `backfill*` params).
    Client stores JSON on device; practice sessions sample locally (e.g. 40 per session).
    """
    try:
        year_list = [int(x.strip()) for x in years.split(",") if x.strip().isdigit()]
        if not year_list:
            raise HTTPException(status_code=400, detail="No valid years in `years`")
        supabase = get_supabase_client()
        ex = exam.upper()
        diffs = ("easy", "medium", "hard")
        combined: List[Dict[str, Any]] = []
        seen: Set[str] = set()

        if not backfill:
            backfill_report: Dict[str, Any] = {
                "enabled": False,
                "ran": False,
                "reason": "backfill=false",
                "total_generated": 0,
                "per_bucket": [],
            }
        elif backfill_max_per_bucket <= 0 or backfill_total_cap <= 0:
            backfill_report = {
                "enabled": True,
                "ran": False,
                "reason": "backfill_max_per_bucket or backfill_total_cap is 0",
                "total_generated": 0,
                "per_bucket": [],
            }
        else:
            backfill_report = run_download_pack_backfill(
                supabase,
                exam=ex,
                subject=subject,
                years=year_list,
                limit_per_year_difficulty=limit_per_year_difficulty,
                backfill_max_per_bucket=backfill_max_per_bucket,
                backfill_total_cap=backfill_total_cap,
            )
            backfill_report["enabled"] = True

        for yr in year_list:
            for diff in diffs:
                past, gen = _merge_jamb_use_of_english_bucket(
                    supabase, ex, yr, subject, diff, limit_per_year_difficulty, topic=None
                )
                for row in past + gen:
                    uid = str(row.get("id", ""))
                    if uid and uid not in seen:
                        seen.add(uid)
                        combined.append(row)

        random.shuffle(combined)
        return {
            "status": "success",
            "exam": ex,
            "subject": subject,
            "years": year_list,
            "count": len(combined),
            "questions": combined,
            "backfill": backfill_report,
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
