from __future__ import annotations

from typing import Any, Dict, List, Optional

from app.core.db import get_supabase_client


class LiteratureRepository:
    def list_novels(self) -> List[Dict[str, Any]]:
        rows = (
            get_supabase_client()
            .table("literature_novels")
            .select("id,slug,title,author,popularity_rank")
            .order("popularity_rank")
            .execute()
            .data
        )
        return list(rows or [])

    def get_novel(self, novel_id: int) -> Optional[Dict[str, Any]]:
        res = (
            get_supabase_client()
            .table("literature_novels")
            .select("id,slug,title,author,popularity_rank")
            .eq("id", novel_id)
            .limit(1)
            .execute()
        )
        if not res.data:
            return None
        return res.data[0]

    def list_source_chapters(self, novel_id: int) -> List[Dict[str, Any]]:
        res = (
            get_supabase_client()
            .table("literature_novel_chapters")
            .select("chapter_number,chapter_title,source_text")
            .eq("novel_id", novel_id)
            .eq("is_approved", True)
            .order("chapter_number")
            .execute()
        )
        return list(res.data or [])

    def get_summary_for_novel(self, novel_id: int) -> Optional[Dict[str, Any]]:
        res = (
            get_supabase_client()
            .table("novel_summaries")
            .select("id,novel_id,sections,section_count,created_at")
            .eq("novel_id", novel_id)
            .limit(1)
            .execute()
        )
        if not res.data:
            return None
        return res.data[0]

    def insert_summary(
        self,
        novel_id: int,
        sections: List[Dict[str, Any]],
        total_in: int,
        total_out: int,
        total_cost: float,
        generated_by: str = "claude",
    ) -> Dict[str, Any]:
        row = {
            "novel_id": novel_id,
            "sections": sections,
            "section_count": len(sections),
            "total_input_tokens": total_in,
            "total_output_tokens": total_out,
            "total_cost": total_cost,
            "generated_by": generated_by,
        }
        ins = get_supabase_client().table("novel_summaries").insert(row).execute()
        if not ins.data:
            raise RuntimeError("Failed to insert novel summary")
        return ins.data[0]

    def replace_source_chapters(
        self,
        novel_id: int,
        chapters: List[Dict[str, Any]],
        source_ref: Optional[str] = None,
    ) -> Dict[str, Any]:
        table = get_supabase_client().table("literature_novel_chapters")
        table.delete().eq("novel_id", novel_id).execute()

        rows: List[Dict[str, Any]] = []
        for ch in chapters:
            rows.append(
                {
                    "novel_id": novel_id,
                    "chapter_number": int(ch["chapter_number"]),
                    "chapter_title": str(ch["chapter_title"]).strip(),
                    "source_text": str(ch["source_text"]).strip(),
                    "is_approved": bool(ch.get("is_approved", True)),
                    "source_ref": source_ref,
                }
            )
        if rows:
            table.insert(rows).execute()
        approved = sum(1 for r in rows if r.get("is_approved"))
        return {"inserted": len(rows), "approved": approved}
