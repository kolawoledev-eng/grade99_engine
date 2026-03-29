-- JAMB UTME: syllabus topic rows for all catalog subjects × years 2024–2026.
-- Topic/section names follow the official JAMB brochure (IBASS) structure.
-- Re-run safe: ON CONFLICT (subject_id, topic_name, year) DO UPDATE display_rank.
-- Supersedes/merges with previous version when the same topic_name + year exists.
--
-- Related migrations: WAEC/NECO → 011_waec_neco_ssce_syllabus_topics.sql;
-- Post-UTME & JUPEB institution topics → 012_post_utme_jupeb_institution_topics.sql.
--
-- CLASSROOM GRANULARITY (all JAMB subjects):
--   Each subject below has ~23–34 flat topic rows derived from the official JAMB
--   (IBASS) syllabus so Classrooms / study notes can target one row per Begin.
--   Re-run safe: ON CONFLICT updates display_rank; old topic_name rows not in this
--   file remain in DB until you delete them (see 015 for History cleanup pattern).
--   Reading text: "The Lekki Headmaster" (Kabir Alabi Garba) — update when JAMB changes novel.
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- Use of English + legacy English (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('The Lekki Headmaster – context, setting and characters (Kabir Alabi Garba)', 10),
  ('The Lekki Headmaster – themes, plot and narrative techniques', 20),
  ('Reading comprehension: literal meaning and factual recall', 30),
  ('Reading comprehension: inference, tone and attitude', 40),
  ('Summary skills: main ideas and précis techniques', 50),
  ('Registers and appropriacy (formal, informal, technical)', 60),
  ('Figures of speech and sound devices', 70),
  ('Word formation: prefixes, suffixes and roots', 80),
  ('Synonyms, antonyms and word classes in context', 90),
  ('Lexical cohesion and collocations', 100),
  ('Tenses, aspect and concord', 110),
  ('Clauses, phrases and sentence types', 120),
  ('Question tags, negation and modality', 130),
  ('Reported speech and direct speech', 140),
  ('Punctuation and mechanics', 150),
  ('Oral English: vowels, consonants and minimal pairs', 160),
  ('Stress patterns in words and sentences', 170),
  ('Intonation: falling, rising and attitudes', 180),
  ('Connected speech: elision, assimilation', 190),
  ('Test-taking: cloze and gap filling', 200),
  ('Test-taking: error identification and correction', 210),
  ('Essay and continuous writing (structure and coherence)', 220),
  ('Critical reading and evaluation of passages', 230),
  ('Vocabulary in academic and everyday contexts', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name in ('Use of English', 'English')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Mathematics (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Number bases and operations', 10),
  ('Fractions, decimals, percentages and approximations', 20),
  ('Indices, logarithms and surds', 30),
  ('Sets, Venn diagrams and applications', 40),
  ('Variation: direct, inverse and joint', 50),
  ('Algebraic expressions, factorisation and simplification', 60),
  ('Linear and quadratic equations', 70),
  ('Simultaneous equations and word problems', 80),
  ('Inequalities and number lines', 90),
  ('Sequences and series (AP and GP)', 100),
  ('Binary operations and simple functions', 110),
  ('Mensuration: plane shapes and solids', 120),
  ('Plane geometry: angles, polygons and circles', 130),
  ('Coordinate geometry: distance, midpoint, gradient', 140),
  ('Straight lines and equations of lines', 150),
  ('Trigonometry: ratios, identities and equations', 160),
  ('Bearings and simple heights and distances', 170),
  ('Differentiation: rules and applications', 180),
  ('Integration: basic techniques and applications', 190),
  ('Statistics: data presentation and measures of central tendency', 200),
  ('Probability: experiments and combined events', 210),
  ('Matrices and determinants (basic)', 220),
  ('Vectors (basic)', 230),
  ('Problem solving and exam-style applications', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Mathematics'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Physics (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Measurements, SI units and significant figures', 10),
  ('Scalars, vectors and vector resolution', 20),
  ('Linear motion: speed, velocity, acceleration', 30),
  ('Motion under gravity and projectiles', 40),
  ('Newton''s laws and equilibrium of forces', 50),
  ('Work, energy, power and conservation of energy', 60),
  ('Simple machines and mechanical advantage', 70),
  ('Elasticity: Hooke''s law and elastic potential energy', 80),
  ('Pressure in fluids and atmospheric pressure', 90),
  ('Temperature, heat capacity and latent heat', 100),
  ('Gas laws and kinetic theory of gases', 110),
  ('Heat transfer: conduction, convection, radiation', 120),
  ('Wave properties: reflection, refraction, diffraction', 130),
  ('Sound waves: beats, resonance, musical notes', 140),
  ('Light: reflection, mirrors and plane surfaces', 150),
  ('Refraction, lenses and optical instruments', 160),
  ('Electrostatics, electric field and capacitors', 170),
  ('Current electricity: Ohm''s law and resistivity', 180),
  ('Electrical energy, power and domestic wiring', 190),
  ('Magnetism, electromagnetic induction and generators', 200),
  ('Alternating current: RMS, transformers', 210),
  ('Photoelectric effect and quantum ideas', 220),
  ('Radioactivity, half-life and nuclear energy', 230),
  ('Electronics: semiconductors and simple circuits', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Physics'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Chemistry (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Introduction to chemistry and laboratory safety', 10),
  ('Separation of mixtures and purification', 20),
  ('Atomic structure: subatomic particles and electronic configuration', 30),
  ('Chemical bonding: ionic, covalent and metallic', 40),
  ('The periodic table and periodic properties', 50),
  ('Stoichiometry, mole concept and chemical equations', 60),
  ('States of matter and gas laws', 70),
  ('Acids, bases, salts and pH', 80),
  ('Oxidation numbers, redox and electrolysis', 90),
  ('Electrochemical cells and applications', 100),
  ('Enthalpy, energy diagrams and rates of reaction', 110),
  ('Chemical equilibrium and Le Chatelier''s principle', 120),
  ('Hydrogen, oxygen, nitrogen and halogens', 130),
  ('Sulphur, phosphorus, carbon and their compounds', 140),
  ('Alkali and alkaline earth metals', 150),
  ('Transition metals and extraction of metals', 160),
  ('Organic chemistry: alkanes, alkenes and alkynes', 170),
  ('Alcohols, aldehydes, ketones and carboxylic acids', 180),
  ('Esters, fats, oils and soaps', 190),
  ('Polymers, petrochemicals and environmental chemistry', 200),
  ('Nuclear chemistry and radioactivity', 210),
  ('Industrial chemistry and chemical industries', 220),
  ('Environmental chemistry and pollution', 230),
  ('Qualitative analysis and salt identification', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Chemistry'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Biology (34 granular topics — flat list; old 014 parent/child seed deprecated)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Characteristics of living organisms', 10),
  ('Cell theory and organisation of living things', 20),
  ('Classification systems and taxonomic hierarchy', 30),
  ('Kingdom Monera and Kingdom Protista', 40),
  ('Kingdom Fungi', 50),
  ('The plant kingdom (divisions overview)', 60),
  ('The animal kingdom (phyla overview)', 70),
  ('Cell structure and functions', 80),
  ('Cell division: mitosis and meiosis', 90),
  ('Nutrition in plants and animals', 100),
  ('Transport in plants and animals', 110),
  ('Respiration in plants and animals', 120),
  ('Excretion and osmoregulation', 130),
  ('Support, movement and locomotion', 140),
  ('Coordination and control: nervous and endocrine systems', 150),
  ('Ecological concepts, habitat and niche', 160),
  ('Components of ecosystems (biotic and abiotic)', 170),
  ('Food chains, food webs and trophic levels', 180),
  ('Ecological pyramids and energy flow', 190),
  ('Nutrient cycling (carbon, nitrogen, water)', 200),
  ('Ecological succession', 210),
  ('Pollution, conservation and environmental issues', 220),
  ('Mendelian inheritance and terminology', 230),
  ('Chromosomes, genes and DNA overview', 240),
  ('Monohybrid and dihybrid crosses', 250),
  ('Linkage, sex determination and sex-linked traits', 260),
  ('Variation, mutation and adaptation', 270),
  ('Blood groups and genetic applications', 280),
  ('Population genetics (basic principles)', 290),
  ('Lamarckism and Darwinism', 300),
  ('Evidence for evolution', 310),
  ('Theories and mechanisms of evolution', 320),
  ('Human evolution (outline)', 330),
  ('Natural selection and speciation', 340)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Biology'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Economics (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Scarcity, choice and opportunity cost', 10),
  ('Factors of production and production possibility frontier', 20),
  ('Types of economic systems', 30),
  ('The Nigerian economy: structure and sectors', 40),
  ('Demand: law, schedules and elasticity', 50),
  ('Supply: law, schedules and elasticity', 60),
  ('Price determination and consumer behaviour', 70),
  ('Theory of production: TP, AP, MP', 80),
  ('Costs of production: fixed, variable, total', 90),
  ('Market structures: perfect competition to monopoly', 100),
  ('National income: concepts and measurement', 110),
  ('Money: functions, demand and supply', 120),
  ('Banking and financial institutions in Nigeria', 130),
  ('Central banking and monetary policy', 140),
  ('Inflation: types, causes and control', 150),
  ('Unemployment: types and policies', 160),
  ('Business cycles and economic fluctuations', 170),
  ('Public finance: revenue, expenditure and taxes', 180),
  ('Fiscal policy and budget', 190),
  ('Economic growth vs development indicators', 200),
  ('Economic planning and development strategies', 210),
  ('International trade: theories and barriers', 220),
  ('Balance of payments and exchange rates', 230),
  ('Agricultural and industrial policy in Nigeria', 240),
  ('Population, labour force and economic development', 250)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Economics'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Government (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Definition, scope and functions of government', 10),
  ('Power, authority, legitimacy and sovereignty', 20),
  ('Nation, state and features of a state', 30),
  ('Forms of government: unitary, federal, confederal', 40),
  ('Presidential and parliamentary systems', 50),
  ('Separation of powers and checks and balances', 60),
  ('The legislature: structure and functions', 70),
  ('The executive: structure and functions', 80),
  ('The judiciary: independence and reforms', 90),
  ('Public administration and civil service', 100),
  ('Political parties, party systems and ideologies', 110),
  ('Electoral systems, franchise and electoral bodies', 120),
  ('Pressure groups and public opinion', 130),
  ('Pre-colonial political organisation in Nigeria', 140),
  ('Colonial administration and nationalist movements', 150),
  ('Nigerian constitutions from 1914 to 1999', 160),
  ('First, second and third republics', 170),
  ('Military rule and transition programmes', 180),
  ('Fourth Republic: institutions and challenges', 190),
  ('Local government: structure, functions and reforms', 200),
  ('Federal character and intergovernmental relations', 210),
  ('Nigeria''s foreign policy objectives and principles', 220),
  ('Nigeria in ECOWAS, AU, UN and Commonwealth', 230),
  ('International organisations: structure and roles', 240),
  ('Contemporary issues in Nigerian government', 250)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Government'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Literature in English (~24 granular topics; prescribed set texts change yearly)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Literature: genres, forms and functions', 10),
  ('Elements of fiction: plot, character, setting', 20),
  ('Point of view, narrative voice and conflict', 30),
  ('Theme, tone, mood and atmosphere', 40),
  ('Figurative language and imagery in prose and poetry', 50),
  ('Diction, rhythm and sound in poetry', 60),
  ('Literary devices: metaphor, simile, symbol, irony', 70),
  ('Drama: tragedy, comedy and dramatic techniques', 80),
  ('Dramatic irony, soliloquy, aside and dialogue', 90),
  ('Shakespearean and modern drama conventions', 100),
  ('African drama: themes and oral performance roots', 110),
  ('The novel and short story: structure and appreciation', 120),
  ('African prose fiction: context and major concerns', 130),
  ('Non-fiction prose and biographical writing', 140),
  ('Poetry: sonnet, ode, lyric, ballad and free verse', 150),
  ('African poetry: oral tradition and written verse', 160),
  ('Literary criticism: approaches and terminology', 170),
  ('Context: historical, social and political readings', 180),
  ('Comparing and contrasting texts', 190),
  ('Answering objective and context questions', 200),
  ('Unseen poetry and prose passages', 210),
  ('Prescribed drama: themes and character analysis', 220),
  ('Prescribed prose: themes and character analysis', 230),
  ('Prescribed poetry: themes and poetic techniques', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Literature in English'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Principles of Accounts (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Meaning, branches and users of accounting information', 10),
  ('Accounting concepts, conventions and policies', 20),
  ('The accounting equation and double entry', 30),
  ('Books of original entry: journals and ledgers', 40),
  ('Cash book, petty cash and imprest', 50),
  ('Bank reconciliation statements', 60),
  ('Control accounts and suspense accounts', 70),
  ('Errors: types, detection and correction', 80),
  ('Trial balance and limitations', 90),
  ('Accruals, prepayments and adjustments', 100),
  ('Bad debts, provisions and discounts', 110),
  ('Trading, profit and loss and balance sheet (sole trader)', 120),
  ('Depreciation methods and asset disposal accounts', 130),
  ('Incomplete records and statement of affairs', 140),
  ('Partnership: appropriation and changes in partners', 150),
  ('Admission, retirement and dissolution of partnership', 160),
  ('Limited companies: shares, debentures and reserves', 170),
  ('Company final accounts and published accounts', 180),
  ('Manufacturing accounts and work-in-progress', 190),
  ('Departmental and branch accounts (basic)', 200),
  ('Non-profit organisations: receipts and payments', 210),
  ('Income and expenditure accounts', 220),
  ('Public sector accounting: funds and votes', 230),
  ('Interpretation: ratios and simple analysis', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Principles of Accounts'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Commerce (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Introduction to commerce, trade and aids to trade', 10),
  ('Division of labour, specialisation and production', 20),
  ('Home trade: retail and wholesale', 30),
  ('Foreign trade: import, export and barriers', 40),
  ('Balance of trade and terms of trade (basic)', 50),
  ('Transport: modes, choice and documents', 60),
  ('Communication and postal services', 70),
  ('Warehousing: types and functions', 80),
  ('Insurance: principles, policies and claims', 90),
  ('Money, currency and exchange', 100),
  ('Commercial banks and central bank functions', 110),
  ('Other financial institutions and instruments', 120),
  ('Stock Exchange and capital market (basic)', 130),
  ('Advertising, sales promotion and packaging', 140),
  ('Public relations and branding', 150),
  ('Forms of business units: sole trader to company', 160),
  ('Cooperatives and public enterprises', 170),
  ('Commercial documents: invoice, bill of lading, etc.', 180),
  ('Market structure, marketing mix and distribution', 190),
  ('Consumer rights, protection and redress', 200),
  ('E-commerce, ICT and digital payments', 210),
  ('Business ethics and social responsibility', 220),
  ('Contract, agency and business law basics', 230),
  ('Entrepreneurship and small business management', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Commerce'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Islamic Studies (~24 granular topics; official name + legacy IRS name)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Revelation, compilation and themes of the Qur''an', 10),
  ('Study of selected surahs and passages', 20),
  ('Hadith: authenticity, collections and application', 30),
  ('Tawhid: rububiyyah, uluhiyyah and asma wa sifat', 40),
  ('Shirk and its forms', 50),
  ('Faith (Iman), pillars of Islam and Ihsan', 60),
  ('Taharah: types of purification and salah', 70),
  ('Zakah, Sawm and Hajj: rulings and wisdom', 80),
  ('Halal and haram: food, dress and transactions', 90),
  ('Marriage, family and inheritance (basic fiqh)', 100),
  ('Mu''amalat: trade, interest and contracts', 110),
  ('Islamic ethics and adab', 120),
  ('Sirah: Makkah period of the Prophet (SAW)', 130),
  ('Sirah: Madinah period and battles', 140),
  ('The Rightly Guided Caliphs', 150),
  ('Umayyad and Abbasid contributions', 160),
  ('Islam in West Africa: jihad and scholarship', 170),
  ('Colonialism and Islam in Nigeria', 180),
  ('Islamic education and institutions', 190),
  ('Contemporary Muslim organisations', 200),
  ('Islam and science, health and environment', 210),
  ('Da''wah and interfaith relations', 220),
  ('Major Islamic festivals and calendar', 230),
  ('Women in Islam: rights and responsibilities', 240),
  ('Revision: integrated themes across Qur''an, fiqh and history', 250)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name in ('Islamic Religious Studies', 'Islamic Studies')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Christian Religious Studies (~24 granular topics; CRS / CRK legacy names)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Creation, fall and the patriarchs', 10),
  ('Exodus, law and covenant at Sinai', 20),
  ('Conquest, judges and united monarchy', 30),
  ('Wisdom literature and the prophets (major)', 40),
  ('The divided kingdom and exile', 50),
  ('Return, restoration and intertestamental period', 60),
  ('Birth, baptism and early ministry of Jesus', 70),
  ('Parables, miracles and the Kingdom of God', 80),
  ('Passion, death and resurrection', 90),
  ('Ascension, Pentecost and the early church', 100),
  ('Paul''s missionary journeys and epistles', 110),
  ('General epistles and Revelation (themes)', 120),
  ('Faith, grace and salvation in the NT', 130),
  ('Christian worship, sacraments and prayer', 140),
  ('Christian ethics: family, work and society', 150),
  ('The Church: unity, mission and ecumenism', 160),
  ('Religious tolerance and citizenship', 170),
  ('Evil, suffering and theodicy', 180),
  ('African Indigenous Religion: comparison (basic)', 190),
  ('Call of Abraham to Joseph narratives (revision)', 200),
  ('Moses to Samuel narratives (revision)', 210),
  ('David to exile narratives (revision)', 220),
  ('Gospels harmony and synoptic themes', 230),
  ('Acts to Romans: church growth and doctrine', 240),
  ('Exam skills: objective and essay questions', 250)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB'
  and s.name in ('Christian Religious Knowledge', 'Christian Religious Studies', 'CRS')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Agricultural Science (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Meaning, importance and branches of agriculture', 10),
  ('Agricultural ecology and climatic zones of Nigeria', 20),
  ('Soil formation, profile and fertility', 30),
  ('Soil management: tillage, erosion and conservation', 40),
  ('Plant nutrients, manures and fertilisers', 50),
  ('Crop classification and farming systems', 60),
  ('Arable crop production: cereals and legumes', 70),
  ('Root and tuber crops; plantation crops', 80),
  ('Horticulture: fruits, vegetables and ornamentals', 90),
  ('Crop pests, diseases and their control', 100),
  ('Weeds and weed control', 110),
  ('Animal nutrition, feeds and feeding', 120),
  ('Ruminant and non-ruminant production', 130),
  ('Poultry production and management', 140),
  ('Fish farming and aquaculture (basic)', 150),
  ('Animal health, parasites and diseases', 160),
  ('Farm records and farm accounts (basic)', 170),
  ('Land tenure, labour and capital in agriculture', 180),
  ('Agricultural marketing and cooperatives', 190),
  ('Extension methods and communication', 200),
  ('Farm tools, machinery and maintenance', 210),
  ('Processing, storage and value addition', 220),
  ('Irrigation, drainage and water management', 230),
  ('Sustainable agriculture and climate-smart practices', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Agricultural Science'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Computer Studies (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('History and generations of computers', 10),
  ('Hardware: CPU, memory, input and output devices', 20),
  ('Software: system, application and utilities', 30),
  ('Data representation: binary, units and storage', 40),
  ('Operating systems and user interfaces', 50),
  ('File organisation, folders and backups', 60),
  ('Word processing and document design', 70),
  ('Spreadsheets: formulas, charts and functions', 80),
  ('Databases: tables, queries and reports (basic)', 90),
  ('Presentation graphics and multimedia', 100),
  ('Networking: LAN, WAN, internet and cloud (basic)', 110),
  ('Email, web and digital citizenship', 120),
  ('Computer viruses, malware and security practices', 130),
  ('Health, ergonomics and lab safety', 140),
  ('ICT in education, business and government', 150),
  ('Algorithms, flowcharts and pseudocode', 160),
  ('Programming concepts: variables, loops, decisions', 170),
  ('High-level languages and debugging (basic)', 180),
  ('Number systems and logic gates (basic)', 190),
  ('Artificial intelligence: concepts and applications', 200),
  ('Robotics and automation (basic)', 210),
  ('Data privacy, cybercrime and ethics', 220),
  ('Copyright, plagiarism and responsible use', 230),
  ('Emerging technologies and career paths', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Computer Studies'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- History (23 topics — Nigeria + Africa/wider world). Old DBs: run 015 to replace legacy 7.
-- ---------------------------------------------------------------------------
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


-- ---------------------------------------------------------------------------
-- French (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('French alphabet, accents and punctuation', 10),
  ('Pronunciation: vowels, consonants and liaison', 20),
  ('Numbers, dates, time and classroom expressions', 30),
  ('Articles, gender and plural of nouns', 40),
  ('Subject pronouns and present tense (être, avoir, -er verbs)', 50),
  ('Adjectives: agreement and position', 60),
  ('Negation, questions and interrogatives', 70),
  ('Prepositions of place, time and movement', 80),
  ('Past tenses: passé composé and imparfait (recognition)', 90),
  ('Future and conditional (basic patterns)', 100),
  ('Reflexive verbs and daily routine', 110),
  ('Possessive and demonstrative adjectives', 120),
  ('Comprehension: short passages and dialogues', 130),
  ('Translation: French to English (sentences)', 140),
  ('Translation: English to French (sentences)', 150),
  ('Lexis: family, school, health and environment', 160),
  ('Lexis: travel, food, culture and Francophonie', 170),
  ('Listening skills: sound discrimination', 180),
  ('Oral practice: guided conversation', 190),
  ('Civilisation: France and French-speaking Africa', 200),
  ('Idiomatic expressions and proverbs (basic)', 210),
  ('Reading strategies for unseen passages', 220),
  ('Writing: guided composition and messages', 230),
  ('Exam techniques: objective and structure items', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'French'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Yoruba (~24 granular topics: Ede, Litireso, Asa)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Gbolohun ati oruko oro (parts of speech)', 10),
  ('Eka-oro ati isapeye (word formation)', 20),
  ('Akojo oro ati itumo (vocabulary)', 30),
  ('Gbolohun oniyipada (syntax basics)', 40),
  ('Ohun elo ede (tones and orthography)', 50),
  ('Akopọ ati itumọ (composition and translation)', 60),
  ('Ìjínlẹ̀ ẹ̀sì (literary devices in Yoruba)', 70),
  ('Orin agbelewo ati owe (proverbs and songs)', 80),
  ('Ìtàn ati àlọ́ (oral narrative forms)', 90),
  ('Ẹ̀wì ati ijó (poetry and performance)', 100),
  ('Ìwé alàdìí (drama and dialogue)', 110),
  ('Onkọwe ati awọn iṣẹ-ọnà (authors and texts)', 120),
  ('Ìtumọ àti àyẹ̀wò ọ̀rọ̀ (literary criticism)', 130),
  ('Aṣà ìbílẹ̀: ìjọba ati ẹ̀tọ́ (customs and governance)', 140),
  ('Ìgbàgbọ́, ẹ̀sìn ati àjọyọ̀ (belief and festivals)', 150),
  ('Ìṣẹ̀lẹ̀ àti ojú-ọ̀nà (occupations and trades)', 160),
  ('Ẹ̀yà ara ati ìlera (health and body)', 170),
  ('Ìmọ̀ ẹ̀kọ́ ati ìmọ̀ ẹ̀rọ (education and media)', 180),
  ('Àṣà ìdàgbàsókè (social change)', 190),
  ('Ìbáṣepọ̀ pẹ̀lú àwọn ẹ̀dá mìíràn (intercultural)', 200),
  ('Ìwádìí ọ̀rọ̀ àti àṣà (research skills)', 210),
  ('Ìgbàyé àti ọjọ́-ọjọ́ (current affairs in Yoruba)', 220),
  ('Ìṣe àti ìmọ̀ ọ̀fẹ́ (oral examination practice)', 230),
  ('Ìṣẹ́-ìdánwò JAMB (exam techniques)', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Yoruba'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Hausa (~24 granular topics: Harshe, Al''adu, Adabi)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Tsarin rubutu da bambancin sautuka', 10),
  ('Sunaye da magana (nouns and pronouns)', 20),
  ('Aikatau da lokuta (verbs and tenses)', 30),
  ('Sifa da adverbs', 40),
  ('Jimloli da ma''ana (sentences and meaning)', 50),
  ('Fassara Hausa–Turanci (basic)', 60),
  ('Rubutu da sassaka (composition)', 70),
  ('Kalmomi da nahiya (vocabulary by theme)', 80),
  ('Adabin baka: wakoki da karin magana', 90),
  ('Tatsuniyoyi da labarai', 100),
  ('Wasan kwaikwayo da hirarun allo', 110),
  ('Rubutaccen adabi: gajerun labarai', 120),
  ('Sharhi da nazarin rubutu', 130),
  ('Al''ada da zamantakewa', 140),
  ('Addini da bikuna', 150),
  ('Sana''o''i da tattalin arziki', 160),
  ('Ilimi da fasaha', 170),
  ('Lafiya da muhalli', 180),
  ('Harkokin yau da kullun', 190),
  ('Dangantaka tsakanin al''ummomi', 200),
  ('Labarun yau da kullun a Hausa', 210),
  ('Bincike da amfani da littattafai', 220),
  ('Fahimtar rubutun bincike', 230),
  ('Shirye-shiryen jarrabawa JAMB', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Hausa'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Igbo (~24 granular topics: Asụsụ, Agụmagụ, Omenala)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Nkebiokwu na ụdị okwu (parts of speech)', 10),
  ('Ụdaume na mgbochiume (vowels and consonants)', 20),
  ('Ahịrịokwu na usoro (syntax)', 30),
  ('Akụkọfọdụ na njikọ okwu', 40),
  ('Njemụba na ntụgharị (translation)', 50),
  ('Njemụba edemede (composition)', 60),
  ('Okwuiche na akparamagwa (idioms and usage)', 70),
  ('Egwu na ilu (songs and proverbs)', 80),
  ('Akụkọ ọdịnala na akụkọ ife (oral literature)', 90),
  ('Egwu abụ na egwuregwu (poetry and drama)', 100),
  ('Njemụba ederede (written literature)', 110),
  ('Onye odeakwụkwọ na ọrụ ya', 120),
  ('Nlebara anya na ederede (literary analysis)', 130),
  ('Omenala na omume obodo', 140),
  ('Ekwemesịrị ụmụnna na ọchịchị', 150),
  ('Ọdịnala ekpere na emume', 160),
  ('Ọrụ aka na azụmahịa', 170),
  ('Ọgwụgwọ na ahụike', 180),
  ('Ọmụmụ na teknụzụ', 190),
  ('Ihe na-emekarị ugbu a n''asụsụ Igbo', 200),
  ('Mmetụta ọdịnala ọzọ', 210),
  ('Ọrụ nchọpụta na ebe akwụkwọ', 220),
  ('Nghọta ederede na-amaghị ama', 230),
  ('Njirimara jamb na ajụjụ ọnụ', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Igbo'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Arabic (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Arabic script, hamza and diacritics', 10),
  ('Nouns: gender, number, case endings (basic)', 20),
  ('Definite article and sun letters', 30),
  ('Pronouns: attached and detached', 40),
  ('Present tense verbs (Form I patterns)', 50),
  ('Past tense and root patterns (recognition)', 60),
  ('Derived verb forms (basic recognition)', 70),
  ('Particles, prepositions and conjunctions', 80),
  ('Nominal sentences and verbal sentences', 90),
  ('Adjectives, comparison and agreement', 100),
  ('Numbers and counting (basic)', 110),
  ('Comprehension: Qur''anic and modern passages', 120),
  ('Translation: Arabic to English (phrases)', 130),
  ('Translation: English to Arabic (phrases)', 140),
  ('Nahw: i''rab basics and common constructions', 150),
  ('Sarf: verbal nouns and participles (basic)', 160),
  ('Guided composition and sentence building', 170),
  ('Formal and informal registers', 180),
  ('Islamic vocabulary in context', 190),
  ('Classical poetry: metre and themes (basic)', 200),
  ('Modern Arabic prose (basic)', 210),
  ('Listening and dictation skills', 220),
  ('Oral reading and tajweed awareness', 230),
  ('Exam techniques for Arabic objective tests', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Arabic'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Geography (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Map reading: scale, distance and direction', 10),
  ('Contours, relief profiles and gradients', 20),
  ('Coordinates, grid references and bearings', 30),
  ('Statistical diagrams and climate graphs', 40),
  ('Fieldwork and simple observation techniques', 50),
  ('Earth rotation, revolution and time', 60),
  ('Structure of the earth: rocks and plate tectonics', 70),
  ('Weathering, erosion and deposition', 80),
  ('Climate: elements, factors and classification', 90),
  ('Vegetation belts and soils', 100),
  ('Rivers, lakes and groundwater', 110),
  ('Oceans, coasts and marine processes', 120),
  ('Population: distribution, density and migration', 130),
  ('Settlement types and urbanisation', 140),
  ('Agriculture: systems and problems in Nigeria', 150),
  ('Mining, power and industry', 160),
  ('Transport, trade and tourism', 170),
  ('Regional geography of Nigeria', 180),
  ('West Africa: physical and economic overview', 190),
  ('Africa: major regions and issues', 200),
  ('World geography: major powers and organisations', 210),
  ('Environmental issues: drought, flood, climate change', 220),
  ('Natural resources and sustainable development', 230),
  ('Map-based and photo interpretation skills', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Geography'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Art (Fine Art) (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Nature and functions of art', 10),
  ('Traditional African art: themes and media', 20),
  ('Nigerian art: Nok, Ife, Benin and contemporary', 30),
  ('Western art: major periods (overview)', 40),
  ('Elements of art: line, shape, colour, texture', 50),
  ('Principles of design: balance, rhythm, emphasis', 60),
  ('Drawing: still life and perspective (basic)', 70),
  ('Painting: media and colour mixing', 80),
  ('Printmaking and pattern design', 90),
  ('Sculpture: modelling and carving basics', 100),
  ('Ceramics: clay preparation and firing (basic)', 110),
  ('Textiles: dyeing, weaving and embellishment', 120),
  ('Graphic design: lettering and layout', 130),
  ('Photography and digital tools (basic)', 140),
  ('Art criticism and appreciation questions', 150),
  ('Careers in art and design', 160),
  ('Environmental art and crafts', 170),
  ('Costume and makeup in drama (basic)', 180),
  ('Museum, gallery and heritage conservation', 190),
  ('Copyright and originality in art', 200),
  ('Sketchbook and portfolio development', 210),
  ('Health and safety in the studio', 220),
  ('Exam techniques: objective and theory', 230),
  ('Integrated studio project (revision)', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Art (Fine Art)'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Home Economics (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Meaning, scope and career opportunities', 10),
  ('Philosophy and goals of home economics', 20),
  ('The family: types, functions and life cycle', 30),
  ('Family resources: types and management', 40),
  ('Decision-making and budgeting', 50),
  ('Housing: choice, care and safety', 60),
  ('Household equipment and maintenance', 70),
  ('Consumer education and rights', 80),
  ('Food nutrients and a balanced diet', 90),
  ('Meal planning, cookery methods and preservation', 100),
  ('Kitchen hygiene, safety and storage', 110),
  ('Food-related diseases and first aid (basic)', 120),
  ('Fibres, fabrics and textile finishes', 130),
  ('Sewing tools, stitches and garment construction', 140),
  ('Pattern adaptation and simple repairs', 150),
  ('Laundry and clothing care', 160),
  ('Child care and development (basic)', 170),
  ('Adolescent health and hygiene', 180),
  ('Entrepreneurship in catering and sewing', 190),
  ('Simple record-keeping for home enterprises', 200),
  ('Environmental sanitation at home', 210),
  ('Time and stress management', 220),
  ('Exam techniques for Home Economics', 230),
  ('Integrated revision across strands', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Home Economics'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Music (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Staff notation, clefs and note values', 10),
  ('Time signatures, tempo and metre', 20),
  ('Scales: major, minor and modes (basic)', 30),
  ('Intervals and triads', 40),
  ('Rhythm patterns and syncopation', 50),
  ('Dynamics, articulation and expression marks', 60),
  ('Key signatures and transposition (basic)', 70),
  ('Elementary harmony: cadences and progressions', 80),
  ('African music: instruments and ensembles', 90),
  ('Traditional Nigerian rhythms and dances', 100),
  ('Highlife, juju, Afrobeat (themes)', 110),
  ('Art music in Africa (overview)', 120),
  ('Western classical periods: overview', 130),
  ('Orchestra families and programme music', 140),
  ('Jazz, pop and world fusion (basic)', 150),
  ('Comparing African and Western forms', 160),
  ('Music and society: functions and contexts', 170),
  ('Composers and performers (recognition)', 180),
  ('Listening skills: timbre, texture, form', 190),
  ('Sight-singing and clapping rhythms', 200),
  ('Creative work: simple melody writing', 210),
  ('Music technology and recording (basic)', 220),
  ('Copyright and performance rights', 230),
  ('Exam techniques: aural and theory papers', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Music'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Physical and Health Education (~24 granular topics)
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Meaning, aims and values of PHE', 10),
  ('Human skeleton, muscles and movement', 20),
  ('Circulatory and respiratory systems in exercise', 30),
  ('Physical fitness components and testing', 40),
  ('Warm-up, cool-down and training principles', 50),
  ('Athletics: track and field events', 60),
  ('Ball games: football, basketball, volleyball', 70),
  ('Racket sports and table tennis', 80),
  ('Gymnastics and athletics safety', 90),
  ('Swimming and aquatics (theory)', 100),
  ('Traditional Nigerian games and dances', 110),
  ('Recreation, leisure and outdoor education', 120),
  ('Nutrition, hydration and performance', 130),
  ('Drugs: misuse, doping and fair play', 140),
  ('First aid: wounds, fractures, CPR awareness', 150),
  ('Safety in sports facilities and equipment', 160),
  ('National sports policy and NSC', 170),
  ('Olympics, AFCON and major events', 180),
  ('Adapted physical activity and inclusion', 190),
  ('Personal hygiene and self-care', 200),
  ('Water, sanitation and community health', 210),
  ('Communicable diseases: prevention and control', 220),
  ('Non-communicable diseases and lifestyle', 230),
  ('Adolescent health, relationships and life skills', 240)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name = 'JAMB' and s.name = 'Physical and Health Education'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;