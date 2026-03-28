-- Broad subject catalog for JAMB, WAEC, NECO, POST UTME (all seeded institutions), JUPEB.
-- Names align with common JAMB/WAEC SSCE/JUPEB brochure wording. Re-run safe: ON CONFLICT DO NOTHING.

-- ---------------------------------------------------------------------------
-- JAMB (UTME) — approved subject areas + extras commonly listed in brochures
-- ---------------------------------------------------------------------------
insert into subjects (exam_id, name)
select e.id, x.name
from exams e
cross join (values
  ('Use of English'),
  ('Mathematics'),
  ('Physics'),
  ('Chemistry'),
  ('Biology'),
  ('Economics'),
  ('Government'),
  ('Literature in English'),
  ('Principles of Accounts'),
  ('Commerce'),
  ('Islamic Religious Studies'),
  ('Agricultural Science'),
  ('Computer Studies'),
  ('History'),
  ('French'),
  ('Yoruba'),
  ('Hausa'),
  ('Christian Religious Knowledge'),
  ('Geography'),
  ('Igbo'),
  ('Arabic'),
  ('Art (Fine Art)'),
  ('Home Economics'),
  ('Music'),
  ('Physical and Health Education')
) as x(name)
where e.name = 'JAMB'
on conflict (exam_id, name) do nothing;

-- Recommended reading / novel focus as a syllabus topic under Use of English (not a separate UTME subject).
insert into syllabus_topics (subject_id, topic_name, year)
select s.id, 'The Lekki Headmaster (recommended reading)', 2025
from subjects s
join exams e on e.id = s.exam_id
where e.name = 'JAMB' and s.name = 'Use of English'
on conflict (subject_id, topic_name, year) do nothing;

-- If DB still has legacy JAMB row "English" only, add the same novel topic there for continuity.
insert into syllabus_topics (subject_id, topic_name, year)
select s.id, 'The Lekki Headmaster (recommended reading)', 2025
from subjects s
join exams e on e.id = s.exam_id
where e.name = 'JAMB' and s.name = 'English'
on conflict (subject_id, topic_name, year) do nothing;

-- ---------------------------------------------------------------------------
-- WAEC (SSCE) — core + common electives
-- ---------------------------------------------------------------------------
insert into subjects (exam_id, name)
select e.id, x.name
from exams e
cross join (values
  ('English Language'),
  ('Civic Education'),
  ('Mathematics'),
  ('Further Mathematics'),
  ('Physics'),
  ('Chemistry'),
  ('Biology'),
  ('Economics'),
  ('Government'),
  ('Literature in English'),
  ('Principles of Accounts'),
  ('Commerce'),
  ('Islamic Religious Studies'),
  ('Christian Religious Knowledge'),
  ('Agricultural Science'),
  ('Computer Studies'),
  ('History'),
  ('Geography'),
  ('French'),
  ('Igbo'),
  ('Hausa'),
  ('Yoruba'),
  ('Arabic'),
  ('Food and Nutrition'),
  ('Technical Drawing'),
  ('Visual Art'),
  ('Physical Education'),
  ('Health Education')
) as x(name)
where e.name = 'WAEC'
on conflict (exam_id, name) do nothing;

-- ---------------------------------------------------------------------------
-- NECO (SSCE) — mirror WAEC-style offering for app parity
-- ---------------------------------------------------------------------------
insert into subjects (exam_id, name)
select e.id, x.name
from exams e
cross join (values
  ('English Language'),
  ('Civic Education'),
  ('Mathematics'),
  ('Further Mathematics'),
  ('Physics'),
  ('Chemistry'),
  ('Biology'),
  ('Economics'),
  ('Government'),
  ('Literature in English'),
  ('Principles of Accounts'),
  ('Commerce'),
  ('Islamic Religious Studies'),
  ('Christian Religious Knowledge'),
  ('Agricultural Science'),
  ('Computer Studies'),
  ('History'),
  ('Geography'),
  ('French'),
  ('Igbo'),
  ('Hausa'),
  ('Yoruba'),
  ('Arabic'),
  ('Food and Nutrition'),
  ('Technical Drawing'),
  ('Visual Art'),
  ('Physical Education'),
  ('Health Education')
) as x(name)
where e.name = 'NECO'
on conflict (exam_id, name) do nothing;

-- ---------------------------------------------------------------------------
-- POST UTME — superset applied to each institution offering (real schools vary;
--             add per-institution rows later; General Knowledge kept.)
-- ---------------------------------------------------------------------------
insert into institution_subjects (offering_id, subject_name)
select o.id, s.subject_name
from institution_exam_offerings o
cross join (values
  ('Use of English'),
  ('English'),
  ('Mathematics'),
  ('Physics'),
  ('Chemistry'),
  ('Biology'),
  ('Government'),
  ('Economics'),
  ('Commerce'),
  ('Principles of Accounts'),
  ('Literature in English'),
  ('Christian Religious Knowledge'),
  ('Islamic Religious Studies'),
  ('Geography'),
  ('History'),
  ('Computer Studies'),
  ('Agricultural Science'),
  ('Civic Education'),
  ('Current Affairs'),
  ('General Knowledge')
) as s(subject_name)
where o.exam_mode = 'post-utme' and o.year = 2025
on conflict (offering_id, subject_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — board-style subjects (≈19 areas; names normalized for one app list)
-- ---------------------------------------------------------------------------
insert into institution_subjects (offering_id, subject_name)
select o.id, s.subject_name
from institution_exam_offerings o
cross join (values
  ('Mathematics'),
  ('Physics'),
  ('Chemistry'),
  ('Biology'),
  ('Agricultural Science'),
  ('Economics'),
  ('Government'),
  ('Geography'),
  ('Accounting'),
  ('Business Studies'),
  ('Christian Religious Studies'),
  ('Islamic Religious Studies'),
  ('Literature in English'),
  ('French'),
  ('History'),
  ('Igbo'),
  ('Yoruba'),
  ('Music'),
  ('Visual Arts')
) as s(subject_name)
where o.exam_mode = 'jupeb' and o.year = 2025
on conflict (offering_id, subject_name) do nothing;
