#!/usr/bin/env python3
"""
Local pilot batch runner (same logic as POST /api/admin/study-notes/batch-generate).

Run from the engine directory, e.g.:

  cd engine && python scripts/generate_study_notes_pilot.py --dry-run

Requires Supabase + Anthropic env (same as the API). Admin key is not used here.
"""

from __future__ import annotations

import argparse
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from app.features.study_notes.batch_schemas import BatchStudyNotesGenerateRequest, TopicCursor
from app.features.study_notes.batch_service import run_batch_pilot


def main() -> None:
    p = argparse.ArgumentParser(description="Batch-generate JAMB study notes (pilot).")
    p.add_argument("--exam", default="JAMB")
    p.add_argument("--years", nargs="*", type=int, default=[2025])
    p.add_argument("--subjects", nargs="*", default=None, help="Default pilot list if omitted and not --all-subjects")
    p.add_argument("--topics", nargs="*", default=None, help="Restrict to exact topic names")
    p.add_argument("--all-subjects", action="store_true", help="Include every subject for the exam")
    p.add_argument("--min-subtopics", type=int, default=25)
    p.add_argument("--read-time-target-minutes", type=int, default=3)
    p.set_defaults(skip_existing=True)
    p.add_argument("--no-skip-existing", action="store_false", dest="skip_existing")
    p.add_argument("--max-topics", type=int, default=30)
    p.add_argument("--no-max-topics", action="store_true", help="Unlimited generations (use with care)")
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--sleep-seconds", type=float, default=1.0)
    p.add_argument("--resume-year", type=int, default=None)
    p.add_argument("--resume-subject", default=None)
    p.add_argument("--resume-topic", default=None)
    p.add_argument("--user-email", default=None)
    args = p.parse_args()

    resume: TopicCursor | None = None
    if args.resume_year is not None or args.resume_subject or args.resume_topic:
        if args.resume_year is None or not args.resume_subject or not args.resume_topic:
            p.error("--resume-year, --resume-subject, and --resume-topic are required together")
        resume = TopicCursor(year=args.resume_year, subject=args.resume_subject, topic=args.resume_topic)

    req = BatchStudyNotesGenerateRequest(
        exam=args.exam,
        years=list(args.years),
        subjects=list(args.subjects) if args.subjects else None,
        topics=list(args.topics) if args.topics else None,
        include_all_subjects=args.all_subjects,
        min_subtopics=args.min_subtopics,
        read_time_target_minutes=args.read_time_target_minutes,
        skip_existing=args.skip_existing,
        max_topics=None if args.no_max_topics else args.max_topics,
        dry_run=args.dry_run,
        sleep_seconds=args.sleep_seconds,
        resume_from=resume,
        user_email=args.user_email,
    )
    out = run_batch_pilot(req)
    print(json.dumps(out.model_dump(), indent=2, default=str))


if __name__ == "__main__":
    main()
