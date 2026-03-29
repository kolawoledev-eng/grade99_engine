-- One-page revision per syllabus topic (JAMB classroom); Claude generates once, app reads from DB.

create table if not exists classroom_topic_pages (
  id uuid primary key default gen_random_uuid(),
  exam varchar(50) not null,
  year int not null,
  subject varchar(100) not null,
  topic varchar(200) not null,
  sequence_number int not null,
  sections jsonb not null,
  total_input_tokens int,
  total_output_tokens int,
  total_cost numeric(12, 6),
  generated_by text default 'claude',
  created_at timestamptz default now(),
  unique (exam, year, subject, topic)
);

create index if not exists idx_classroom_topic_pages_lookup
  on classroom_topic_pages(exam, year, subject);
