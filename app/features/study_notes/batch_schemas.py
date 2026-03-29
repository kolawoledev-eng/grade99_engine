"""Request/response models for admin batch study-notes generation (pilot)."""

from __future__ import annotations

from typing import Any, Optional

from pydantic import BaseModel, Field


class TopicCursor(BaseModel):
    """Resume token: first work item to process in the next request (inclusive)."""

    year: int
    subject: str
    topic: str


class BatchStudyNotesGenerateRequest(BaseModel):
    """
    Pilot batch: defaults to a small subject list (see batch_service.PILOT_DEFAULT_SUBJECTS).
    Set include_all_subjects=true to enumerate every subject for the exam — never the default.
    """

    exam: str = Field(default="JAMB", examples=["JAMB"])
    years: list[int] = Field(default_factory=lambda: [2025])
    subjects: Optional[list[str]] = Field(
        default=None,
        description="If null and include_all_subjects is false, use pilot default subjects.",
    )
    topics: Optional[list[str]] = Field(
        default=None,
        description="If set, only these topic names (exact syllabus strings) are included.",
    )
    include_all_subjects: bool = Field(
        default=False,
        description="When true, use all subjects from the exam; required to avoid accidentally running the full catalog.",
    )
    min_subtopics: int = Field(default=25, ge=23, le=50)
    read_time_target_minutes: int = Field(default=3, ge=2, le=3)
    skip_existing: bool = Field(default=True, description="Skip when study_note_sets already exist for the triple.")
    max_topics: Optional[int] = Field(
        default=30,
        ge=1,
        le=500,
        description="Maximum Claude generations (attempts) per HTTP request; skips do not count.",
    )
    dry_run: bool = Field(default=False, description="Enumerate only; no Anthropic calls.")
    sleep_seconds: float = Field(default=1.0, ge=0.0, le=120.0, description="Pause between Anthropic calls.")
    resume_from: Optional[TopicCursor] = Field(
        default=None,
        description="Start at this (year, subject, topic) inclusive; use next_cursor from a previous response.",
    )
    user_email: Optional[str] = Field(default=None, description="Stored as generated_by on new note sets.")


class BatchStudyNotesGenerateResponse(BaseModel):
    status: str
    processed: int = 0
    skipped: int = 0
    failed: int = 0
    errors: list[dict[str, Any]] = Field(default_factory=list)
    total_cost: float = 0.0
    total_input_tokens: int = 0
    total_output_tokens: int = 0
    enumerated_total: int = 0
    next_cursor: Optional[TopicCursor] = None
    dry_run_preview: Optional[list[dict[str, Any]]] = None
