from __future__ import annotations

import time
from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from app.core.admin_auth import verify_admin_key
from app.features.novel_recommendation.literature_repository import LiteratureRepository
from app.features.novel_recommendation.literature_summary_service import LiteratureSummaryService

router = APIRouter(prefix="/api/admin/novels", tags=["admin", "literature"])


class LiteratureBatchBody(BaseModel):
    skip_existing: bool = Field(default=True)
    max_novels: Optional[int] = Field(default=None, ge=1, le=50)
    sleep_seconds: float = Field(default=2.0, ge=0.0, le=120.0)


@router.post("/literature/{novel_id}/generate-summary", dependencies=[Depends(verify_admin_key)])
async def admin_generate_novel_summary(novel_id: int) -> Dict[str, Any]:
    try:
        return LiteratureSummaryService().generate_and_save(novel_id, generated_by="admin")
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post("/literature/generate-batch", dependencies=[Depends(verify_admin_key)])
async def admin_generate_novel_batch(body: LiteratureBatchBody) -> Dict[str, Any]:
    repo = LiteratureRepository()
    svc = LiteratureSummaryService()
    novels = repo.list_novels()
    processed = 0
    skipped = 0
    failed = 0
    errors: list[Dict[str, Any]] = []

    generations = 0
    for n in novels:
        nid = int(n["id"])
        if body.skip_existing and repo.get_summary_for_novel(nid):
            skipped += 1
            continue
        if body.max_novels is not None and generations >= body.max_novels:
            break
        try:
            svc.generate_and_save(nid, generated_by="admin_batch")
            processed += 1
            generations += 1
        except Exception as exc:
            failed += 1
            errors.append({"novel_id": nid, "title": n.get("title"), "error": str(exc)})
        if body.sleep_seconds > 0:
            time.sleep(body.sleep_seconds)

    return {
        "status": "success",
        "processed": processed,
        "skipped": skipped,
        "failed": failed,
        "errors": errors,
    }
