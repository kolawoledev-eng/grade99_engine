"""
Batch pilot generation for study notes.

Enumerates syllabus topics via TopicsRepository, optionally deletes existing note sets per topic
before regenerate, and calls StudyNotesService.generate_and_save with throttling.

Estimated cost scales with topics × ~1 Claude message each; a full multi-year multi-subject run
can be hundreds or thousands of calls — use max_topics, sleep_seconds, and resume_from.
"""

from __future__ import annotations

import time
from typing import Any

from app.features.study_notes.batch_schemas import (
    BatchStudyNotesGenerateRequest,
    BatchStudyNotesGenerateResponse,
    TopicCursor,
)
from app.features.study_notes.repository import StudyNotesRepository
from app.features.study_notes.service import StudyNotesService
from app.features.topics.repository import TopicsRepository

# Default pilot when subjects is None and include_all_subjects is False (documented in BatchStudyNotesGenerateRequest).
PILOT_DEFAULT_SUBJECTS: tuple[str, ...] = ("History", "Mathematics", "Use of English")

ALL_TOPICS_LABEL = "All Topics"


def flatten_topic_names(topic_rows: list[dict[str, Any]]) -> list[str]:
    """Leaf topic names from list_topics-style rows; skips 'All Topics' and supports optional children."""
    out: list[str] = []
    for row in topic_rows:
        raw = " ".join(str(row.get("topic_name", "")).split()).strip()
        if not raw or raw == ALL_TOPICS_LABEL:
            continue
        children = row.get("children")
        if isinstance(children, list) and len(children) > 0:
            for c in children:
                if not isinstance(c, dict):
                    continue
                nm = " ".join(str(c.get("topic_name", "")).split()).strip()
                if nm and nm != ALL_TOPICS_LABEL:
                    out.append(nm)
        else:
            out.append(raw)
    return out


def _work_item_key(w: dict[str, Any]) -> tuple[int, str, str]:
    return (int(w["year"]), str(w["subject"]).lower(), str(w["topic"]).lower())


def build_work_queue(
    exam: str,
    years: list[int],
    subjects: list[str],
    topics_repo: TopicsRepository,
    topic_filter: set[str] | None,
) -> list[dict[str, Any]]:
    work: list[dict[str, Any]] = []
    for year in years:
        for subject in subjects:
            try:
                rows = topics_repo.list_topics(exam, year, subject)
            except ValueError:
                continue
            names = flatten_topic_names(rows)
            if topic_filter is not None:
                names = [n for n in names if n in topic_filter]
            for topic in names:
                work.append({"year": year, "subject": subject, "topic": topic})
    work.sort(key=_work_item_key)
    return work


def find_resume_index(work: list[dict[str, Any]], resume: TopicCursor | None) -> int:
    if resume is None:
        return 0
    for i, w in enumerate(work):
        if w["year"] == resume.year and w["subject"] == resume.subject and w["topic"] == resume.topic:
            return i
    raise ValueError(
        f"resume_from not found in enumerated queue: year={resume.year!r} "
        f"subject={resume.subject!r} topic={resume.topic!r}"
    )


def run_batch_pilot(req: BatchStudyNotesGenerateRequest) -> BatchStudyNotesGenerateResponse:
    topics_repo = TopicsRepository()
    svc = StudyNotesService()
    repo = StudyNotesRepository()

    exam = req.exam.strip()
    if req.include_all_subjects:
        subject_names = [s["name"] for s in topics_repo.list_subjects(exam)]
    elif req.subjects:
        subject_names = list(req.subjects)
    else:
        subject_names = list(PILOT_DEFAULT_SUBJECTS)

    topic_filter: set[str] | None = None
    if req.topics:
        topic_filter = set(req.topics)

    work = build_work_queue(exam, req.years, subject_names, topics_repo, topic_filter)
    enumerated_total = len(work)

    start_idx = find_resume_index(work, req.resume_from)

    if req.dry_run:
        if req.max_topics is None:
            preview = work[start_idx:]
            next_c: TopicCursor | None = None
        else:
            preview = work[start_idx : start_idx + req.max_topics]
            if start_idx + len(preview) < len(work):
                nxt = work[start_idx + len(preview)]
                next_c = TopicCursor(year=nxt["year"], subject=nxt["subject"], topic=nxt["topic"])
            else:
                next_c = None
        return BatchStudyNotesGenerateResponse(
            status="dry_run",
            enumerated_total=enumerated_total,
            dry_run_preview=preview,
            next_cursor=next_c,
        )

    processed = 0
    skipped = 0
    failed = 0
    errors: list[dict[str, Any]] = []
    total_cost = 0.0
    total_in = 0
    total_out = 0

    idx = start_idx
    generations = 0
    max_gen = req.max_topics

    while idx < len(work):
        if max_gen is not None and generations >= max_gen:
            break
        item = work[idx]
        year, subject, topic = item["year"], item["subject"], item["topic"]

        if req.skip_existing and repo.has_notes_for_topic(exam, year, subject, topic):
            skipped += 1
            idx += 1
            continue

        try:
            repo.delete_notes_for_topic(exam, year, subject, topic)
            result = svc.generate_and_save(
                exam=exam,
                year=year,
                subject=subject,
                topic=topic,
                min_subtopics=req.min_subtopics,
                read_time_target_minutes=req.read_time_target_minutes,
                user_email=req.user_email,
                source_url=None,
            )
            processed += 1
            generations += 1
            total_cost += float(result.total_cost)
            total_in += int(result.input_tokens)
            total_out += int(result.output_tokens)
        except Exception as exc:  # noqa: BLE001 — batch collects per-item failures
            failed += 1
            generations += 1
            errors.append(
                {
                    "year": year,
                    "subject": subject,
                    "topic": topic,
                    "error": str(exc),
                }
            )

        idx += 1
        if req.sleep_seconds > 0 and idx < len(work) and (max_gen is None or generations < max_gen):
            time.sleep(req.sleep_seconds)

    next_cursor: TopicCursor | None = None
    if idx < len(work):
        nxt = work[idx]
        next_cursor = TopicCursor(year=nxt["year"], subject=nxt["subject"], topic=nxt["topic"])

    return BatchStudyNotesGenerateResponse(
        status="success",
        processed=processed,
        skipped=skipped,
        failed=failed,
        errors=errors,
        total_cost=total_cost,
        total_input_tokens=total_in,
        total_output_tokens=total_out,
        enumerated_total=enumerated_total,
        next_cursor=next_cursor,
    )
