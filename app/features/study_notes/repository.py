from __future__ import annotations

from typing import Any, Dict, Optional

from app.core.db import get_supabase_client


class StudyNotesRepository:
    def list_notes(
        self,
        exam: str,
        year: int,
        subject: str,
        topic: Optional[str] = None,
        limit: int = 100,
    ) -> list[Dict[str, Any]]:
        query = (
            get_supabase_client()
            .table("study_notes")
            .select("*")
            .eq("exam", exam.upper())
            .eq("year", year)
            .eq("subject", subject)
        )
        if topic:
            query = query.eq("topic", topic)
        return query.order("sequence_number").limit(limit).execute().data

    def get_note_set(self, note_set_id: str) -> tuple[Dict[str, Any], list[Dict[str, Any]]]:
        supabase = get_supabase_client()
        set_res = supabase.table("study_note_sets").select("*").eq("id", note_set_id).limit(1).execute()
        if not set_res.data:
            raise ValueError("Study note set not found")
        note_set = set_res.data[0]
        notes = (
            supabase.table("study_notes")
            .select("*")
            .eq("note_set_id", note_set_id)
            .order("sequence_number")
            .execute()
            .data
        )
        return note_set, notes

    def has_notes_for_topic(
        self,
        exam: str,
        year: int,
        subject: str,
        topic: str,
    ) -> bool:
        supabase = get_supabase_client()
        ex = exam.upper().strip()
        res = (
            supabase.table("study_note_sets")
            .select("id")
            .eq("exam", ex)
            .eq("year", year)
            .eq("subject", subject)
            .eq("topic", topic)
            .limit(1)
            .execute()
        )
        return bool(res.data)

    def delete_notes_for_topic(
        self,
        exam: str,
        year: int,
        subject: str,
        topic: str,
    ) -> int:
        """Delete all study_note_sets for this scope; study_notes rows cascade."""
        supabase = get_supabase_client()
        ex = exam.upper().strip()
        sel = (
            supabase.table("study_note_sets")
            .select("id")
            .eq("exam", ex)
            .eq("year", year)
            .eq("subject", subject)
            .eq("topic", topic)
            .execute()
        )
        n = len(sel.data or [])
        if n == 0:
            return 0
        supabase.table("study_note_sets").delete().eq("exam", ex).eq("year", year).eq("subject", subject).eq(
            "topic", topic
        ).execute()
        return n

