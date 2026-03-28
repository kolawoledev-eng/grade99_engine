-- JUPEB subjects per institution offering (mirror post-UTME set)
insert into institution_subjects (offering_id, subject_name)
select o.id, s.subject_name
from institution_exam_offerings o
cross join (values
  ('English'),
  ('Mathematics'),
  ('Physics'),
  ('Chemistry'),
  ('Biology'),
  ('Government'),
  ('Economics'),
  ('Literature in English')
) as s(subject_name)
where o.exam_mode = 'jupeb' and o.year = 2025
on conflict (offering_id, subject_name) do nothing;
