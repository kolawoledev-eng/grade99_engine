from __future__ import annotations

from typing import Any, Dict

from fastapi import APIRouter, HTTPException, Query

from app.features.classroom.subject_pages_service import ClassroomSubjectPagesService

router = APIRouter(prefix="/api/classroom", tags=["classroom"])


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
