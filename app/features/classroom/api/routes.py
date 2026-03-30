from __future__ import annotations

from typing import Any, Dict

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field

from app.core.generate_key_auth import verify_optional_generate_key
from app.features.classroom.subject_pages_service import ClassroomSubjectPagesService

router = APIRouter(prefix="/api/classroom", tags=["classroom"])


class EnsureTopicPageBody(BaseModel):
    exam: str = Field(default="JAMB")
    year: int = Field(..., ge=2000, le=2100)
    subject: str = Field(..., min_length=1)
    topic: str = Field(..., min_length=1)
    sequence: int = Field(..., ge=1, le=500)


@router.get("/subject-pages")
async def get_subject_pages(
    exam: str = Query(..., examples=["JAMB"]),
    year: int = Query(..., ge=2000, le=2100),
    subject: str = Query(..., min_length=1),
) -> Dict[str, Any]:
    try:
        return ClassroomSubjectPagesService().build_reader_payload(exam, year, subject)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post(
    "/ensure-topic-page",
    dependencies=[Depends(verify_optional_generate_key)],
)
async def ensure_topic_page(body: EnsureTopicPageBody) -> Dict[str, Any]:
    """Generate one classroom topic page if missing (Claude), else return existing. Idempotent per topic."""
    try:
        out = ClassroomSubjectPagesService().generate_one_topic(
            exam=body.exam,
            year=body.year,
            subject=body.subject,
            topic=body.topic,
            sequence_number=body.sequence,
            generated_by="app_ensure",
        )
        return {"status": "success", **out}
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
