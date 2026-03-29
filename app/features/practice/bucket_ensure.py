"""
Top up national question buckets: for each syllabus topic × difficulty, aim for target count
(past + generated) using the existing generator. Ingest real past via POST .../admin/past-questions/bulk.
"""

from __future__ import annotations

import logging
from typing import Any, Dict, List, Optional

from supabase import Client

from app.core.question_quota import MAX_PER_DIFFICULTY, allowed_new_generations_national, count_national_scope
from app.features.topics.repository import TopicsRepository
from app.services.question_generator import QuestionGeneratorSupabase

logger = logging.getLogger(__name__)

DIFFICULTIES = ("easy", "medium", "hard")


def run_ensure_national_buckets(
    supabase: Client,
    *,
    exam: str,
    year: int,
    subject: str,
    target_per_difficulty: int = 100,
    max_questions_to_generate: int = 500,
    topics_filter: Optional[List[str]] = None,
    user_email: Optional[str] = None,
) -> Dict[str, Any]:
    ex = exam.upper().strip()
    target = max(1, min(int(target_per_difficulty), MAX_PER_DIFFICULTY))

    try:
        topic_rows = TopicsRepository().list_topics(exam, year, subject)
    except ValueError as exc:
        return {
            "status": "error",
            "exam": ex,
            "year": year,
            "subject": subject,
            "reason": str(exc),
            "buckets": [],
            "total_generated": 0,
        }

    topic_names = [
        str(t.get("topic_name", "")).strip()
        for t in topic_rows
        if t.get("topic_name") and str(t.get("topic_name")).strip() != "All Topics"
    ]
    if topics_filter:
        allow = {x.strip() for x in topics_filter if x.strip()}
        topic_names = [t for t in topic_names if t in allow]

    if not topic_names:
        return {
            "status": "skipped",
            "exam": ex,
            "year": year,
            "subject": subject,
            "reason": "No syllabus topics for this subject/year (seed syllabus_topics or adjust topics_filter).",
            "buckets": [],
            "total_generated": 0,
        }

    try:
        generator = QuestionGeneratorSupabase()
    except ValueError as exc:
        return {
            "status": "error",
            "exam": ex,
            "year": year,
            "subject": subject,
            "reason": str(exc),
            "buckets": [],
            "total_generated": 0,
        }

    buckets_out: List[Dict[str, Any]] = []
    total_generated = 0

    for topic in topic_names:
        for difficulty in DIFFICULTIES:
            if total_generated >= max_questions_to_generate:
                buckets_out.append(
                    {
                        "topic": topic,
                        "difficulty": difficulty,
                        "skipped": True,
                        "note": "max_questions_to_generate reached",
                    }
                )
                continue

            scope = count_national_scope(supabase, ex, year, subject, topic, difficulty)
            current = scope["total"]
            need = max(0, target - current)
            entry: Dict[str, Any] = {
                "topic": topic,
                "difficulty": difficulty,
                "before_total": current,
                "target": target,
                "needed": need,
                "generated": 0,
                "allowed": 0,
                "quota_note": "",
                "error": None,
            }
            if need == 0:
                buckets_out.append(entry)
                continue

            allowed, reason = allowed_new_generations_national(
                supabase, ex, year, subject, topic, difficulty, need
            )
            cap_left = max_questions_to_generate - total_generated
            allowed = min(allowed, cap_left)
            entry["allowed"] = allowed
            entry["quota_note"] = reason or ""

            if allowed <= 0:
                buckets_out.append(entry)
                continue

            try:
                rows = generator.generate_and_save(
                    exam=ex,
                    year=year,
                    subject=subject,
                    difficulty=difficulty,
                    topic=topic,
                    count=allowed,
                    user_email=user_email,
                )
                n = len(rows)
                entry["generated"] = n
                total_generated += n
            except Exception as exc:
                logger.exception("ensure-buckets generate failed topic=%s diff=%s", topic, difficulty)
                entry["error"] = str(exc)

            buckets_out.append(entry)

    return {
        "status": "success",
        "exam": ex,
        "year": year,
        "subject": subject,
        "target_per_difficulty": target,
        "buckets": buckets_out,
        "total_generated": total_generated,
    }
