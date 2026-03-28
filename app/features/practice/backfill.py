"""
Optional Claude backfill for national download packs when a (year × difficulty) bucket is short.

Uses existing QuestionGeneratorSupabase + quota rules (app.core.question_quota).
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List

from app.core.config import get_settings
from app.services.question_generator import QuestionGeneratorSupabase

logger = logging.getLogger(__name__)


def count_national_bucket_total(
    supabase: Any,
    exam: str,
    year: int,
    subject: str,
    difficulty: str,
) -> int:
    """All topics combined for this exam/year/subject/difficulty."""
    ex = exam.upper()
    past_c = 0
    gen_c = 0
    try:
        r = (
            supabase.table("past_questions")
            .select("id", count="exact")
            .eq("exam", ex)
            .eq("year", year)
            .eq("subject", subject)
            .eq("difficulty", difficulty)
            .execute()
        )
        past_c = r.count or 0
    except Exception:
        pass
    try:
        r2 = (
            supabase.table("generated_questions")
            .select("id", count="exact")
            .eq("exam", ex)
            .eq("year", year)
            .eq("subject", subject)
            .eq("difficulty", difficulty)
            .execute()
        )
        gen_c = r2.count or 0
    except Exception:
        pass
    return past_c + gen_c


def run_download_pack_backfill(
    supabase: Any,
    *,
    exam: str,
    subject: str,
    years: List[int],
    limit_per_year_difficulty: int,
    backfill_max_per_bucket: int,
    backfill_total_cap: int,
) -> Dict[str, Any]:
    """
    For each year × difficulty, if count < limit_per_year_difficulty, call Claude
    up to backfill_max_per_bucket new questions, until backfill_total_cap is reached.
    """
    settings = get_settings()
    if not settings.anthropic_api_key:
        return {
            "ran": False,
            "reason": "ANTHROPIC_API_KEY not set",
            "total_generated": 0,
            "per_bucket": [],
        }

    ex = exam.upper()
    diffs = ("easy", "medium", "hard")
    per_bucket: List[Dict[str, Any]] = []
    total_generated = 0

    try:
        generator = QuestionGeneratorSupabase(model=settings.anthropic_model or None)
    except Exception as exc:
        logger.warning("download-pack backfill: could not init generator: %s", exc)
        return {
            "ran": False,
            "reason": str(exc),
            "total_generated": 0,
            "per_bucket": [],
        }

    for yr in years:
        for diff in diffs:
            if total_generated >= backfill_total_cap:
                break
            before = count_national_bucket_total(supabase, ex, yr, subject, diff)
            shortfall = limit_per_year_difficulty - before
            if shortfall <= 0:
                per_bucket.append(
                    {
                        "year": yr,
                        "difficulty": diff,
                        "before": before,
                        "requested": 0,
                        "generated": 0,
                        "note": "already at or above target",
                    }
                )
                continue

            room = backfill_total_cap - total_generated
            # generate_and_save allows count 1..100
            need = min(shortfall, backfill_max_per_bucket, room, 100)
            if need < 1:
                break

            entry: Dict[str, Any] = {
                "year": yr,
                "difficulty": diff,
                "before": before,
                "requested": need,
                "generated": 0,
                "error": None,
            }
            try:
                rows = generator.generate_and_save(
                    exam=ex,
                    year=yr,
                    subject=subject,
                    difficulty=diff,
                    topic="all topics",
                    count=need,
                    user_email=None,
                )
                n = len(rows)
                entry["generated"] = n
                total_generated += n
                if n == 0:
                    entry["note"] = "generator returned no rows (quota, validation, or API failures)"
            except ValueError as exc:
                entry["error"] = str(exc)
            except Exception as exc:
                logger.exception("download-pack backfill failed year=%s diff=%s", yr, diff)
                entry["error"] = str(exc)

            per_bucket.append(entry)

        if total_generated >= backfill_total_cap:
            break

    return {
        "ran": True,
        "reason": None,
        "total_generated": total_generated,
        "per_bucket": per_bucket,
        "usage": {
            "input_tokens": generator.usage.input_tokens,
            "output_tokens": generator.usage.output_tokens,
            "total_cost": float(generator.usage.total_cost),
        },
    }
