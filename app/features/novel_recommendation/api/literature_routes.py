from __future__ import annotations

from typing import Any, Dict

from fastapi import APIRouter, Depends, HTTPException

from app.core.generate_key_auth import verify_optional_generate_key
from app.features.novel_recommendation.literature_repository import LiteratureRepository
from app.features.novel_recommendation.literature_summary_service import LiteratureSummaryService

router = APIRouter(prefix="/api/novels", tags=["literature"])


def _summary_payload(novel: Dict[str, Any], summary: Dict[str, Any], ensure_status: str) -> Dict[str, Any]:
    return {
        "status": "success",
        "novel": novel,
        "section_count": summary.get("section_count"),
        "sections": summary.get("sections"),
        "created_at": summary.get("created_at"),
        "ensure_status": ensure_status,
    }


@router.get("/literature")
async def list_literature_novels() -> Dict[str, Any]:
    try:
        rows = LiteratureRepository().list_novels()
        return {"status": "success", "count": len(rows), "novels": rows}
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.get("/literature/{novel_id}/summary")
async def get_literature_summary(novel_id: int) -> Dict[str, Any]:
    repo = LiteratureRepository()
    try:
        novel = repo.get_novel(novel_id)
        if not novel:
            raise HTTPException(status_code=404, detail="Novel not found")
        summary = repo.get_summary_for_novel(novel_id)
        if not summary:
            raise HTTPException(
                status_code=404,
                detail="Summary not generated yet. Ask an admin to run generate for this title.",
            )
        return _summary_payload(novel, summary, ensure_status="cached")
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@router.post(
    "/literature/{novel_id}/ensure-summary",
    dependencies=[Depends(verify_optional_generate_key)],
)
async def ensure_literature_summary(novel_id: int) -> Dict[str, Any]:
    """Generate novel summary if missing (Claude), else return DB row. Idempotent."""
    repo = LiteratureRepository()
    try:
        novel = repo.get_novel(novel_id)
        if not novel:
            raise HTTPException(status_code=404, detail="Novel not found")
        existing = repo.get_summary_for_novel(novel_id)
        if existing:
            return _summary_payload(novel, existing, ensure_status="cached")
        result = LiteratureSummaryService().generate_and_save(novel_id, generated_by="app_ensure")
        summary = result.get("summary")
        if not summary:
            summary = repo.get_summary_for_novel(novel_id)
        if not summary:
            raise HTTPException(status_code=500, detail="Generation finished but summary not found")
        ensure_status = "cached" if result.get("status") == "already_exists" else "created"
        return _summary_payload(novel, summary, ensure_status=ensure_status)
    except HTTPException:
        raise
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
