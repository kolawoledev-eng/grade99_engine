from __future__ import annotations

import hashlib
import os
import random
import re
from typing import Any, Dict, List, Optional, Set, Tuple

from fastapi import APIRouter, Depends, Header, HTTPException, Query

from app.core.admin_auth import verify_admin_key
from app.core.db import get_supabase_client
from app.features.auth.service import AuthService
from app.features.practice.backfill import run_download_pack_backfill
from app.features.practice.bucket_ensure import run_ensure_national_buckets
from app.features.practice.past_ingest import insert_past_questions_batch
from app.services.question_generator import QuestionGeneratorSupabase
from app.schemas import (
    BulkPastQuestionsRequest,
    EnsureBucketsRequest,
    PastQuestionRow,
    PracticeSessionResultCreate,
)

router = APIRouter(prefix="/api/practice", tags=["practice"])

# National online practice: allowed exam years on stored questions (inclusive).
_PRACTICE_YEAR_MIN = 2000
_PRACTICE_YEAR_MAX = 2025


def _default_practice_year_range() -> List[int]:
    return list(range(_PRACTICE_YEAR_MIN, _PRACTICE_YEAR_MAX + 1))


def _parse_years_query_param(raw: Optional[str]) -> List[int]:
    if not raw or not str(raw).strip():
        return []
    s = str(raw).strip()
    if s.lower() == "all":
        return _default_practice_year_range()
    out: List[int] = []
    for part in s.split(","):
        p = part.strip()
        if p.isdigit():
            y = int(p)
            if _PRACTICE_YEAR_MIN <= y <= _PRACTICE_YEAR_MAX:
                out.append(y)
    return sorted(set(out))


def _resolve_session_years(
    *,
    is_activated: bool,
    year: Optional[int],
    years_param: Optional[str],
) -> List[int]:
    """Free tier always gets the full year range (client year filters are ignored)."""
    if not is_activated:
        return _default_practice_year_range()
    ys = _parse_years_query_param(years_param)
    if ys:
        return ys
    if year is not None and _PRACTICE_YEAR_MIN <= year <= _PRACTICE_YEAR_MAX:
        return [year]
    if year is not None:
        return _default_practice_year_range()
    return _default_practice_year_range()


def _effective_session_difficulty(
    *,
    is_activated: bool,
    difficulty: str,
    topic_normalized: Optional[str],
) -> str:
    """Free users: mixed difficulty unless a specific topic is requested (e.g. classroom drill)."""
    raw = (difficulty or "medium").strip().lower()
    if not is_activated:
        if topic_normalized is not None:
            if raw in ("easy", "medium", "hard"):
                return raw
            if raw == "general":
                return "general"
            return "medium"
        return "general"
    if raw in ("easy", "medium", "hard", "general"):
        return raw
    return "medium"


def _normalize_session_topic(topic: Optional[str]) -> Optional[str]:
    if not topic or str(topic).strip().lower() in ("", "all topics"):
        return None
    return topic


# Practice session: past + generated share MCQ columns; only past_questions has source_label.
_MCQ_FIELDS = (
    "id,question_text,option_a,option_b,option_c,option_d,correct_answer,explanation,image_url,topic,year,difficulty,"
    "learning_outcomes,syllabus_alignment,source_type,tokens_used,api_cost"
)
_PAST_FIELDS = _MCQ_FIELDS + ",source_label"
_GEN_FIELDS = _MCQ_FIELDS

_WS = re.compile(r"\s+")


def _fingerprint_part(raw: Any) -> str:
    s = str(raw or "").strip().lower()
    s = _WS.sub(" ", s)
    return s


def _question_fingerprint(row: Dict[str, Any]) -> str:
    """Stable hash so past vs generated duplicates (same stem/options) collapse to one card."""
    blob = "|".join(
        [
            _fingerprint_part(row.get("question_text")),
            _fingerprint_part(row.get("option_a")),
            _fingerprint_part(row.get("option_b")),
            _fingerprint_part(row.get("option_c")),
            _fingerprint_part(row.get("option_d")),
        ]
    )
    return hashlib.sha256(blob.encode("utf-8")).hexdigest()


