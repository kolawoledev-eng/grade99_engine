-- NECO subjects (mirror WAEC sample set for parity)
insert into subjects (exam_id, name)
select e.id, x.name
from exams e
cross join (values
  ('Mathematics'), ('English Language'), ('Physics'), ('Chemistry'), ('Biology'), ('Further Mathematics')
) as x(name)
where e.name = 'NECO'
on conflict (exam_id, name) do nothing;
