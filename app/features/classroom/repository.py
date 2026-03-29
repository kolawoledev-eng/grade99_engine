from __future__ import annotations

from typing import Any, Dict, List, Optional

from app.core.db import get_supabase_client


class ClassroomTopicPagesRepository:
    def list_pages_for_subject(self, exam: str, year: int, subject: str) -> List[Dict[str, Any]]:
        ex = exam.upper().strip()
        rows = (
            get_supabase_client()
            .table("classroom_topic_pages")
            .select("*")
            .eq("exam", ex)
            .eq("year", year)
            .eq("subject", subject)
            .execute()
            .data
        )
        return list(rows or [])

    def get_page(self, exam: str, year: int, subject: str, topic: str) -> Optional[Dict[str, Any]]:
        ex = exam.upper().strip()
        res = (
            get_supabase_client()
            .table("classroom_topic_pages")
            .select("*")
            .eq("exam", ex)
            .eq("year", year)
            .eq("subject", subject)
            .eq("topic", topic)
            .limit(1)
            .execute()
        )
        if not res.data:
            return None
        return res.data[0]

    def delete_page(self, exam: str, year: int, subject: str, topic: str) -> None:
        ex = exam.upper().strip()
        get_supabase_client().table("classroom_topic_pages").delete().eq("exam", ex).eq("year", year).eq(
            "subject", subject
        ).eq("topic", topic).execute()

    def upsert_page(
        self,
        exam: str,
        year: int,
        subject: str,
        topic: str,
        sequence_number: int,
        sections: List[Dict[str, Any]],
        total_in: int,
        total_out: int,
        total_cost: float,
        generated_by: str = "claude",
    ) -> Dict[str, Any]:
        ex = exam.upper().strip()
        row = {
            "exam": ex,
            "year": year,
            "subject": subject,
            "topic": topic,
            "sequence_number": sequence_number,
            "sections": sections,
            "total_input_tokens": total_in,
            "total_output_tokens": total_out,
            "total_cost": total_cost,
            "generated_by": generated_by,
        }
        supabase = get_supabase_client()
        supabase.table("classroom_topic_pages").delete().eq("exam", ex).eq("year", year).eq(
            "subject", subject
        ).eq("topic", topic).execute()
        ins = supabase.table("classroom_topic_pages").insert(row).execute()
        if not ins.data:
            raise RuntimeError("Failed to save classroom topic page")
        return ins.data[0]
