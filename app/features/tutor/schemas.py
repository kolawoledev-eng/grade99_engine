from __future__ import annotations

from typing import Any, Dict, Optional

from pydantic import BaseModel, Field


class QuestionContext(BaseModel):
    question_text: str = ""
    option_a: str = ""
    option_b: str = ""
    option_c: str = ""
    option_d: str = ""
    correct_answer: str = ""
    topic: Optional[str] = None


class TutorChatRequest(BaseModel):
    exam: str = Field(..., min_length=1, max_length=50)
    subject: str = Field(..., min_length=1, max_length=120)
    user_message: str = Field(..., min_length=1, max_length=4000)
    topic: Optional[str] = Field(default=None, max_length=200)
    question: Optional[QuestionContext] = None


class TutorChatResponse(BaseModel):
    status: str = "success"
    reply: str
