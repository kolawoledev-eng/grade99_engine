"""
One-time Claude generation per literature text; results stored in novel_summaries.
Public API reads only from DB — no repeat LLM calls after save.
"""

from __future__ import annotations

import json
import re
from decimal import Decimal
from typing import Any, Dict, List, Optional, Tuple

import anthropic

from app.config import get_settings
from app.features.novel_recommendation.literature_repository import LiteratureRepository

INPUT_TOKEN_PRICE_PER_1K = Decimal("0.003")
OUTPUT_TOKEN_PRICE_PER_1K = Decimal("0.015")
MAX_OUT = 8192


def _cost(inp: int, out: int) -> Decimal:
    return (Decimal(inp) / Decimal(1000)) * INPUT_TOKEN_PRICE_PER_1K + (
        Decimal(out) / Decimal(1000)
    ) * OUTPUT_TOKEN_PRICE_PER_1K


def _extract_json(raw: str) -> str:
    raw = raw.strip()
    m = re.search(r"```(?:json)?\s*([\s\S]*?)```", raw)
    if m:
        return m.group(1).strip()
    return raw


def _parse_sections(raw_text: str, min_need: int) -> List[Dict[str, str]]:
    text = _extract_json(raw_text)
    try:
        payload = json.loads(text)
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON from model: {e}") from e
    notes = payload.get("sections", [])
    if not isinstance(notes, list):
        raise ValueError("Model returned invalid sections format")
    out: List[Dict[str, str]] = []
    for item in notes:
        if not isinstance(item, dict):
            continue
        h = " ".join(str(item.get("heading", "")).split()).strip()
        b = str(item.get("body", "")).strip()
        if not h or len(b) < 80:
            continue
        out.append({"heading": h, "body": b})
    if len(out) < min_need:
        raise ValueError(f"Only {len(out)} valid sections, need at least {min_need}")
    return out


class LiteratureSummaryService:
    def __init__(self, model: Optional[str] = None) -> None:
        settings = get_settings()
        self.model = model or settings.anthropic_model
        self.client = anthropic.Anthropic(api_key=settings.anthropic_api_key)
        self.repo = LiteratureRepository()

    def _prompt_part(self, title: str, author: str, part_label: str, instructions: str) -> str:
        return f"""
You are helping Nigerian SS3 students preparing for JAMB Literature in English.

Work: **{title}** by **{author}**.

Audience: SS3 in Nigeria — write like a good Nigerian textbook / lesson note: clear paragraphs, logical sub-ideas,
and wording students hear in school. Use simple English; explain literary terms (e.g. metaphor, dramatic irony)
in one short phrase when they appear. Avoid exam-cram jargon stacks.

Be accurate to the text; do not invent plot or quotes you are unsure of.

{part_label}

{instructions}

Return **JSON only** (no markdown fences) with this shape:
{{
  "sections": [
    {{ "heading": "Short section title", "body": "Several paragraphs of plain text; use escaped newlines between paragraphs." }}
  ]
}}

Rules:
- Escape double quotes inside strings as \\".
- Each body should be substantial (roughly ½–1½ exam pages of reading if read aloud slowly).
- JSON must be complete and valid.
""".strip()

    def _call(self, prompt: str) -> Tuple[str, int, int]:
        resp = self.client.messages.create(
            model=self.model,
            max_tokens=MAX_OUT,
            temperature=0.35,
            messages=[{"role": "user", "content": prompt}],
        )
        raw = resp.content[0].text
        if getattr(resp, "stop_reason", None) == "max_tokens":
            raise ValueError("Output truncated (max_tokens); retry or split prompt further.")
        return raw, resp.usage.input_tokens, resp.usage.output_tokens

    def generate_and_save(self, novel_id: int, generated_by: str = "admin") -> Dict[str, Any]:
        novel = self.repo.get_novel(novel_id)
        if not novel:
            raise ValueError("Novel not found")
        existing = self.repo.get_summary_for_novel(novel_id)
        if existing:
            return {"status": "already_exists", "novel_id": novel_id, "summary": existing}

        title = str(novel["title"])
        author = str(novel["author"])

        p1 = self._prompt_part(
            title,
            author,
            "Part 1 of 2",
            """Produce exactly **5** sections:
1) What this text is (genre, form) and why it matters for JAMB.
2) Author / background students should remember.
3) Main characters OR speakers (who they are, role in the work).
4) Plot / content summary (part one — setup and rising action, or stanza-by-stanza for short poems).
5) Plot / content summary (part two — climax, ending, resolution).""",
        )
        raw1, in1, out1 = self._call(p1)
        sec1 = _parse_sections(raw1, min_need=4)

        p2 = self._prompt_part(
            title,
            author,
            "Part 2 of 2",
            f"""You already covered overview, author, characters, and plot in another message.
Now produce exactly **5** NEW sections (do not repeat earlier headings or re-summarize the same plot beat-by-beat):
6) Major themes and moral lessons.
7) Language, tone, imagery, and key symbols (as fits the text).
8) Notable quotations or lines to remember (paraphrase if exact wording uncertain).
9) How JAMB often sets questions on this text (question styles, what to compare).
10) Quick revision checklist (bullet-style sentences inside the body string).

Earlier section headings for reference only (do not duplicate): {", ".join(s["heading"] for s in sec1[:5])}""",
        )
        raw2, in2, out2 = self._call(p2)
        sec2 = _parse_sections(raw2, min_need=3)

        combined = sec1 + sec2
        for i, s in enumerate(combined, start=1):
            s["order"] = i

        total_in = in1 + in2
        total_out = out1 + out2
        cost = float(_cost(total_in, total_out))

        try:
            saved = self.repo.insert_summary(
                novel_id=novel_id,
                sections=combined,
                total_in=total_in,
                total_out=total_out,
                total_cost=cost,
                generated_by=generated_by,
            )
        except Exception:
            existing2 = self.repo.get_summary_for_novel(novel_id)
            if existing2:
                return {"status": "already_exists", "novel_id": novel_id, "summary": existing2}
            raise
        return {
            "status": "created",
            "novel_id": novel_id,
            "summary": saved,
            "usage": {"input_tokens": total_in, "output_tokens": total_out, "total_cost": cost},
        }
