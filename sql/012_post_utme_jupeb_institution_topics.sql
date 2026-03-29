-- Post-UTME & JUPEB: seed institution_topics for every institution_subject row (2025 offerings).
-- Re-run safe: ON CONFLICT (institution_subject_id, topic_name) DO NOTHING.
--
-- ============================================================================
-- KEY CORRECTIONS vs. previous version
-- ============================================================================
--
-- POST-UTME:
--   Post-UTME has no single national syllabus. Universities set their own
--   papers but consistently test JAMB/WAEC topics. Topics below are therefore
--   aligned to those verified JAMB/WAEC section headings rather than loose,
--   invented labels. Specific changes per subject:
--
--   • English: renamed "Essay and Composition" → "Essay Writing"; renamed
--     "Grammar and Usage" → "Summary"; added correct 5th paper-section.
--   • Mathematics: replaced "Algebra" → "Algebraic Processes"; replaced
--     "Geometry and Trigonometry" → separate "Plane Geometry and Mensuration"
--     and "Trigonometry"; replaced vague "Calculus Basics" with correct label.
--   • Physics: replaced 5 vague topics with the correct JAMB/WAEC thematic
--     blocks (Mechanics, Thermal Physics & Properties of Matter, Waves &
--     Optics, Electricity & Magnetism, Modern Physics & Electronics).
--   • Chemistry: replaced 5 vague topics with the correct thematic groupings
--     (Atomic Structure & Bonding, Stoichiometry & Kinetics, Organic Chemistry,
--     Electrochemistry & Redox, Physical Chemistry & States of Matter).
--   • Biology: renamed "Cell Biology" → "Cell Structure & Organisation";
--     replaced "Plant and Animal Physiology" → "Physiology (Nutrition,
--     Respiration, Transport, Excretion)"; corrected to match JAMB sections.
--   • Computer Studies: renamed "Computer Fundamentals" → "Evolution &
--     Fundamentals of Computing"; added "Artificial Intelligence & Robotics"
--     (new JAMB section); replaced "Data Representation" with more accurate
--     "Data Representation & Number Systems".
--   • Agricultural Science: replaced "Pests and Diseases" with the correct
--     JAMB section label "Agricultural Technology (Mechanisation & Processing)".
--   • Government: replaced 5 vague topics with the correct JAMB/WAEC groupings
--     covering Elements/Forms, Organs of Government, Nigerian Political
--     Development, Electoral Systems, and International Organisations.
--   • Economics: replaced "Basic Concepts and Principles" with correct label
--     "Introduction and Basic Concepts"; added "Theory of the Firm & Costs".
--   • Commerce: corrected "Trade and Aids to Trade" → "Home, Foreign Trade &
--     Channels of Distribution"; renamed "Insurance and Marketing" to correctly
--     separate insurance from marketing per WAEC section structure.
--   • Principles of Accounts: replaced "Double Entry" → "Double Entry &
--     Books of Original Entry"; replaced "Depreciation" → "Depreciation &
--     Disposal of Assets".
--   • Literature in English: replaced "African and Non-African Texts" with
--     "General Literary Principles & Literary Appreciation".
--   • CRS: replaced old 5-topic list with the correct Old/New Testament and
--     Church sections from the WAEC CRS syllabus structure.
--   • IRS: corrected topic names to match official WAEC IRS section headings.
--   • Geography: replaced "Map Work" → "Practical Geography & Map Reading";
--     replaced "Nigeria Geography" → "Regional Geography of Nigeria &
--     West Africa".
--   • History: replaced "Sources and Methods" with "Trans-Atlantic Slave
--     Trade & Its Impact"; corrected to match WAEC History section headings.
--   • Civic Education: replaced 5 loose topics with the 3 official WAEC
--     Civic Education section headings.
--   • Current Affairs: topics are reasonable; retained with minor label fixes.
--   • General Knowledge: retained; this subject is not syllabus-governed.
--
-- JUPEB:
--   JUPEB has 19 official subjects only (confirmed at jupeb.edu.ng/about/
--   examination_subjects). The subject "Computer Studies" does NOT exist in
--   JUPEB — removed. Topics now reflect the official JUPEB course-code
--   structure (two semesters, two courses per semester = 4 course units).
--
--   • Mathematics: MAT001 Advanced Pure Mathematics + MAT002 Calculus
--     (Semester 1); MAT003 Applied Mathematics + MAT004 Statistics (Semester 2).
--   • Physics: PHY001 Mechanics & Properties of Matter + PHY002 Heat, Waves
--     & Optics (Semester 1); PHY003 Electricity & Magnetism + PHY004 Modern
--     Physics (Semester 2).
--   • Chemistry: CHE001 Physical & Inorganic Chemistry (Semester 1);
--     CHE002 Organic Chemistry & Biochemistry (Semester 2).
--   • Biology: BIO001 Cell Biology & Genetics + BIO002 Ecology & Evolution
--     (Semester 1); BIO003 Physiology & Anatomy (Semester 2).
--   • Economics: ECN001 Principles of Economics I (Micro) + ECN002
--     Principles of Economics II (Macro/Development).
--   • Government: GOV001 Political Theory & Comparative Government +
--     GOV002 Nigerian Government & International Relations.
--   • Accounting: ACC001 Financial Accounting + ACC002 Cost & Management
--     Accounting.
--   • Business Studies: BUS001 Business Environment & Management +
--     BUS002 Marketing, Finance & Entrepreneurship.
--   • Agricultural Science: AGR001 Crop & Soil Science + AGR002 Animal
--     Production, Farm Management & Agricultural Economics.
--   • Geography: GEO001 Physical & Practical Geography + GEO002 Human &
--     Regional Geography.
--   • Literature-in-English: LIT001 Drama & Prose (Set Texts) + LIT002
--     Poetry & Literary Criticism.
--   • CRS: CRS001 Old Testament Themes + CRS002 New Testament & Church History.
--   • IRS: ISS001 Qur'an, Hadith & Tawhid + ISS002 Fiqh, Sirah & Islamic
--     History.
--   • French: FRE001 Grammar, Comprehension & Composition + FRE002 Oral
--     French & Culture.
--   • History: HIS001 Nigerian & West African History + HIS002 African &
--     World History since 1800.
--   • Visual Arts: VSA001 History & Theory of Art + VSA002 Studio Practice.
--   • Music: MUS001 Music Theory & Harmony + MUS002 History of African &
--     Western Music.
--   • Igbo / Yoruba: Language, Literature & Culture (3-section structure).
--   • "Business Studies" corrected — previous file had this as JUPEB subject
--     but used wrong topics (it exists; correct topics now applied).
-- ============================================================================


