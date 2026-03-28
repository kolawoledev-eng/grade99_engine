-- Popularity / importance ordering for subject lists (lower = earlier in the app).
-- Defaults: unmigrated rows stay at 500; alphabetical tie-break handled in API.

alter table subjects
  add column if not exists display_rank int not null default 500;

alter table institution_subjects
  add column if not exists display_rank int not null default 500;

alter table syllabus_topics
  add column if not exists display_rank int not null default 500;

-- ---------------------------------------------------------------------------
-- JAMB: Use of English first, core sciences & socials, then languages & electives
-- ---------------------------------------------------------------------------
update subjects s
set display_rank = v.rank
from exams e,
(values
  ('Use of English', 10),
  ('English', 20),
  ('Mathematics', 30),
  ('Biology', 40),
  ('Chemistry', 50),
  ('Physics', 60),
  ('Economics', 70),
  ('Government', 80),
  ('Literature in English', 90),
  ('Principles of Accounts', 100),
  ('Commerce', 110),
  ('Islamic Religious Studies', 120),
  ('Christian Religious Knowledge', 130),
  ('Agricultural Science', 140),
  ('Computer Studies', 150),
  ('History', 160),
  ('Geography', 170),
  ('French', 180),
  ('Igbo', 190),
  ('Yoruba', 200),
  ('Hausa', 210),
  ('Arabic', 220),
  ('Art (Fine Art)', 230),
  ('Home Economics', 240),
  ('Music', 250),
  ('Physical and Health Education', 260)
) as v(subject_name, rank)
where e.id = s.exam_id
  and e.name = 'JAMB'
  and s.name = v.subject_name;

-- ---------------------------------------------------------------------------
-- WAEC: user-priority cluster (sciences, accounts, bio, lit, civic…) then rest
-- ---------------------------------------------------------------------------
update subjects s
set display_rank = v.rank
from exams e,
(values
  ('Physics', 10),
  ('Principles of Accounts', 20),
  ('Biology', 30),
  ('Literature in English', 40),
  ('Civic Education', 50),
  ('English Language', 60),
  ('Mathematics', 70),
  ('Chemistry', 80),
  ('Economics', 90),
  ('Government', 100),
  ('Further Mathematics', 110),
  ('Commerce', 120),
  ('Islamic Religious Studies', 130),
  ('Christian Religious Knowledge', 140),
  ('Agricultural Science', 150),
  ('Computer Studies', 160),
  ('History', 170),
  ('Geography', 180),
  ('French', 190),
  ('Igbo', 200),
  ('Hausa', 210),
  ('Yoruba', 220),
  ('Arabic', 230),
  ('Food and Nutrition', 240),
  ('Technical Drawing', 250),
  ('Visual Art', 260),
  ('Physical Education', 270),
  ('Health Education', 280)
) as v(subject_name, rank)
where e.id = s.exam_id
  and e.name = 'WAEC'
  and s.name = v.subject_name;

-- ---------------------------------------------------------------------------
-- NECO: mirror WAEC ordering
-- ---------------------------------------------------------------------------
update subjects s
set display_rank = v.rank
from exams e,
(values
  ('Physics', 10),
  ('Principles of Accounts', 20),
  ('Biology', 30),
  ('Literature in English', 40),
  ('Civic Education', 50),
  ('English Language', 60),
  ('Mathematics', 70),
  ('Chemistry', 80),
  ('Economics', 90),
  ('Government', 100),
  ('Further Mathematics', 110),
  ('Commerce', 120),
  ('Islamic Religious Studies', 130),
  ('Christian Religious Knowledge', 140),
  ('Agricultural Science', 150),
  ('Computer Studies', 160),
  ('History', 170),
  ('Geography', 180),
  ('French', 190),
  ('Igbo', 200),
  ('Hausa', 210),
  ('Yoruba', 220),
  ('Arabic', 230),
  ('Food and Nutrition', 240),
  ('Technical Drawing', 250),
  ('Visual Art', 260),
  ('Physical Education', 270),
  ('Health Education', 280)
) as v(subject_name, rank)
where e.id = s.exam_id
  and e.name = 'NECO'
  and s.name = v.subject_name;

-- ---------------------------------------------------------------------------
-- POST UTME institution subjects (all offerings): GK & core papers first
-- ---------------------------------------------------------------------------
update institution_subjects isu
set display_rank = v.rank
from institution_exam_offerings o,
(values
  ('General Knowledge', 10),
  ('Current Affairs', 20),
  ('Use of English', 30),
  ('English', 40),
  ('Mathematics', 50),
  ('Physics', 60),
  ('Chemistry', 70),
  ('Biology', 80),
  ('Government', 90),
  ('Economics', 100),
  ('Commerce', 110),
  ('Principles of Accounts', 120),
  ('Literature in English', 130),
  ('Christian Religious Knowledge', 140),
  ('Islamic Religious Studies', 150),
  ('Geography', 160),
  ('History', 170),
  ('Computer Studies', 180),
  ('Agricultural Science', 190),
  ('Civic Education', 200)
) as v(subject_name, rank)
where isu.offering_id = o.id
  and o.exam_mode = 'post-utme'
  and isu.subject_name = v.subject_name;

-- ---------------------------------------------------------------------------
-- JUPEB: sciences & core socials first
-- ---------------------------------------------------------------------------
update institution_subjects isu
set display_rank = v.rank
from institution_exam_offerings o,
(values
  ('Mathematics', 10),
  ('Physics', 20),
  ('Chemistry', 30),
  ('Biology', 40),
  ('Economics', 50),
  ('Government', 60),
  ('Geography', 70),
  ('Accounting', 80),
  ('Business Studies', 90),
  ('Literature in English', 100),
  ('Christian Religious Studies', 110),
  ('Islamic Religious Studies', 120),
  ('French', 130),
  ('History', 140),
  ('Igbo', 150),
  ('Yoruba', 160),
  ('Music', 170),
  ('Visual Arts', 180)
) as v(subject_name, rank)
where isu.offering_id = o.id
  and o.exam_mode = 'jupeb'
  and isu.subject_name = v.subject_name;

-- The Lekki Headmaster (topic under JAMB English / Use of English) surfaces first after "All Topics" in API
update syllabus_topics st
set display_rank = 10
from subjects s
join exams e on e.id = s.exam_id
where st.subject_id = s.id
  and e.name = 'JAMB'
  and s.name in ('Use of English', 'English')
  and st.topic_name ilike '%Lekki Headmaster%';
