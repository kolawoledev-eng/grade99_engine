from __future__ import annotations

from typing import Any, Dict

from app.core.db import get_supabase_client


class TopicsRepository:
    """Supabase/PostgREST chained `.order()` is unreliable for multi-column sort; we sort in Python."""

    @staticmethod
    def _sort_subject_rows(rows: list[Dict[str, Any]] | None) -> list[Dict[str, Any]]:
        out = list(rows or [])

        def key(r: Dict[str, Any]) -> tuple[int, str]:
            try:
                rank = int(r.get("display_rank", 500))
            except (TypeError, ValueError):
                rank = 500
            return (rank, (r.get("name") or "").lower())

        out.sort(key=key)
        return out

    @staticmethod
    def _sort_topic_rows(rows: list[Dict[str, Any]] | None) -> list[Dict[str, Any]]:
        out = list(rows or [])

        def key(t: Dict[str, Any]) -> tuple[int, str]:
            try:
                rank = int(t.get("display_rank", 500))
            except (TypeError, ValueError):
                rank = 500
            return (rank, (t.get("topic_name") or "").lower())

        out.sort(key=key)
        return out

    def list_exams(self) -> list[Dict[str, Any]]:
        return get_supabase_client().table("exams").select("*").order("name").execute().data

    def _get_exam_id(self, exam: str) -> int:
        res = get_supabase_client().table("exams").select("id").eq("name", exam.upper()).limit(1).execute()
        if not res.data:
            raise ValueError(f"Exam '{exam}' not found")
        return res.data[0]["id"]

    def list_subjects(self, exam: str) -> list[Dict[str, Any]]:
        exam_id = self._get_exam_id(exam)
        rows = (
            get_supabase_client()
            .table("subjects")
            .select("id,name,display_rank")
            .eq("exam_id", exam_id)
            .execute()
            .data
        )
        rows = self._sort_subject_rows(rows)
        return [
            {
                "id": r["id"],
                "name": r["name"],
                "display_rank": int(r.get("display_rank") or 500),
            }
            for r in rows
        ]

    def list_topics(self, exam: str, year: int, subject: str) -> list[Dict[str, Any]]:
        exam_id = self._get_exam_id(exam)
        sub = (
            get_supabase_client()
            .table("subjects")
            .select("id")
            .eq("exam_id", exam_id)
            .eq("name", subject)
            .limit(1)
            .execute()
        )
        if not sub.data:
            raise ValueError(f"Subject '{subject}' not found under '{exam}'")
        subject_id = sub.data[0]["id"]
        topics = (
            get_supabase_client()
            .table("syllabus_topics")
            .select("id,topic_name,year,display_rank")
            .eq("subject_id", subject_id)
            .eq("year", year)
            .execute()
            .data
        )
        topics = self._sort_topic_rows(topics)
        slim = [{"id": t["id"], "topic_name": t["topic_name"], "year": t["year"]} for t in topics]
        return [{"id": 0, "topic_name": "All Topics", "year": year}] + slim

