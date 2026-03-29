-- Parent/child syllabus topics (e.g. JAMB Biology: five areas → key subtopics for Classrooms).

alter table syllabus_topics
  add column if not exists parent_id bigint references syllabus_topics (id) on delete cascade;

create index if not exists idx_syllabus_topics_parent_id on syllabus_topics (parent_id)
  where parent_id is not null;

comment on column syllabus_topics.parent_id is
  'Null = top-level syllabus area; set for granular topics shown under that area in Classrooms.';
