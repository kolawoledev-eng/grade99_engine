from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from app.core.admin_auth import verify_admin_key
from app.features.study_notes.batch_schemas import BatchStudyNotesGenerateRequest
from app.features.study_notes.batch_service import run_batch_pilot

router = APIRouter(prefix="/api/admin", tags=["admin"])


@router.post(
    "/study-notes/batch-generate",
    dependencies=[Depends(verify_admin_key)],
)
async def batch_generate_study_notes(payload: BatchStudyNotesGenerateRequest):
    try:
        return run_batch_pilot(payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
