from __future__ import annotations

from typing import Any, Dict

from fastapi import APIRouter, HTTPException

from app.features.novel_recommendation.literature_repository import LiteratureRepository

router = APIRouter(prefix="/api/novels", tags=["literature"])


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
        return {
            "status": "success",
            "novel": novel,
            "section_count": summary.get("section_count"),
            "sections": summary.get("sections"),
            "created_at": summary.get("created_at"),
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