def _subject_key(name: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", (name or "").strip().lower())


def _subject_aliases(exam: str, subject: str) -> List[str]:
    if exam.upper() == "JAMB" and _subject_key(subject) in {"useofenglish", "english"}:
        return ["Use of English", "English", "use of english", "english"]
    return [subject]


def _pack_row_fingerprint(row: Dict[str, Any]) -> str:
    """Offline pack spans multiple years — keep same stem in different years as separate cards."""
    blob = "|".join(
        [
            _fingerprint_part(row.get("question_text")),
            _fingerprint_part(row.get("option_a")),
            _fingerprint_part(row.get("option_b")),
            _fingerprint_part(row.get("option_c")),
            _fingerprint_part(row.get("option_d")),
            str(row.get("year", "")),
            _fingerprint_part(row.get("difficulty")),
            _fingerprint_part(row.get("topic")),
        ]
    )
    return hashlib.sha256(blob.encode("utf-8")).hexdigest()


def _practice_past_ratio() -> float:
    try:
        r = float(os.getenv("PRACTICE_PAST_RATIO", "0.7"))
    except ValueError:
        r = 0.7
    return max(0.0, min(1.0, r))


def _split_past_gen_targets(limit: int, past_ratio: float) -> Tuple[int, int]:
    pr = max(0.0, min(1.0, float(past_ratio)))
    past_t = min(limit, int(round(limit * pr)))
    return past_t, limit - past_t


def _finalize_past_generated_ratio(
    past: List[Dict[str, Any]],
    gen: List[Dict[str, Any]],
    limit: int,
    past_ratio: float,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """
    Target ~past_ratio past / ~(1-past_ratio) generated (unique by stem+options),
    then backfill from either pool if one side is short.
    """
    if limit <= 0:
        return [], []
    pr = max(0.0, min(1.0, float(past_ratio)))
    past_target = min(limit, int(round(limit * pr)))
    gen_target = limit - past_target
    seen: Set[str] = set()
    out_past: List[Dict[str, Any]] = []
    out_gen: List[Dict[str, Any]] = []

    def try_add(r: Dict[str, Any], label: str) -> bool:
        fp = _question_fingerprint(r)
        if fp in seen:
            return False
        seen.add(fp)
        row = dict(r)
        row["source"] = "past" if label == "past" else "generated"
        if label == "past":
            out_past.append(row)
        else:
            out_gen.append(row)
        return True

    for r in past:
        if len(out_past) >= past_target:
            break
        try_add(r, "past")

    for r in gen:
        if len(out_gen) >= gen_target:
            break
        try_add(r, "generated")

    need = limit - len(out_past) - len(out_gen)
    if need > 0:
        for r in past:
            if need <= 0:
                break
            if try_add(r, "past"):
                need -= 1
        for r in gen:
            if need <= 0:
                break
            if try_add(r, "generated"):
                need -= 1
    return out_past, out_gen


def _difficulty_split(total: int) -> List[Tuple[str, int]]:
    base = total // 3
    rem = total % 3
    buckets = [("easy", base), ("medium", base), ("hard", base)]
    for i in range(rem):
        d, c = buckets[i]
        buckets[i] = (d, c + 1)
    return [(d, c) for d, c in buckets if c > 0]


def _auto_generate_national_mix(
    *,
    exam: str,
    year: int,
    subject: str,
    topic: Optional[str],
    limit: int,
) -> Tuple[List[Dict[str, Any]], str]:
    try:
        gen = QuestionGeneratorSupabase()
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Auto-generation unavailable: {exc}",
        ) from exc

    generated: List[Dict[str, Any]] = []
    errors: List[str] = []
    topic_key = topic if topic and topic.lower() != "all topics" else "all topics"
    for diff, cnt in _difficulty_split(limit):
        try:
            rows = gen.generate_and_save(
                exam=exam.upper(),
                year=year,
                subject=subject,
                difficulty=diff,
                topic=topic_key,
                count=cnt,
                user_email="api-auto",
            )
            for r in rows:
                row = dict(r)
                row["source"] = "generated"
                generated.append(row)
        except Exception as exc:
            errors.append(f"{diff}: {exc}")
    if not generated:
        reason = "; ".join(errors) if errors else "unknown generation error"
        raise HTTPException(
            status_code=503,
            detail=(
                "No questions available and auto-generation failed. "
                f"Likely Claude/API quota or config issue: {reason}"
            ),
        )
    random.shuffle(generated)
    return generated[:limit], "; ".join(errors) if errors else ""


# Default off to avoid mobile timeouts and surprise Claude cost. Set DOWNLOAD_PACK_BACKFILL_DEFAULT=true on the host to opt in.
_download_bf_env = os.getenv("DOWNLOAD_PACK_BACKFILL_DEFAULT", "").strip().lower()
DOWNLOAD_PACK_BACKFILL_DEFAULT: bool = _download_bf_env in ("1", "true", "yes")


def _past_row_to_db(r: PastQuestionRow) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "exam": r.exam.strip().upper(),
        "year": r.year,
        "subject": r.subject.strip(),
        "difficulty": r.difficulty,
        "topic": r.topic.strip(),
        "question_text": r.question_text.strip(),
        "option_a": r.option_a.strip(),
        "option_b": r.option_b.strip(),
        "option_c": r.option_c.strip(),
        "option_d": r.option_d.strip(),
        "correct_answer": r.correct_answer,
        "explanation": (r.explanation or "").strip() or None,
        "source_label": (r.source_label or "").strip() or None,
        "learning_outcomes": list(r.learning_outcomes or []),
        "syllabus_alignment": (r.syllabus_alignment or "").strip() or None,
        "source_type": (r.source_type or "past").strip() or "past",
    }
    if r.tokens_used is not None:
        row["tokens_used"] = r.tokens_used
    if r.api_cost is not None:
        row["api_cost"] = r.api_cost
    return row


