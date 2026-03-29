-- Replace JAMB History syllabus topics with the 23-topic seed (see 010).
-- Run after 010 if your database still has the older 7-topic History rows.

delete from syllabus_topics st
using subjects s
join exams e on e.id = s.exam_id
where st.subject_id = s.id
  and e.name = 'JAMB'
  and s.name = 'History'
  and st.year in (2024, 2025, 2026);

insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('The Nigeria area up to 1800: early centres of civilization', 10),
  ('Kanem-Bornu, Hausaland and trans-Saharan trade', 20),
  ('The Sokoto Jihad and the caliphate system', 30),
  ('The Oyo Empire and Yoruba political order', 40),
  ('The Benin Kingdom and the Niger Delta', 50),
  ('European contact and the Atlantic slave trade', 60),
  ('Colonial conquest and the amalgamation of Nigeria', 70),
  ('Indirect rule and colonial administration in Nigeria', 80),
  ('Nationalism and constitutional development (1922–1945)', 90),
  ('Nigeria 1945–1960: decolonisation and independence', 100),
  ('The First Republic and the crises of 1960–1966', 110),
  ('The Nigerian Civil War (1967–1970)', 120),
  ('Military regimes and economic restructuring', 130),
  ('The Fourth Republic and contemporary Nigeria (1999–present)', 140),
  ('West Africa since 1800 (Ghana, Senegal, etc.)', 150),
  ('North Africa: Egypt, Maghreb and decolonisation', 160),
  ('East Africa: Ethiopia, Kenya, Tanzania and Uganda', 170),
  ('Southern Africa: apartheid and liberation movements', 180),
  ('Central Africa and the Congo region', 190),
  ('Imperialism, colonialism and resistance in Africa', 200),
  ('Pan-Africanism and the OAU/AU', 210),
  ('Africa during the Cold War', 220),
  ('Africa in the global economy and globalisation', 230)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'History'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;
