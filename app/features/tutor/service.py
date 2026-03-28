from __future__ import annotations

from typing import List

import anthropic

from app.config import get_settings

from .schemas import QuestionContext, TutorChatRequest


class TutorService:
    """Scoped exam tutor: no web search; answers in Nigerian exam prep context only."""

    def __init__(self) -> None:
        settings = get_settings()
        self._client = anthropic.Anthropic(api_key=settings.anthropic_api_key)
        self._model = settings.anthropic_model

    def _question_block(self, q: QuestionContext) -> str:
        parts = [
            f"Question: {q.question_text}",
            f"A) {q.option_a}",
            f"B) {q.option_b}",
            f"C) {q.option_c}",
            f"D) {q.option_d}",
            f"Marked correct letter: {q.correct_answer}",
        ]
        if q.topic:
            parts.append(f"Syllabus topic: {q.topic}")
        return "\n".join(parts)

    def chat(self, req: TutorChatRequest) -> str:
        system = (
            "You are a patient tutor for Nigerian secondary students preparing for "
            f"{req.exam.upper()} in {req.subject}. "
            "Use clear English. Stay on syllabus-level explanations. "
            "Do not claim to browse the internet. "
            "If the student asks for anything unrelated to studying or exams, politely redirect. "
            "Keep answers focused; use short headings or bullets when helpful."
        )
        user_parts: List[str] = [
            f"Exam: {req.exam.upper()}",
            f"Subject: {req.subject}",
        ]
        if req.topic:
            user_parts.append(f"Topic focus: {req.topic}")
        if req.question:
            user_parts.append("Current question context:\n" + self._question_block(req.question))
        user_parts.append(f"Student message:\n{req.user_message}")

        user_content = "\n\n".join(user_parts)

        resp = self._client.messages.create(
            model=self._model,
            max_tokens=1800,
            temperature=0.4,
            system=system,
            messages=[{"role": "user", "content": user_content}],
        )
        text = ""
        for block in resp.content:
            if hasattr(block, "text"):
                text += block.text
        text = text.strip()
        if not text:
            raise RuntimeError("Empty model response")
        return text