@router.post("/admin/past-questions/bulk", dependencies=[Depends(verify_admin_key)])
async def bulk_ingest_past_questions(payload: BulkPastQuestionsRequest) -> Dict[str, Any]:
    """Admin: bulk insert licensed past MCQs into past_questions (header X-Admin-Key)."""
    if not payload.questions:
        return {"status": "success", "inserted": 0, "requested": 0, "errors": []}
    supabase = get_supabase_client()
    rows = [_past_row_to_db(q) for q in payload.questions]
    result = insert_past_questions_batch(supabase, rows)
    return {"status": "success", **result}


@router.post("/admin/ensure-buckets", dependencies=[Depends(verify_admin_key)])
async def ensure_national_buckets(payload: EnsureBucketsRequest) -> Dict[str, Any]:
    """Admin: top up each syllabus topic × difficulty toward target using AI generation (X-Admin-Key)."""
    supabase = get_supabase_client()
    return run_ensure_national_buckets(
        supabase,
        exam=payload.exam,
        year=payload.year,
        subject=payload.subject,
        target_per_difficulty=payload.target_per_difficulty,
        max_questions_to_generate=payload.max_questions_to_generate,
        topics_filter=payload.topics,
        user_email=payload.user_email,
    )


def _collect_bucket(
    supabase: Any,
    exam: str,
    year: int,
    subject: str,
    difficulty: str,
    past_limit: int,
    gen_limit: int,
    topic: Optional[str] = None,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """
    Fetch up to past_limit unique past_questions and gen_limit unique generated_questions
    (generated skips fingerprints already taken from past). Larger fetch_cap avoids
    empty slots when many rows are duplicate stems.
    """
    total = past_limit + gen_limit
    fetch_cap = min(500, max(total * 10, total + 50, past_limit * 15, gen_limit * 15))
    aliases = _subject_aliases(exam, subject)

    past_raw: List[Dict[str, Any]] = []
    if past_limit > 0:
        try:
            q = (
                supabase.table("past_questions")
                .select(_PAST_FIELDS)
                .eq("exam", exam.upper())
                .eq("year", year)
                .eq("difficulty", difficulty)
            )
            if len(aliases) > 1:
                q = q.in_("subject", aliases)
            else:
                q = q.eq("subject", subject)
            if topic and topic.lower() != "all topics":
                q = q.eq("topic", topic)
            past_raw = q.limit(fetch_cap).execute().data or []
        except Exception:
            past_raw = []

    seen: Set[str] = set()
    past: List[Dict[str, Any]] = []
    for r in past_raw:
        if len(past) >= past_limit:
            break
        fp = _question_fingerprint(r)
        if fp in seen:
            continue
        seen.add(fp)
        past.append(dict(r))

    gen: List[Dict[str, Any]] = []
    if gen_limit > 0:
        gen_raw: List[Dict[str, Any]] = []
        try:
            q2 = (
                supabase.table("generated_questions")
                .select(_GEN_FIELDS)
                .eq("exam", exam.upper())
                .eq("year", year)
                .eq("difficulty", difficulty)
            )
            if len(aliases) > 1:
                q2 = q2.in_("subject", aliases)
            else:
                q2 = q2.eq("subject", subject)
            if topic and topic.lower() != "all topics":
                q2 = q2.eq("topic", topic)
            gen_raw = q2.limit(fetch_cap).execute().data or []
        except Exception:
            gen_raw = []

        for r in gen_raw:
            if len(gen) >= gen_limit:
                break
            fp = _question_fingerprint(r)
            if fp in seen:
                continue
            seen.add(fp)
            gen.append(dict(r))

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
    past_limit: int,
    gen_limit: int,
    topic: Optional[str] = None,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """
    If packs were ingested as legacy JAMB subject name \"English\", merge them into Use of English.
    """
    past, gen = _collect_bucket(
        supabase, exam, year, subject, difficulty, past_limit, gen_limit, topic=topic
    )
    if exam.upper() != "JAMB" or _subject_key(subject) not in {"useofenglish", "english"}:
        return past, gen
    need_past = past_limit - len(past)
    need_gen = gen_limit - len(gen)
    if need_past <= 0 and need_gen <= 0:
        return past, gen
    past2, gen2 = _collect_bucket(
        supabase, exam, year, "English", difficulty, need_past, need_gen, topic=topic
    )
    if not (past2 or gen2) and topic and topic.lower() != "all topics":
        # Legacy English rows often use old topic labels; relax topic to avoid empty sessions.
        past2, gen2 = _collect_bucket(
            supabase, exam, year, "English", difficulty, need_past, need_gen, topic=None
        )
    seen_fp = {_question_fingerprint(x) for x in past + gen}
    for row in past2:
        if len(past) >= past_limit:
            break
        fp = _question_fingerprint(row)
        if fp in seen_fp:
            continue
        seen_fp.add(fp)
        past.append(row)
    for row in gen2:
        if len(gen) >= gen_limit:
            break
        fp = _question_fingerprint(row)
        if fp in seen_fp:
            continue
        seen_fp.add(fp)
        gen.append(row)
    return past, gen


def _merge_jamb_bucket_multi_year(
    supabase: Any,
    exam: str,
    years: List[int],
    subject: str,
    difficulty: str,
    past_target: int,
    gen_target: int,
    topic: Optional[str] = None,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """Round-robin across exam years until past/gen targets are met (deduped)."""
    if not years:
        return [], []
    if len(years) == 1:
        return _merge_jamb_use_of_english_bucket(
            supabase,
            exam,
            years[0],
            subject,
            difficulty,
            past_target,
            gen_target,
            topic=topic,
        )

    past_out: List[Dict[str, Any]] = []
    gen_out: List[Dict[str, Any]] = []
    seen: Set[str] = set()
    y_order = list(years)
    random.shuffle(y_order)
    n_y = len(y_order)
    per_round_p = (
        max(2, min(12, past_target // max(3, n_y) + 2)) if past_target > 0 else 0
    )
    per_round_g = (
        max(2, min(12, gen_target // max(3, n_y) + 2)) if gen_target > 0 else 0
    )
    yi = 0
    for _ in range(120):
        if len(past_out) >= past_target and len(gen_out) >= gen_target:
            break
        progressed = False
        for _step in range(n_y):
            if len(past_out) >= past_target and len(gen_out) >= gen_target:
                break
            yr = y_order[yi % n_y]
            yi += 1
            need_p = past_target - len(past_out)
            need_g = gen_target - len(gen_out)
            rp = min(per_round_p, need_p) if need_p > 0 else 0
            rg = min(per_round_g, need_g) if need_g > 0 else 0
            if rp <= 0 and rg <= 0:
                break
            p, g = _merge_jamb_use_of_english_bucket(
                supabase, exam, yr, subject, difficulty, rp, rg, topic=topic
            )
            for row in p:
                if len(past_out) >= past_target:
                    break
                fp = _question_fingerprint(row)
                if fp in seen:
                    continue
                seen.add(fp)
                past_out.append(row)
                progressed = True
            for row in g:
                if len(gen_out) >= gen_target:
                    break
                fp = _question_fingerprint(row)
                if fp in seen:
                    continue
                seen.add(fp)
                gen_out.append(row)
                progressed = True
        if not progressed:
            break
    return past_out, gen_out


def _session_collect_mixed_general(
    supabase: Any,
    exam: str,
    years: List[int],
    subject: str,
    past_target: int,
    gen_target: int,
    topic: Optional[str] = None,
) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]]]:
    """Blend easy / medium / hard when difficulty=general (free tier default)."""
    seen: Set[str] = set()
    past_all: List[Dict[str, Any]] = []
    gen_all: List[Dict[str, Any]] = []
    pmap = dict(_difficulty_split(past_target)) if past_target > 0 else {}
    gmap = dict(_difficulty_split(gen_target)) if gen_target > 0 else {}
    diffs = sorted(set(pmap.keys()) | set(gmap.keys()))
    for diff in diffs:
        pc = pmap.get(diff, 0)
        gc = gmap.get(diff, 0)
        if pc <= 0 and gc <= 0:
            continue
        p, g = _merge_jamb_bucket_multi_year(
            supabase, exam, years, subject, diff, pc, gc, topic=topic
        )
        for row in p:
            fp = _question_fingerprint(row)
            if fp in seen:
                continue
            seen.add(fp)
            past_all.append(row)
        for row in g:
            fp = _question_fingerprint(row)
            if fp in seen:
                continue
            seen.add(fp)
            gen_all.append(row)
    return past_all, gen_all


@router.get("/session")
async def practice_session(
    exam: str = Query(...),
    subject: str = Query(...),
    difficulty: str = Query(...),
    year: Optional[int] = Query(
        default=None,
        description="Single exam year (subscribers). Optional if years= is set.",
    ),
    years: Optional[str] = Query(
        default=None,
        description="Comma-separated years or 'all' (2000–2025). Subscribers only; free tier ignores.",
    ),
    topic: Optional[str] = Query(default=None),
    limit: int = Query(default=20, ge=1, le=100),
    authorization: Optional[str] = Header(default=None),
) -> Dict[str, Any]:
    """
    Build a practice set: mix past_questions and generated_questions (~70/30 by default,
    PRACTICE_PAST_RATIO). Questions are unique by stem+options fingerprint; if one pool is
    short, the other fills remaining slots.

    Free (unactivated) users: always draw from all years 2000–2025 and mixed difficulty
    (easy/medium/hard), regardless of year/years/difficulty query params — so older app
    builds keep working while the pool is wider.

    Subscribers: optional ``years`` (or legacy ``year``) and difficulty including
    ``general`` for a mixed split.
    """
    try:
        free_question_limit = 5
        is_activated = False
        auth_user_id: Optional[str] = None
        if authorization:
            parts = authorization.split(" ", 1)
            if len(parts) == 2 and parts[0].lower() == "bearer":
                token = parts[1].strip()
                if token:
                    auth_svc = AuthService()
                    user = auth_svc.user_from_token(token)
                    if user:
                        auth_user_id = user.get("id")
                        is_activated = bool(
                            auth_svc.access_state(user["id"]).get("is_activated")
                        )

        effective_limit = limit if is_activated else min(limit, free_question_limit)
        supabase = get_supabase_client()
        exu = exam.upper()
        topic_eff = _normalize_session_topic(topic)
        resolved_years = _resolve_session_years(
            is_activated=is_activated,
            year=year,
            years_param=years,
        )
        diff_eff = _effective_session_difficulty(
            is_activated=is_activated,
            difficulty=difficulty,
            topic_normalized=topic_eff,
        )
        ratio = _practice_past_ratio()
        past_target, gen_target = _split_past_gen_targets(effective_limit, ratio)
        if diff_eff == "general":
            past, gen = _session_collect_mixed_general(
                supabase,
                exu,
                resolved_years,
                subject,
                past_target,
                gen_target,
                topic=topic_eff,
            )
        else:
            past, gen = _merge_jamb_bucket_multi_year(
                supabase,
                exu,
                resolved_years,
                subject,
                diff_eff,
                past_target,
                gen_target,
                topic=topic_eff,
            )
        past, gen = _finalize_past_generated_ratio(
            past, gen, effective_limit, ratio
        )

        combined = past + gen
        auto_note: Optional[str] = None
        if not combined:
            gen_year = (
                resolved_years[0]
                if len(resolved_years) == 1
                else random.choice(resolved_years)
            )
            combined, auto_errors = _auto_generate_national_mix(
                exam=exu,
                year=gen_year,
                subject=subject,
                topic=topic_eff,
                limit=effective_limit,
            )
            if auto_errors:
                auto_note = f"partial generation notes: {auto_errors}"
        random.shuffle(combined)
        analytics_year = (
            resolved_years[0]
            if len(resolved_years) == 1
            else _PRACTICE_YEAR_MIN
        )
        if auth_user_id:
            try:
                supabase.table("practice_attempts").insert(
                    {
                        "user_id": auth_user_id,
                        "exam": exu,
                        "year": analytics_year,
                        "subject": subject,
                        "difficulty": diff_eff,
                        "requested_limit": limit,
                        "served_limit": min(len(combined), effective_limit),
                        "blocked_at_question": (free_question_limit + 1)
                        if not is_activated and limit > free_question_limit
                        else None,
                        "is_activated_at_request": is_activated,
                    }
                ).execute()
            except Exception:
                # Non-blocking analytics insert.
                pass
        payload: Dict[str, Any] = {
            "status": "success",
            "count": len(combined),
            "past_count": len(past),
            "generated_count": len(gen),
            "questions": combined[:effective_limit],
            "is_activated": is_activated,
            "free_question_limit": free_question_limit,
            "paywall_trigger_question": free_question_limit + 1,
            "practice_years": resolved_years,
            "difficulty_applied": diff_eff,
        }
        if auto_note is not None:
            payload["auto_generation_note"] = auto_note
        return payload
    except HTTPException:
        raise
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
    minimum_required: int = Query(
        default=40,
        ge=1,
        le=400,
        description="Minimum questions expected by client for a first offline session.",
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

        pack_ratio = _practice_past_ratio()
        past_pack_target, gen_pack_target = _split_past_gen_targets(
            limit_per_year_difficulty, pack_ratio
        )

        def collect_combined() -> List[Dict[str, Any]]:
            out: List[Dict[str, Any]] = []
            local_seen: Set[str] = set()
            for yr in year_list:
                for diff in diffs:
                    past, gen = _merge_jamb_use_of_english_bucket(
                        supabase,
                        ex,
                        yr,
                        subject,
                        diff,
                        past_pack_target,
                        gen_pack_target,
                        topic=None,
                    )
                    past, gen = _finalize_past_generated_ratio(
                        past, gen, limit_per_year_difficulty, pack_ratio
                    )
                    for row in past + gen:
                        fp = _pack_row_fingerprint(row)
                        if fp in local_seen:
                            continue
                        local_seen.add(fp)
                        out.append(row)
            return out

        combined = collect_combined()

        # Auto-escalate: if caller passed backfill=false but DB is empty,
        # run backfill once automatically to avoid hard dead-ends.
        if (
            not backfill
            and not combined
            and backfill_max_per_bucket > 0
            and backfill_total_cap > 0
        ):
            auto_report = run_download_pack_backfill(
                supabase,
                exam=ex,
                subject=subject,
                years=year_list,
                limit_per_year_difficulty=limit_per_year_difficulty,
                backfill_max_per_bucket=backfill_max_per_bucket,
                backfill_total_cap=backfill_total_cap,
            )
            auto_report["enabled"] = True
            auto_report["auto_triggered"] = True
            auto_report["reason"] = auto_report.get("reason") or "auto-triggered because initial pack was empty"
            backfill_report = auto_report
            combined = collect_combined()
        random.shuffle(combined)
        count = len(combined)
        ready_for_offline = count >= minimum_required
        if count == 0:
            reason = backfill_report.get("reason") or "no questions available"
            raise HTTPException(
                status_code=503,
                detail=(
                    f"No questions available for {ex} {subject}. "
                    f"Backfill state: enabled={backfill_report.get('enabled')} "
                    f"ran={backfill_report.get('ran')} reason={reason}. "
                    "Configure ANTHROPIC_API_KEY and enable backfill, or ingest past questions."
                ),
            )
        return {
            "status": "success",
            "exam": ex,
            "subject": subject,
            "years": year_list,
            "count": count,
            "minimum_required": minimum_required,
            "ready_for_offline": ready_for_offline,
            "message": (
                "Offline pack ready."
                if ready_for_offline
                else f"Pack downloaded but only {count} questions found (< {minimum_required}). "
                "Try again shortly while generation backfills."
            ),
            "questions": combined,
            "backfill": backfill_report,
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/session-result")
async def submit_practice_session_result(
    payload: PracticeSessionResultCreate,
    authorization: Optional[str] = Header(default=None),
) -> Dict[str, Any]:
    """
    Record one finished national practice session (correct / total) for leaderboards.
    Requires Bearer token. School / institution practice should not call this.
    """
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
    exu = payload.exam.strip().upper()
    subj = payload.subject.strip()
    if not subj:
        raise HTTPException(status_code=400, detail="subject is required")
    score_pct = round(100.0 * payload.correct_count / payload.total_count, 3)
    diff = (payload.difficulty or "").strip()[:20] or None
    row: Dict[str, Any] = {
        "user_id": uid,
        "exam": exu,
        "subject": subj[:120],
        "year": payload.year,
        "difficulty": diff,
        "practise_mode": payload.practise_mode,
        "correct_count": payload.correct_count,
        "total_count": payload.total_count,
        "score_pct": score_pct,
    }
    try:
        get_supabase_client().table("practice_session_results").insert(row).execute()
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    return {"status": "success"}