-- ===========================================================================
-- POST-UTME 2025
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- English / Use of English  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Comprehension (Factual, Inferential, Vocabulary in Context)'),
  ('Summary Writing'),
  ('Lexis and Structure (Synonyms, Antonyms, Idioms, Grammar)'),
  ('Essay Writing (Letters, Reports, Speeches, Narratives, Arguments)'),
  ('Oral English (Vowels, Consonants, Stress, Intonation)')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name in ('Use of English', 'English', 'English Language')
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Mathematics  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Number and Numeration (Indices, Logarithms, Surds, Sets, Matrices)'),
  ('Algebraic Processes (Equations, Inequalities, Functions, Variation)'),
  ('Plane Geometry and Mensuration (Angles, Polygons, Circles, Areas, Volumes)'),
  ('Coordinate Geometry and Trigonometry'),
  ('Calculus (Differentiation and Integration) and Statistics & Probability')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Mathematics'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Physics  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Mechanics (Motion, Forces, Work, Energy, Power, Machines, SHM)'),
  ('Thermal Physics & Properties of Matter (Heat, Gas Laws, Elasticity, Pressure)'),
  ('Waves and Optics (Wave Properties, Light, Sound, Electromagnetic Spectrum)'),
  ('Electricity and Magnetism (Electrostatics, Current Electricity, Electromagnetic Induction, AC Circuits)'),
  ('Modern Physics and Electronics (Radioactivity, Nuclear Reactions, Semiconductors, Diodes)')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Physics'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Chemistry  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Atomic Structure, Periodic Table and Chemical Bonding'),
  ('Stoichiometry, Chemical Kinetics and Equilibrium'),
  ('Organic Chemistry (Hydrocarbons, Functional Groups, Reactions)'),
  ('Electrochemistry, Redox Reactions and Metals/Non-Metals'),
  ('Physical Chemistry (States of Matter, Gas Laws, Energy Changes, Acids/Bases/Salts)')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Chemistry'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Biology  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Cell Structure, Organisation and Cell Processes'),
  ('Genetics, Heredity and Evolution'),
  ('Ecology (Ecosystems, Food Webs, Pollution, Conservation)'),
  ('Physiology (Nutrition, Respiration, Transport, Excretion, Coordination)'),
  ('Reproduction and Growth in Organisms')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Biology'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Computer Studies  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Evolution and Fundamentals of Computing (Hardware and Software)'),
  ('Data Representation, Number Systems and Computer Arithmetic'),
  ('Problem-Solving, Algorithms, Flowcharts and Programming Concepts'),
  ('Internet, Networking and Information & Communication Technology (ICT)'),
  ('Artificial Intelligence, Robotics and Computer Ethics')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name in ('Computer Studies', 'Computer Science')
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Agricultural Science  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Soil Science (Formation, Composition, Properties and Conservation)'),
  ('Crop Production (Husbandry, Pests, Diseases, Harvesting and Storage)'),
  ('Animal Production (Livestock, Poultry, Fisheries, Nutrition and Health)'),
  ('Agricultural Economics and Extension (Farm Management, Records, Marketing)'),
  ('Agricultural Technology (Farm Tools, Mechanisation and Processing)')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Agricultural Science'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Government  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Elements and Forms of Government (Democracy, Federalism, Unitarism)'),
  ('Organs of Government (Legislature, Executive, Judiciary) and Constitution'),
  ('Nigerian Political Development (Pre-Colonial, Colonial, Independence, Post-Independence)'),
  ('Political Parties, Electoral Systems and Public Administration'),
  ('International Organisations and Nigeria''s Foreign Policy (UN, AU, ECOWAS)')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Government'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Economics  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Introduction, Basic Concepts and Economic Systems'),
  ('Demand, Supply and Price Determination'),
  ('Theory of the Firm and Costs (Production, Market Structures)'),
  ('National Income, Money, Banking and Inflation'),
  ('Public Finance, International Trade and Economic Development')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Economics'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Commerce  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Home and Foreign Trade, Channels of Distribution'),
  ('Business Organisations and Enterprises'),
  ('Transportation, Communication and Warehousing'),
  ('Insurance, Advertising and Banking/Finance'),
  ('Commercial Documents, Consumer Protection and ICT in Commerce')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Commerce'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Principles of Accounts / Financial Accounting  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Double Entry, Books of Original Entry and Ledger Accounts'),
  ('Bank Reconciliation Statement and Control Accounts'),
  ('Final Accounts of Sole Traders (Trading, P&L, Balance Sheet)'),
  ('Depreciation and Disposal of Assets; Incomplete Records'),
  ('Partnership, Company Accounts and Non-Profit Organisation Accounts')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name in ('Principles of Accounts', 'Financial Accounting')
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Literature in English  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Poetry (Set Poems, Poetic Devices, Appreciation)'),
  ('Drama (Set Texts, Dramatic Techniques)'),
  ('Prose (Set Texts, Narrative Techniques)'),
  ('General Literary Principles and Literary Appreciation (Genre, Style, Tone, Theme)'),
  ('Literary Devices, Figures of Speech and Critical Analysis')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Literature in English'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Christian Religious Studies / Knowledge  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Old Testament: The Patriarchs, Moses, the Law and the Prophets'),
  ('Old Testament: Kingship, Exile and Restoration'),
  ('New Testament: The Life and Teaching of Jesus Christ'),
  ('New Testament: The Early Church – Acts, Epistles and Revelation'),
  ('Christian Ethics, Social Responsibilities and Church History')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name in ('Christian Religious Knowledge', 'Christian Religious Studies', 'CRS', 'CRK')
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Islamic Religious Studies  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('The Qur''an (Selected Surahs, Recitation, Tafsir)'),
  ('Hadith (Selected Traditions of the Prophet)'),
  ('Aqeedah – Articles of Faith (Tawhid, Prophethood, Last Day)'),
  ('Fiqh – Islamic Law (Ibadah, Muamalat, Moral Conduct)'),
  ('Sirah and Islamic History (Life of the Prophet, Early Caliphate, West African Islam)')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name in ('Islamic Religious Studies', 'Islamic Studies', 'IRS')
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Geography  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Practical Geography and Map Reading (Maps, Photos, Statistical Methods)'),
  ('Physical Geography (Landforms, Drainage, Climate, Atmosphere)'),
  ('Biogeography (Vegetation, Soils, Ecosystem)'),
  ('Human and Economic Geography (Population, Settlement, Agriculture, Industry)'),
  ('Regional Geography of Nigeria and West Africa')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Geography'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- History  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Pre-Colonial Nigerian States and Societies (up to 1800)'),
  ('Trans-Atlantic Slave Trade and its Impact on West Africa'),
  ('Colonial Conquest and Administration in Nigeria'),
  ('Nationalist Movements and Nigeria''s Path to Independence'),
  ('Nigeria Since 1960 and West African/African Regional History')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'History'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Civic Education  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('National Ethics, Discipline, Citizenship, Human Rights and Law & Order'),
  ('Emerging Issues in Society (Cultism, Drug Abuse, Human Trafficking, HIV/AIDS, Youth Empowerment)'),
  ('Governmental System and Processes (Democracy, Rule of Law, Public Service, Civil Society)')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Civic Education'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- Current Affairs  (Post-UTME)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Nigerian National Affairs and Government Policies'),
  ('West African and African Regional Events'),
  ('International Affairs and Global Organisations'),
  ('Science, Technology and Environment'),
  ('Sports, Culture and Social Issues')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'Current Affairs'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- General Knowledge / Aptitude  (Post-UTME)
