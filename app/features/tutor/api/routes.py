from __future__ import annotations

from fastapi import APIRouter, HTTPException

from app.features.tutor.schemas import TutorChatRequest, TutorChatResponse
from app.features.tutor.service import TutorService

router = APIRouter(prefix="/api/tutor", tags=["tutor"])


@router.post("/chat", response_model=TutorChatResponse)
async def tutor_chat(payload: TutorChatRequest) -> TutorChatResponse:
    """
    Scoped AI tutor for the current exam/subject (optional question context).
    Does not perform web search; for in-app study help only.
    """
    try:
        svc = TutorService()
        reply = svc.chat(payload)
        return TutorChatResponse(reply=reply)
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
