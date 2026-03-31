-- Approved chapter-source storage for literature summaries.
-- Phase 2: when source text is available, summarize per real chapter number/title.

create table if not exists literature_novel_chapters (
  id bigserial primary key,
  novel_id bigint not null references literature_novels(id) on delete cascade,
  chapter_number int not null,
  chapter_title text not null,
  source_text text not null,
  is_approved boolean not null default false,
  source_ref text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (novel_id, chapter_number)
);

create index if not exists idx_lit_novel_chapters_novel_num
  on literature_novel_chapters(novel_id, chapter_number);

create index if not exists idx_lit_novel_chapters_approved
  on literature_novel_chapters(novel_id, is_approved);
