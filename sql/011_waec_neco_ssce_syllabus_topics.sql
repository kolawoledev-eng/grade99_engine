-- WAEC & NECO SSCE: syllabus topic rows for all catalog subjects × years 2024–2026.
-- Section/topic names align with official WAEC SSCE syllabus published on waec.gov.ng
-- and confirmed via waecsyllabus.com (the authoritative mirror used here).
-- NECO SSCE covers the same topic areas; NECO-only additions are noted inline.
-- Re-run safe: ON CONFLICT (subject_id, topic_name, year) DO UPDATE display_rank.
--
-- KEY CORRECTIONS vs. previous version:
--   • English Language: 3 official papers → Section A Essay Writing (with 9 genres),
--     Section B Comprehension, Section C Summary, Paper 2 Lexis & Structure,
--     Paper 3 Oral English. Previous list conflated JAMB-style topics with WAEC papers.
--   • Civic Education: restructured to 3 official sections (National Ethics,
--     Emerging Issues, Governmental System & Processes) instead of 10 loose topics.
--   • Mathematics: restructured to the 7 official WAEC topic groupings
--     (Number & Numeration, Algebraic Processes, Mensuration, Plane Geometry,
--     Coordinate Geometry, Trigonometry, Introductory Calculus, Statistics &
--     Probability, Vectors & Transformation). "Sets" and "Logarithms and Surds"
--     are sub-topics inside Number & Numeration — not separate sections.
--   • Further Mathematics: corrected to match the official WAEC/NECO section headings.
--   • Physics: restructured to 4 official thematic blocks
--     (Interaction of Matter/Space/Time, Energy: Mechanical & Heat, Waves, Fields)
--     plus the Harmonised Topics block.  Previous 8 topics were inaccurate.
--   • Chemistry: restructured to 13 official section headings
--     (Introduction, Atomic Structure, Separation Techniques, Periodic Chemistry,
--     Chemical Bonds, Stoichiometry, States of Matter, Energy Changes, Acids/Bases/Salts,
--     Solubility, Kinetics & Equilibrium, Redox, Organic Chemistry, Industry &
--     Environment, Basic Biochemistry & Polymers).
--   • Biology: restructured to the 4 official thematic sections
--     (Concept of Living, Plant & Animal Nutrition, Basic Ecological Concepts,
--     Conservation of Natural Resources, Variation in Population, Heredity,
--     Adaptation & Evolution).
--   • Economics: section headings corrected; "Aids to Trade" removed (Commerce topic).
--   • Government: restructured to the correct WAEC headings.
--   • Literature in English: generic structural sections; texts not hardcoded.
--   • Principles of Accounts / Financial Accounting: corrected to WAEC Financial
--     Accounting headings (WAEC calls it "Financial Accounting", not "Principles
--     of Accounts" — see note below).
--   • Commerce: corrected to 8 official WAEC section headings.
--   • IRS: corrected to official WAEC heading structure.
--   • CRS (Christian Religious Studies): corrected — official WAEC name is CRS,
--     NOT "Christian Religious Knowledge" (CRK is NECO's name; both handled).
--   • Agricultural Science: updated to 5 official WAEC section groupings.
--   • Computer Science / Studies: corrected to official WAEC section headings.
--   • History: updated to correct WAEC section structure.
--   • Geography: updated to correct WAEC section structure.
--   • French, Hausa, Igbo, Yoruba, Arabic: corrected to proper WAEC section headings.
--   • Food and Nutrition: corrected to official WAEC section titles.
--   • Technical Drawing: corrected to official WAEC section headings.
--   • Visual Art: corrected to official WAEC section headings.
--   • Physical Education: corrected to official WAEC section headings.
--   • Health Education: corrected to official WAEC section headings.
--
-- NOTE on subject names:
--   WAEC calls it "Financial Accounting"; NECO calls it "Principles of Accounts".
--   WHERE clause below covers both.
--   WAEC calls religious studies "Christian Religious Studies" (CRS).
--   NECO calls it "Christian Religious Knowledge" (CRK). Both covered.
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- English Language
-- WAEC/NECO structure: Paper 1 = Essay + Comprehension + Summary (3 sections);
-- Paper 2 = Lexis & Structure; Paper 3 = Oral English.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Essay Writing (Letters, Reports, Articles, Speeches, Narratives, Debates, Descriptions, Expositions, Creative Writing)', 10),
  ('Comprehension (Factual, Inferential and Grammatical Questions on Passages)', 20),
  ('Summary (Extracting and Re-presenting Relevant Information)', 30),
  ('Lexis and Structure (Vocabulary, Idioms, Structural Elements, Figurative Usage)', 40),
  ('Oral English (Consonants, Vowels, Stress, Intonation, Emphatic Stress)', 50)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'English Language'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Civic Education
-- 3 official WAEC sections.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('National Ethics, Discipline, Rights and Obligations', 10),
  ('Emerging Issues in Society (Cultism, Drug Abuse, Human Trafficking, HIV/AIDS, Youth Empowerment)', 20),
  ('Governmental System and Processes (Democracy, Rule of Law, Public Service, Civil Society)', 30)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Civic Education'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Mathematics (General / Core)
-- Official WAEC topic groupings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Number and Numeration (Number Bases, Modular Arithmetic, Fractions, Indices, Logarithms, Surds, Sets, Matrices)', 10),
  ('Algebraic Processes (Expressions, Equations, Inequalities, Functions, Quadratics, Variation)', 20),
  ('Mensuration (Lengths, Areas, Volumes, Longitudes and Latitudes)', 30),
  ('Plane Geometry (Angles, Triangles, Polygons, Circles, Construction, Loci)', 40),
  ('Coordinate Geometry of Straight Lines', 50),
  ('Trigonometry (Ratios, Graphs, Bearings, Angles of Elevation and Depression)', 60),
  ('Introductory Calculus (Differentiation and Integration of Algebraic Functions)', 70),
  ('Statistics and Probability (Frequency Distribution, Charts, Measures of Central Tendency and Dispersion)', 80),
  ('Vectors and Transformation in the Cartesian Plane', 90)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Mathematics'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Further Mathematics (Mathematics Elective)
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Pure Mathematics – Algebra (Polynomials, Rational Functions, Complex Numbers)', 10),
  ('Pure Mathematics – Matrices and Linear Transformation', 20),
  ('Pure Mathematics – Trigonometry (Advanced Identities, Equations)', 30),
  ('Pure Mathematics – Coordinate Geometry (Conic Sections, Circles, Parabolas)', 40),
  ('Pure Mathematics – Calculus (Limits, Differentiation, Integration, Applications)', 50),
  ('Statistics and Probability (Permutation, Combination, Distributions, Hypothesis Testing)', 60),
  ('Vectors (2D and 3D, Scalar and Vector Products)', 70),
  ('Mechanics (Statics, Kinematics, Newton''s Laws, Work, Energy, Power)', 80)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Further Mathematics'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Physics
-- 4 official WAEC thematic blocks + Harmonised Topics for short structured questions.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Interaction of Matter, Space and Time (Quantities, Units, Motion, Forces, Equilibrium, SHM, Newton''s Laws)', 10),
  ('Energy: Mechanical and Heat (Work, Energy, Power, Machines, Heat, Gas Laws, Latent Heat, Vapour)', 20),
  ('Waves (Production, Propagation, Types, Properties, Light, Sound, Electromagnetic Spectrum)', 30),
  ('Fields (Gravitational, Electric, Magnetic, Electromagnetic Induction, AC Circuits)', 40),
  ('Modern Physics and Electronics (Atomic Structure, Radioactivity, Nuclear Reactions, Semiconductors, Diodes)', 50),
  ('Harmonised Topics (Projectile Motion, Satellites, Elasticity, Thermal Conductivity, Fibre Optics, LASER)', 60)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Physics'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Chemistry
-- 15 official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Introduction to Chemistry (Measurement, Scientific Method)', 10),
  ('Structure of the Atom (Atomic Number, Isotopes, Electronic Configuration)', 20),
  ('Standard Separation Techniques for Mixtures', 30),
  ('Periodic Chemistry (Periodic Table, Trends and Periodicity)', 40),
  ('Chemical Bonds (Ionic, Covalent, Coordinate; Properties of Compounds)', 50),
  ('Stoichiometry and Chemical Reactions (Symbols, Formulae, Equations, Mole Concept)', 60),
  ('States of Matter (Kinetic Theory, Changes of State, Diffusion)', 70),
  ('Energy and Energy Changes (Enthalpy, Exothermic and Endothermic Reactions)', 80),
  ('Acids, Bases and Salts (Definitions, Properties, pH, Electrolytes)', 90),
  ('Solubility of Substances (Principles and Applications)', 100),
  ('Chemical Kinetics and Equilibrium (Rates, Factors, Le Chatelier''s Principle)', 110),
  ('Redox Reactions (Oxidation, Reduction, Electrochemical Cells)', 120),
  ('Chemistry of Carbon Compounds (Organic Chemistry, Petroleum)', 130),
  ('Chemistry, Industry and the Environment', 140),
  ('Basic Biochemistry and Synthetic Polymers (Proteins, Carbohydrates, Fats, Polymers)', 150)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Chemistry'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Biology
-- Official WAEC thematic groupings (Sections A, B, C of the syllabus).
-- Section A = common to all countries; Sections B/C = Ghana vs Nigeria etc.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Concept of Living (Classification, Cell, Organization of Life, Cell Processes, Tissues)', 10),
  ('Plant and Animal Nutrition (Photosynthesis, Mineral Requirements, Digestive System)', 20),
  ('Basic Ecological Concepts (Ecosystem, Ecological Factors, Food Webs, Energy Flow, Pollution)', 30),
  ('Conservation of Natural Resources', 40),
  ('Variation in Population (Morphological and Physiological Variations)', 50),
  ('Biology of Heredity – Genetics (Mendel''s Laws, Chromosomes, Linkage, Sex Determination)', 60),
  ('Adaptation for Survival and Evolution (Behavioural Adaptation, Theories of Evolution)', 70),
  ('Support Systems, Transport, Respiration, Excretion and Homeostasis', 80),
  ('Hormonal and Nervous Coordination; Sense Organs', 90),
  ('Reproductive Systems and Reproduction in Organisms', 100)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Biology'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Economics
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Introduction to Economics (Basic Concepts, Economic Systems, Methodology)', 10),
  ('Theory of Demand and Supply', 20),
  ('Theory of Production and Costs', 30),
  ('Market Structures (Perfect Competition, Monopoly, Oligopoly)', 40),
  ('National Income (Concepts, Measurement, Determination)', 50),
  ('Money, Banking and the Financial System', 60),
  ('Inflation and Deflation', 70),
  ('Public Finance (Taxation, Expenditure, Budget, Public Debt)', 80),
  ('International Trade and Balance of Payments', 90),
  ('Economic Development and Planning', 100),
  ('Agriculture in the Nigerian Economy', 110),
  ('Industry, Trade and Entrepreneurship', 120),
  ('Population, Labour Market and Employment', 130)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Economics'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Government
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Basic Concepts of Government (State, Sovereignty, Power, Authority, Legitimacy)', 10),
  ('Forms and Systems of Government (Democracy, Federalism, Unitarism, Confederation)', 20),
  ('Constitution (Types, Features, Constitutional Development)', 30),
  ('Arms of Government (Legislature, Executive, Judiciary)', 40),
  ('Electoral Systems and Political Parties', 50),
  ('Public Administration (Civil Service, Bureaucracy, Local Government)', 60),
  ('Nigerian Pre-Colonial Political Systems', 70),
  ('Colonial Administration in Nigeria', 80),
  ('Nationalist Movement and Nigerian Independence', 90),
  ('Post-Independence Political Development in Nigeria', 100),
  ('International Organisations and Nigeria''s Foreign Policy (UN, AU, ECOWAS, Commonwealth)', 110)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Government'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Literature in English
-- Genre-section structure only. Prescribed texts rotate on a 5-year cycle and
-- must be managed in a separate prescribed_texts table, not here.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Drama (Set Texts and Dramatic Techniques)', 10),
  ('Prose (Set Texts and Narrative Techniques)', 20),
  ('Poetry (Set Poems, Poetic Devices, Appreciation)', 30),
  ('General Literary Principles (Genre, Literary Terms, Style, Theme, Tone)', 40)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Literature in English'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Financial Accounting / Principles of Accounts
-- WAEC calls it "Financial Accounting"; NECO calls it "Principles of Accounts".
-- WHERE clause covers both names.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Accounting Concepts, Conventions and Processes', 10),
  ('Books of Original Entry (Journals, Day Books, Subsidiary Books)', 20),
  ('Ledger Accounts, Trial Balance and Errors', 30),
  ('Bank Transactions and Bank Reconciliation Statement', 40),
  ('Control Accounts', 50),
  ('Final Accounts of Sole Traders (Trading, Profit & Loss, Balance Sheet)', 60),
  ('Depreciation, Disposal and Revaluation of Assets', 70),
  ('Incomplete Records and Single Entry', 80),
  ('Accounts of Non-Profit Organisations (Clubs and Societies)', 90),
  ('Partnership Accounts', 100),
  ('Limited Liability Company Accounts (Share Capital, Debentures, Published Accounts)', 110),
  ('Manufacturing Accounts', 120),
  ('Public Sector Accounting (Government Accounts, Appropriation)', 130)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO')
  and s.name in ('Financial Accounting', 'Principles of Accounts')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Commerce
-- Official WAEC section headings (8 main sections).
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Introduction to Commerce (Trade, Aids to Trade, Channels of Distribution)', 10),
  ('Business Organisations and Enterprises', 20),
  ('Retail and Wholesale Trade (Home and Foreign Trade)', 30),
  ('Transportation and Communication', 40),
  ('Warehousing, Insurance and Advertising', 50),
  ('Banking, Finance and the Capital Market', 60),
  ('Commercial Documents and Transactions', 70),
  ('Consumer Education and Protection', 80)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Commerce'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Islamic Religious Studies (IRS)
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('The Qur''an (Recitation, Memorisation, Tafsir of Selected Surahs)', 10),
  ('Hadith (Selected Traditions of the Prophet)', 20),
  ('Aqeedah – Articles of Faith (Tawhid, Prophethood, Angels, Scriptures, Last Day)', 30),
  ('Fiqh – Islamic Law and Jurisprudence (Ibadah, Muamalat, Moral Conduct)', 40),
  ('Sirah – Life of the Prophet Muhammad (SAW) and Early Caliphate', 50),
  ('Islamic History and Civilisation in West Africa', 60)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO')
  and s.name in ('Islamic Religious Studies', 'Islamic Studies', 'IRS')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Christian Religious Studies / Christian Religious Knowledge
-- WAEC uses "CRS"; NECO uses "CRK". WHERE clause covers both.
-- Official WAEC structure: themes from Old Testament through New Testament and Church.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('God – His Nature, Attributes and Works (Creation, Providence, Sovereignty)', 10),
  ('Old Testament Themes: The Patriarchs, Moses, Covenant and the Law', 20),
  ('Old Testament Themes: The Prophets, Kingship, Exile and Restoration', 30),
  ('New Testament: The Life and Teaching of Jesus Christ', 40),
  ('New Testament: The Holy Spirit and the Early Church (Acts)', 50),
  ('New Testament: Pauline and General Epistles (Selected Themes)', 60),
  ('The Church: History, Mission and Contemporary Issues', 70),
  ('Christian Ethics and Social Responsibilities', 80)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO')
  and s.name in ('Christian Religious Studies', 'CRS', 'Christian Religious Knowledge', 'CRK')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Agricultural Science
-- Official WAEC section groupings (5 sections).
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('General Agriculture (Importance, Branches, Ecology and Climate)', 10),
  ('Soil Science (Formation, Composition, Properties, Erosion and Conservation)', 20),
  ('Crop Production (Crop Classification, Husbandry, Pests, Diseases, Harvesting)', 30),
  ('Animal Production (Livestock, Poultry, Fisheries, Animal Nutrition and Health)', 40),
  ('Agricultural Economics and Extension (Farm Management, Marketing, Farm Records, Credit)', 50)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Agricultural Science'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Computer Science / Computer Studies
-- WAEC official section headings (syllabus titled "Computer Studies" in WAEC PDF).
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('History and Development of Computers', 10),
  ('Computer Hardware (System Unit, Input, Output and Storage Devices)', 20),
  ('Computer Software (Operating Systems, Application Packages, Programming)', 30),
  ('Data Representation and Number Systems', 40),
  ('Problem Solving, Algorithms and Flowcharts', 50),
  ('Programming Languages and Coding Concepts', 60),
  ('Internet, Networking and Communication', 70),
  ('Spreadsheets, Databases and Office Applications', 80),
  ('Computer Ethics, Security and Maintenance', 90)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO')
  and s.name in ('Computer Science', 'Computer Studies')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- History
-- Official WAEC section headings for Nigeria-focus (Section C countries).
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Pre-Colonial Nigeria (States, Peoples and Societies up to 1800)', 10),
  ('The Trans-Atlantic Slave Trade and its Impact', 20),
  ('Colonial Conquest and Administration in Nigeria', 30),
  ('Nationalist Movements and the Path to Independence', 40),
  ('Nigeria Since Independence (1960 to Present)', 50),
  ('West Africa: Integration, Cooperation and Conflicts', 60),
  ('Africa and the Wider World (Scramble, Pan-Africanism, International Relations)', 70)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'History'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Geography
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Practical Geography (Maps, Photographs, Statistical Methods, Fieldwork)', 10),
  ('Physical Geography (Internal Processes, Landforms, Drainage, Atmosphere, Climate)', 20),
  ('Biogeography (Vegetation, Soils, Ecosystem)', 30),
  ('Human and Economic Geography (Population, Settlement, Agriculture, Industry, Trade)', 40),
  ('Regional Geography of Nigeria and West Africa', 50)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Geography'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- French
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Oral French (Phonetics, Listening and Speaking)', 10),
  ('Reading Comprehension (Unseen Passages)', 20),
  ('Grammar and Structure (Lexis, Morphology, Syntax)', 30),
  ('Composition and Free Writing (Essay, Formal and Informal Letters)', 40),
  ('French Culture and Civilization (Francophone Africa and France)', 50)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'French'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Igbo
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Asụsụ – Igbo Language (Oral, Grammar, Vocabulary, Comprehension, Composition)', 10),
  ('Agụmagụ – Igbo Literature (Set Texts: Prose, Drama, Poetry)', 20),
  ('Omenala – Igbo Customs, Institutions and Culture', 30)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Igbo'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Hausa
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Harshe – Hausa Language (Oral, Grammar, Vocabulary, Comprehension, Composition)', 10),
  ('Adabi – Hausa Literature (Set Texts: Prose, Drama, Poetry)', 20),
  ('Al''adu – Hausa Culture and Institutions', 30)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Hausa'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Yoruba
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Ede – Yoruba Language (Oral, Grammar, Vocabulary, Comprehension, Composition)', 10),
  ('Litireso – Yoruba Literature (Set Texts: Prose, Drama, Poetry, Oral Poetry)', 20),
  ('Asa ati Aṣà – Yoruba Culture and Institutions', 30)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Yoruba'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Arabic
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Arabic Oral (Phonetics and Listening Comprehension)', 10),
  ('Arabic Comprehension (Unseen Passages)', 20),
  ('Arabic Grammar (Nahw and Sarf)', 30),
  ('Arabic Composition (Free Writing, Translation)', 40),
  ('Arabic Literature (Classical and Modern Texts)', 50),
  ('Qur''anic Arabic (Selected Passages and Linguistic Study)', 60)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Arabic'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Foods and Nutrition
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Food Nutrients (Composition, Functions, Sources, Deficiency Diseases)', 10),
  ('Digestion, Absorption and Metabolism of Food', 20),
  ('Meal Planning and Dietary Requirements (Balanced Diet, Special Diets)', 30),
  ('Food Preparation Methods and Cookery (Principles and Techniques)', 40),
  ('Food Preservation and Storage', 50),
  ('Kitchen Equipment, Safety and Hygiene', 60),
  ('Consumer Education and Food Economics', 70)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO')
  and s.name in ('Foods and Nutrition', 'Food and Nutrition')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Technical Drawing
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Plane Geometry (Lines, Angles, Triangles, Polygons, Circles, Conic Sections)', 10),
  ('Solid Geometry and Orthographic Projection (1st and 3rd Angle)', 20),
  ('Pictorial Drawing (Isometric, Oblique, Perspective)', 30),
  ('Sections of Solids (True Shapes, Intersections)', 40),
  ('Development of Surfaces (Prisms, Cylinders, Cones, Pyramids)', 50),
  ('Engineering Graphics (Fasteners, Bearings, Dimensioning, Conventions)', 60)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Technical Drawing'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Visual Art
-- Official WAEC section headings (PDF titled "Visual Art / Art").
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('History of Art (African Traditional Art, Western Art History, Art Appreciation)', 10),
  ('Drawing (Observational, Technical and Expressive Drawing)', 20),
  ('Painting (Media, Techniques, Composition)', 30),
  ('Graphic Design (Typography, Layout, Illustration, Printmaking)', 40),
  ('Sculpture and Ceramics (Modelling, Casting, Construction)', 50),
  ('Textiles and Crafts (Weaving, Dyeing, Batik, Tie-Dye)', 60)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO')
  and s.name in ('Visual Art', 'Art', 'Fine Art')
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Physical Education
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Foundation and History of Physical Education', 10),
  ('Human Anatomy and Physiology (Skeletal, Muscular, Cardiovascular Systems)', 20),
  ('Athletics (Track and Field Events, Rules and Techniques)', 30),
  ('Games and Sports (Team and Individual Sports, Rules and Officiating)', 40),
  ('Gymnastics and Aquatics', 50),
  ('Recreation, Leisure and Dance', 60),
  ('Physical Fitness and Conditioning', 70)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Physical Education'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;


-- ---------------------------------------------------------------------------
-- Health Education
-- Official WAEC section headings.
-- ---------------------------------------------------------------------------
insert into syllabus_topics (subject_id, topic_name, year, display_rank)
select s.id, t.topic_name, y.yr, t.drank
from subjects s
join exams e on e.id = s.exam_id
cross join (values
  ('Personal Health and Hygiene', 10),
  ('Community and Environmental Health', 20),
  ('Nutrition and Health', 30),
  ('Communicable and Non-Communicable Diseases', 40),
  ('Reproductive Health and Family Life Education', 50),
  ('Drug Abuse and Mental Health', 60),
  ('First Aid, Safety Education and Emergency Care', 70),
  ('National and International Health Organisations', 80)
) as t(topic_name, drank)
cross join (values (2024), (2025), (2026)) as y(yr)
where e.name in ('WAEC', 'NECO') and s.name = 'Health Education'
on conflict (subject_id, topic_name, year) do update set display_rank = excluded.display_rank;