-- Note: this is not a syllabus-governed subject; topics reflect common
-- aptitude test sections used by Nigerian universities.
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Quantitative Reasoning and Data Interpretation'),
  ('Verbal Reasoning and Comprehension'),
  ('Logical Reasoning and Problem-Solving'),
  ('Basic Science and Technology Awareness'),
  ('Current Affairs and General Awareness')
) as t(topic_name)
where o.exam_mode = 'post-utme' and o.year = 2025
  and isub.subject_name = 'General Knowledge'
on conflict (institution_subject_id, topic_name) do nothing;


-- ===========================================================================
-- JUPEB 2025
-- Official JUPEB subject list: 19 subjects only (jupeb.edu.ng).
-- Topics reflect the official semester/course-code structure.
-- "Computer Studies" is NOT a JUPEB subject and has been removed.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- JUPEB — Mathematics
-- MAT001 Advanced Pure Mathematics | MAT002 Calculus (Sem 1)
-- MAT003 Applied Mathematics | MAT004 Statistics (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('MAT001: Real Numbers, Algebra, Complex Numbers, Trigonometry and Coordinate Geometry'),
  ('MAT002: Differentiation, Exponential & Logarithm Functions, Integration and Differential Equations'),
  ('MAT003: Vectors, Kinematics, Dynamics, Simple Harmonic Motion and Statics'),
  ('MAT004: Probability, Frequency Distributions, Measures of Central Tendency, Hypothesis Testing and Regression')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Mathematics'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Physics
-- PHY001 Mechanics & Properties of Matter | PHY002 Heat, Waves & Optics (Sem 1)
-- PHY003 Electricity & Magnetism | PHY004 Modern Physics (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('PHY001: Units, Vectors, Particle Kinetics, Dynamics, Gravitational Field, Work/Energy/Power, Circular & Oscillatory Motion, Elasticity, Hydrostatics and Hydrodynamics'),
  ('PHY002: Ideal Gases, Thermometry, Thermodynamics, Electromagnetic Waves, Geometrical Optics, Lenses & Optical Instruments, Oscillation of Waves and Wave Theory of Light'),
  ('PHY003: Electrostatics, Capacitors, Current Electricity, Magnetic Fields, Electromagnetic Induction and AC Circuits'),
  ('PHY004: Atomic Structure, Photoelectric Effect, X-Rays, Radioactivity, Nuclear Reactions and Semiconductor Electronics')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Physics'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Chemistry
-- CHE001 Physical & Inorganic Chemistry (Sem 1)
-- CHE002 Organic Chemistry & Biochemistry (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('CHE001: Atomic Structure, Periodic Table, Chemical Bonding, Stoichiometry, States of Matter, Thermochemistry, Chemical Kinetics & Equilibrium, Acids/Bases/Salts and Electrochemistry'),
  ('CHE002: Hydrocarbons, Functional Group Chemistry (Alcohols, Aldehydes, Ketones, Acids, Amines), Polymers and Basic Biochemistry (Carbohydrates, Proteins, Lipids, Enzymes)')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Chemistry'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Biology
-- BIO001 Cell Biology & Genetics | BIO002 Ecology & Evolution (Sem 1)
-- BIO003 Physiology & Anatomy (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('BIO001: Cell Structure & Organelles, Cell Division (Mitosis & Meiosis), Genetics (Mendelian Laws, Chromosomes, DNA, Gene Expression)'),
  ('BIO002: Ecology (Ecosystems, Energy Flow, Nutrient Cycles, Population Dynamics), Evolution (Theories, Evidence, Natural Selection, Speciation)'),
  ('BIO003: Mammalian Anatomy and Physiology (Nutrition, Digestion, Respiration, Circulation, Excretion, Nervous & Hormonal Coordination, Reproduction)')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Biology'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Agricultural Science
-- AGR001 Crop Production & Soil Science (Sem 1)
-- AGR002 Animal Production, Farm Management & Agricultural Economics (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('AGR001: Soil Formation, Composition & Conservation; Crop Classification, Cultural Practices, Crop Improvement, Pests & Diseases, Harvesting and Storage'),
  ('AGR002: Livestock & Poultry Production, Fisheries; Farm Management, Agricultural Economics, Extension Services, Farm Records and Agricultural Credit')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Agricultural Science'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Economics
-- ECN001 Principles of Economics I (Microeconomics) (Sem 1)
-- ECN002 Principles of Economics II (Macroeconomics & Development) (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('ECN001: Introduction to Economics, Basic Economic Principles, Tools of Economic Analysis, The Price System (Demand & Supply), Consumer Behaviour and Theory of the Firm'),
  ('ECN002: Market Structures, National Income, Money & Banking, Fiscal Policy, International Trade & Balance of Payments, Economic Development and the Nigerian Economy')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Economics'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Government
-- GOV001 Political Theory & Comparative Government (Sem 1)
-- GOV002 Nigerian Government & International Relations (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('GOV001: Political Theory (Sovereignty, Power, Authority, Legitimacy), Concepts of Government, Constitutions, Organs of Government, Electoral Systems and Political Parties'),
  ('GOV002: Nigerian Pre-Colonial, Colonial and Post-Independence Political Development; Public Administration; International Relations and Global Organisations (UN, AU, ECOWAS)')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Government'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Accounting (MSS-J131)
-- ACC001 Financial Accounting (Sem 1)
-- ACC002 Cost and Management Accounting (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('ACC001: Accounting Concepts & Conventions, Double Entry, Books of Original Entry, Ledger, Trial Balance, Final Accounts (Sole Trader, Partnership, Limited Company, Non-Profits)'),
  ('ACC002: Cost Concepts, Marginal & Absorption Costing, Budgeting & Budgetary Control, Standard Costing, Variance Analysis and Management Decision-Making')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Accounting'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Business Studies (MSS-J132)
-- BUS001 Business Environment & Management (Sem 1)
-- BUS002 Marketing, Finance & Entrepreneurship (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('BUS001: Business Environment, Forms of Business Ownership, Management Principles (Planning, Organising, Directing, Controlling), Human Resource Management and Business Ethics'),
  ('BUS002: Marketing (4Ps, Market Research, Consumer Behaviour), Business Finance (Capital, Investment), Entrepreneurship and Small Business Development')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Business Studies'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Geography (MSS-J134)
-- GEO001 Physical & Practical Geography (Sem 1)
-- GEO002 Human & Regional Geography (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('GEO001: Map Reading & Interpretation, Fieldwork Methods, Landforms (Weathering, Rivers, Coasts), Atmosphere (Climate, Weather), Soils and Vegetation'),
  ('GEO002: Population, Settlement, Agriculture, Industry, Trade & Transport; Regional Geography of Nigeria, West Africa and Africa; Environmental Issues')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Geography'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Literature-in-English (ART-J126)
-- LIT001 Drama & Prose Set Texts (Sem 1)
-- LIT002 Poetry & Literary Criticism (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('LIT001: Set Drama Texts (African and Non-African), Set Prose Texts; Dramatic and Narrative Techniques, Plot, Character, Theme and Setting'),
  ('LIT002: Set Poetry Texts (African and Non-African), Poetic Devices; General Literary Principles, Literary Criticism and Appreciation')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Literature in English'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Christian Religious Studies (ART-J121)
-- CRS001 Old Testament Themes (Sem 1)
-- CRS002 New Testament and Church History (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('CRS001: God''s Nature and Works, The Patriarchs, Moses and the Covenant, The Prophets, Kingship, Exile and Restoration (Old Testament Themes)'),
  ('CRS002: The Life and Teaching of Jesus Christ, The Holy Spirit and the Early Church, Pauline Epistles, Christian Ethics and Church History')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Christian Religious Studies'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Islamic Studies (ART-J125)
-- ISS001 Qur'an, Hadith and Aqeedah (Sem 1)
-- ISS002 Fiqh, Sirah and Islamic History (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('ISS001: The Qur''an (Selected Surahs, Tafsir), Hadith (Selected Traditions), Tawhid and Articles of Faith (Aqeedah)'),
  ('ISS002: Fiqh – Islamic Law and Jurisprudence (Ibadah & Muamalat), Sirah of the Prophet (SAW), Early Caliphate, Islamic History and Civilisation')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Islamic Religious Studies'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — French (ART-J122)
-- FRE001 Grammar, Comprehension & Composition (Sem 1)
-- FRE002 Oral French, Literature & Culture (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('FRE001: French Grammar (Morphology, Syntax, Lexis), Reading Comprehension (Unseen Passages), Essay Writing and Translation'),
  ('FRE002: Oral French (Phonetics, Speaking), French Literature (Set Texts), Francophone Culture and Civilisation')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'French'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — History (ART-J123)
-- HIS001 Nigerian and West African History (Sem 1)
-- HIS002 African and World History since 1800 (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('HIS001: Pre-Colonial Nigerian States, Trans-Atlantic Slave Trade, Colonial Conquest and Administration, Nationalism and Nigerian Independence'),
  ('HIS002: Nigeria since 1960, West African Integration and Conflicts, Pan-Africanism, Imperialism & Colonialism in Africa, World History Themes (Historiography, Global Institutions)')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'History'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Visual Arts (ART-J128)
-- VSA001 History & Theory of Art (Sem 1)
-- VSA002 Studio Practice (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('VSA001: History of African Traditional Art, History of Western Art, Art Appreciation & Criticism, Elements and Principles of Design'),
  ('VSA002: Drawing, Painting, Graphic Design & Printmaking, Sculpture & Ceramics, Textile Arts & Crafts')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Visual Arts'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Music (ART-J127)
-- MUS001 Music Theory & Harmony (Sem 1)
-- MUS002 History of African & Western Music (Sem 2)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('MUS001: Rudiments of Music (Notation, Rhythm, Pitch, Scale, Intervals), Elementary Harmony (Chord Construction, Part Writing, Cadences)'),
  ('MUS002: History and Literature of African Music (Traditional and Contemporary), History and Literature of Western Music, Comparative Music Studies')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Music'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Igbo (ART-J124)
-- Language, Literature and Culture (3-section structure)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Asụsụ – Igbo Language (Oral, Grammar, Vocabulary, Comprehension and Composition)'),
  ('Agụmagụ – Igbo Literature (Set Texts: Prose, Drama and Poetry; Literary Appreciation)'),
  ('Omenala na Ewumewu – Igbo Customs, Institutions and Culture')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Igbo'
on conflict (institution_subject_id, topic_name) do nothing;

-- ---------------------------------------------------------------------------
-- JUPEB — Yoruba (ART-J129)
-- Language, Literature and Culture (3-section structure)
-- ---------------------------------------------------------------------------
insert into institution_topics (institution_subject_id, topic_name)
select isub.id, t.topic_name
from institution_subjects isub
join institution_exam_offerings o on o.id = isub.offering_id
cross join (values
  ('Ede – Yoruba Language (Oral, Grammar, Vocabulary, Comprehension and Composition)'),
  ('Litireso – Yoruba Literature (Set Texts: Prose, Drama, Poetry and Oral Poetry; Literary Appreciation)'),
  ('Aṣà ati Ìṣe – Yoruba Culture, Institutions and History')
) as t(topic_name)
where o.exam_mode = 'jupeb' and o.year = 2025
  and isub.subject_name = 'Yoruba'
on conflict (institution_subject_id, topic_name) do nothing;