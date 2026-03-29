from __future__ import annotations

from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.core.admin_auth import verify_admin_key
from app.features.classroom.subject_pages_service import ClassroomSubjectPagesService

router = APIRouter(prefix="/api/admin/classroom", tags=["admin", "classroom"])


class GenerateSubjectBody(BaseModel):
    exam: str = Field(default="JAMB")
    year: int = Field(..., ge=2000, le=2100)
    subject: str = Field(..., min_length=1)
    skip_existing: bool = True
    sleep_seconds: float = Field(default=1.0, ge=0.0, le=120.0)
    max_topics: Optional[int] = Field(default=None, ge=1, le=200)


class GenerateOneTopicBody(BaseModel):
    exam: str = Field(default="JAMB")
    year: int = Field(..., ge=2000, le=2100)
    subject: str = Field(..., min_length=1)
    topic: str = Field(..., min_length=1)
    sequence_number: int = Field(..., ge=1, le=500)


@router.post("/generate-subject", dependencies=[Depends(verify_admin_key)])
async def admin_generate_subject(body: GenerateSubjectBody) -> Dict[str, Any]:
    try:
        return ClassroomSubjectPagesService().generate_whole_subject(
            exam=body.exam,
            year=body.year,
            subject=body.subject,
            skip_existing=body.skip_existing,
            sleep_seconds=body.sleep_seconds,
            max_topics=body.max_topics,
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/generate-topic", dependencies=[Depends(verify_admin_key)])
async def admin_generate_one_topic(body: GenerateOneTopicBody) -> Dict[str, Any]:
    try:
        return ClassroomSubjectPagesService().generate_one_topic(
            exam=body.exam,
            year=body.year,
            subject=body.subject,
            topic=body.topic,
            sequence_number=body.sequence_number,
            generated_by="admin",
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
