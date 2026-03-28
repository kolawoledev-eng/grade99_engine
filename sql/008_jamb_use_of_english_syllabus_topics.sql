-- Canonical syllabus-area rows for JAMB Use of English (and legacy "English") across years
-- the app queries (2024 syllabus year, 2025 default filter, 2026 forward).
-- Matches app focus chips: set text, comprehension, lexis & structure, oral English.
-- Re-run safe: upserts display_rank only on conflict.

insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, v.topic_name, v.yr, v.display_rank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('The Lekki Headmaster (recommended reading)', 2024, 10),
  ('The Lekki Headmaster (recommended reading)', 2025, 10),
  ('The Lekki Headmaster (recommended reading)', 2026, 10),
  ('Comprehension', 2024, 20),
  ('Comprehension', 2025, 20),
  ('Comprehension', 2026, 20),
  ('Lexis and Structure', 2024, 30),
  ('Lexis and Structure', 2025, 30),
  ('Lexis and Structure', 2026, 30),
  ('Oral English', 2024, 40),
  ('Oral English', 2025, 40),
  ('Oral English', 2026, 40)
) as v(topic_name, yr, display_rank)
where e.name = 'JAMB' and s.name = 'Use of English'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;

insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, v.topic_name, v.yr, v.display_rank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('The Lekki Headmaster (recommended reading)', 2024, 10),
  ('The Lekki Headmaster (recommended reading)', 2025, 10),
  ('The Lekki Headmaster (recommended reading)', 2026, 10),
  ('Comprehension', 2024, 20),
  ('Comprehension', 2025, 20),
  ('Comprehension', 2026, 20),
  ('Lexis and Structure', 2024, 30),
  ('Lexis and Structure', 2025, 30),
  ('Lexis and Structure', 2026, 30),
  ('Oral English', 2024, 40),
  ('Oral English', 2025, 40),
  ('Oral English', 2026, 40)
) as v(topic_name, yr, display_rank)
where e.name = 'JAMB' and s.name = 'English'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;
