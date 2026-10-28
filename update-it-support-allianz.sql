-- ============================================================================
--  update-it-support-allianz.sql
--  IT Support Specialist (Allianz Head Office) + Full-Stack Developer + Designer
--
--  How to run:
--  1. Open your Supabase Project Dashboard (https://supabase.com/dashboard)
--  2. Click on "SQL Editor" in the left sidebar
--  3. Click "New query"
--  4. Paste this entire script and click "Run" (Ctrl + Enter)
-- ============================================================================

-- ─────────────────────────────────────────────────────────────
-- 1. DYNAMIC COLUMNS SETUP (Idempotent - Safe to run anytime)
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.portfolio_profile_settings
  ADD COLUMN IF NOT EXISTS hero_title_name         text,
  ADD COLUMN IF NOT EXISTS hero_title_role         text,
  ADD COLUMN IF NOT EXISTS hero_cta_work_label     text,
  ADD COLUMN IF NOT EXISTS hero_cta_work_url       text,
  ADD COLUMN IF NOT EXISTS hero_cta_hire_label     text,
  ADD COLUMN IF NOT EXISTS hero_cta_hire_url       text,
  ADD COLUMN IF NOT EXISTS years_exp_label         text,
  ADD COLUMN IF NOT EXISTS deployed_systems_label  text,
  ADD COLUMN IF NOT EXISTS freelance_clients_label text,
  ADD COLUMN IF NOT EXISTS about_section_title     text,
  ADD COLUMN IF NOT EXISTS about_badge_icon        text,
  ADD COLUMN IF NOT EXISTS about_badge_title       text,
  ADD COLUMN IF NOT EXISTS about_badge_sub         text,
  ADD COLUMN IF NOT EXISTS about_heading           text,
  ADD COLUMN IF NOT EXISTS about_paragraphs        text[],
  ADD COLUMN IF NOT EXISTS about_img_url           text,
  ADD COLUMN IF NOT EXISTS cv_url                  text,
  ADD COLUMN IF NOT EXISTS cv_label                text,
  ADD COLUMN IF NOT EXISTS skills_section_title    text,
  ADD COLUMN IF NOT EXISTS journey_section_title   text,
  ADD COLUMN IF NOT EXISTS reviews_section_title   text,
  ADD COLUMN IF NOT EXISTS reviews_section_desc    text,
  ADD COLUMN IF NOT EXISTS gallery_section_title   text,
  ADD COLUMN IF NOT EXISTS contact_section_title   text,
  ADD COLUMN IF NOT EXISTS page_title              text,
  ADD COLUMN IF NOT EXISTS meta_description        text,
  ADD COLUMN IF NOT EXISTS meta_keywords           text,
  ADD COLUMN IF NOT EXISTS show_gallery            boolean DEFAULT true,
  ADD COLUMN IF NOT EXISTS show_reviews            boolean DEFAULT true;


-- ─────────────────────────────────────────────────────────────
-- 2. PROFILE SETTINGS
-- ─────────────────────────────────────────────────────────────
UPDATE public.portfolio_profile_settings
SET
  about_section_title     = 'About Me',
  skills_section_title    = 'What I Do',
  journey_section_title   = 'My Journey',
  reviews_section_title   = 'Client Reviews',
  reviews_section_desc    = 'Real feedback from freelance clients, reflecting reliability, communication and delivery quality.',
  gallery_section_title   = 'Design Gallery',
  contact_section_title   = 'Get In Touch',

  hero_title_name         = 'Sachintha Shyamika',
  hero_title_role         = 'IT Support Specialist at Allianz Head Office',
  availability_status     = 'IT Support Specialist at Allianz Head Office',
  availability_badge      = 'IT Support Specialist at Allianz Head Office',
  hero_roles              = ARRAY[
    'IT Support Specialist at Allianz.',
    'Full-Stack Developer.',
    'Enterprise Systems Support.',
    'UI/UX & Graphic Designer.',
    'IT Operations Associate.',
    'Problem Solver.'
  ],
  hero_subtitle           = 'IT Support Specialist at Allianz Head Office and HNDIT undergraduate. Delivering enterprise end-user computing, Active Directory administration, hardware troubleshooting, and network diagnostics — backed by full-stack web development and UI/UX design capabilities.',
  hero_cta_work_label     = 'Explore Work & Projects',
  hero_cta_work_url       = '#portfolio-section',
  hero_cta_hire_label     = 'View Experience',
  hero_cta_hire_url       = '#journey-section',

  years_exp               = '5+',
  years_exp_label         = 'Years Technical Experience',
  deployed_systems        = '10+',
  deployed_systems_label  = 'Deployed Systems & Solutions',
  freelance_clients       = '40+',
  freelance_clients_label = 'Global Clients & Support',
  cgpa_value              = '3.70',
  cgpa_label              = 'HNDIT Cumulative GPA — Semester I-III',
  cgpa_note               = 'Average across 3 completed semesters.',

  about_badge_icon        = 'fa-headset',
  about_badge_title       = 'IT Support Specialist at Allianz Head Office',
  about_badge_sub         = 'Enterprise Systems & Web Engineering',
  about_heading           = 'Enterprise IT reliability combined with full-stack engineering',
  about_paragraphs        = ARRAY[
    'I''m an IT undergraduate (HNDIT — SLIATE) and Cyber Security diploma student, currently working as an <strong>IT Support Specialist at Allianz Head Office</strong> alongside my studies.',
    'On the enterprise support side, I handle day-to-day corporate IT operations at Allianz, including Active Directory user and identity management, Microsoft 365 administration, corporate network connectivity troubleshooting (LAN/WLAN/VPN), and high-priority incident ticketing adhering to strict SLAs.',
    'On the software side, I design and build end-to-end full-stack web systems using modern stacks like JavaScript/TypeScript, React, Next.js, Node.js, PHP/MySQL, Firebase, and Supabase. Having both development and systems support experience allows me to troubleshoot issues from physical hardware and networking layers all the way up to database queries and application code.',
    'I also bring 3+ years of freelance experience as a Fiverr Level 1 Seller with over 100+ five-star reviews under my digital brand <strong>RuuGraphics</strong>, delivering UI/UX prototypes and brand identities for international clients.'
  ],
  cv_url                  = 'Sachintha Shyamika.pdf',
  cv_label                = 'Download CV',

  page_title              = 'Sachintha Shyamika | IT Support Specialist at Allianz Head Office',
  meta_description        = 'Sachintha Shyamika — IT Support Specialist at Allianz Head Office and Full-Stack Developer from Colombo, Sri Lanka. Enterprise Systems Support, Active Directory, Network Troubleshooting, and Production Web Systems.',
  meta_keywords           = 'Sachintha Shyamika, IT Support Specialist, Allianz Sri Lanka, Full-Stack Developer, Systems Administrator, Active Directory, Microsoft 365, Next.js, React, Node.js, UI UX designer, HNDIT SLIATE',

  show_gallery            = true,
  show_reviews            = true,
  updated_at              = NOW()
WHERE id = 'main_profile';


-- ─────────────────────────────────────────────────────────────
-- 3. PROJECTS (KEEP ALL PUBLISHED)
-- ─────────────────────────────────────────────────────────────
UPDATE public.portfolio_projects  SET is_published = true;
UPDATE public.portfolio_uiux      SET is_published = true;
UPDATE public.portfolio_graphics  SET is_published = true;


-- ─────────────────────────────────────────────────────────────
-- 4. WORK EXPERIENCE
-- ─────────────────────────────────────────────────────────────
DELETE FROM public.portfolio_experience WHERE company ILIKE '%Allianz%';

-- 1. Allianz IT Support Role (Top Priority)
INSERT INTO public.portfolio_experience (
  title, company, period, achievements, icon, sort_order, is_published
) VALUES (
  'IT Support Specialist',
  'Allianz Insurance Sri Lanka — Head Office',
  '2026 — Present',
  ARRAY[
    'Delivering enterprise L1/L2 technical support for end-users, ensuring timely resolution of hardware, OS, and software issues.',
    'Administering user accounts, credentials, and access permissions using Active Directory and Microsoft 365 Admin Center.',
    'Managing incident workflows and service requests via enterprise ticketing systems adhering to strict corporate SLAs.',
    'Troubleshooting corporate LAN/WiFi, VPN connectivity, printer configurations, and peripheral setup.',
    'Handling Windows Enterprise deployments, system maintenance, and adhering to financial data security policies.'
  ],
  'fa-headset', 1, true
);

-- 2. Junior Web Systems Developer (Project-Based)
UPDATE public.portfolio_experience
SET sort_order = 2, is_published = true,
    title      = 'Junior Web Systems Developer (Project-Based)',
    company    = 'Academic & Production Systems'
WHERE id = '19afe068-3125-4817-a12c-f193cb4bd730';

-- 3. Freelance Designer & Digital Service Provider (Fiverr Level 1)
UPDATE public.portfolio_experience
SET sort_order = 3, is_published = true,
    title      = 'Freelance Designer & Digital Service Provider',
    company    = 'Level 1 Seller — Fiverr.com — Remote / Worldwide Clients'
WHERE id = '63e782fe-439d-4d4b-b3fc-3a1511ab71f9';

-- 4. IT Support & Hardware Troubleshooting
UPDATE public.portfolio_experience
SET sort_order = 4, is_published = true,
    title      = 'IT Support & Hardware Troubleshooting',
    company    = 'Personal & Hands-on Experience — System & Network Maintenance'
WHERE id = '258b24bc-9981-41e3-9023-d43b162d3181';


-- ─────────────────────────────────────────────────────────────
-- 5. SKILLS
-- ─────────────────────────────────────────────────────────────

-- 1. IT Support & Hardware Diagnostics
UPDATE public.portfolio_skills
SET sort_order = 1, is_published = true, title = 'IT Support & Hardware Diagnostics',
    tags = 'Windows 10/11 Enterprise [main], Active Directory [main], PC / Laptop Diagnostics [main], Driver & Peripheral Config [core], Remote Desktop Support [core], MS Office Suite & M365, Hardware Maintenance'
WHERE id = '8a87dee5-17d5-4f63-a80d-df850bbcabfc';

-- 2. Cyber Security & Networking
UPDATE public.portfolio_skills
SET sort_order = 2, is_published = true, title = 'Cyber Security & Networking',
    tags = 'Basic Networking (TCP/IP) [main], VPN & LAN/WLAN Support [main], DNS & DHCP Basics [core], Endpoint Protection [core], RBAC & Password Security, Network Troubleshooting'
WHERE id = 'b64de50e-bb0e-41a7-9ca0-8c0fd04bb06f';

-- 3. Frontend & Frameworks
UPDATE public.portfolio_skills
SET sort_order = 3, is_published = true,
    tags = 'JavaScript (ES6+) [main], HTML5 / CSS3 [main], React.js [main], Next.js 16 [main], TypeScript [core], Tailwind CSS v4 [core], Responsive Design [core], Leaflet Maps, WordPress'
WHERE id = 'e71e5c4b-f476-4d94-850d-dc685426f31a';

-- 4. Backend & Databases
UPDATE public.portfolio_skills
SET sort_order = 4, is_published = true,
    tags = 'Node.js / Express.js [main], PHP / MySQL [main], Firebase / Firestore [core], Supabase Storage [core], MongoDB Atlas [core], PostgreSQL (Neon) [core], Prisma ORM [core], REST APIs, Real-Time Sync'
WHERE id = '045018f3-0c42-40cf-bf22-d959f41e1bab';

-- 5. Scripting & Programming
UPDATE public.portfolio_skills
SET sort_order = 5, is_published = true,
    tags = 'JavaScript [main], PHP [main], TypeScript [core], SQL [core], C#, Java, OOP Principles, Automation Mindset'
WHERE id = 'ddb21144-b810-4993-a222-5ed267232c38';

-- 6. Auth, Payments & Integrations
UPDATE public.portfolio_skills
SET sort_order = 6, is_published = true,
    tags = 'JWT Auth / OTP [main], PayHere Gateway [main], Firebase Auth [core], Clerk Auth [core], EmailJS [core], RBAC Security [core], Bcrypt, Binance API'
WHERE id = 'b2ae68de-2308-4d46-877d-ebaa6f22f048';

-- 7. ITSM & Documentation
UPDATE public.portfolio_skills
SET sort_order = 7, is_published = true, title = 'ITSM & Documentation',
    tags = 'SOP & Knowledge Base [main], Ticket Lifecycle Management [main], SLA Adherence [core], Incident & Issue Logs [core], Clear User Guidance, Cross-Team Collaboration'
WHERE id = '867ace81-a55c-4151-bf60-34c425a1669b';

-- 8. Enterprise Tools & Platforms
UPDATE public.portfolio_skills
SET sort_order = 8, is_published = true, title = 'Enterprise Tools & Platforms',
    tags = 'Active Directory Users & Computers [main], Microsoft 365 Admin Center [main], Remote Support (AnyDesk/RDP) [core], Ticket Systems (ServiceNow/Jira) [core], VS Code, Git / GitHub, Postman'
WHERE id = 'b8933829-3626-46b7-93b6-35aeabf5bab7';

-- 9. UI/UX & Graphic Design
UPDATE public.portfolio_skills
SET sort_order = 9, is_published = true,
    tags = 'Figma [main], Adobe Illustrator [main], Adobe Photoshop [core], Canva [core], Brand Identity, Logo Design, Landing Page Design, Design Systems'
WHERE id = 'b6bad3e4-ca4e-4f83-902c-924986099175';

-- 10. Academic Foundation (HNDIT Coursework)
UPDATE public.portfolio_skills
SET sort_order = 10, is_published = true,
    tags = 'Data Structures & Algorithms [main], Database Management Systems [main], System Analysis & Design [core], Software Engineering Practices [core], Computer & Network Systems, Operating Systems'
WHERE id = '53b5beb9-e868-4e4c-95a5-a1c263451cb9';

-- 11. AI Productivity & Troubleshooting Tools
UPDATE public.portfolio_skills
SET sort_order = 11, is_published = true,
    tags = 'ChatGPT [main], Claude AI [main], Prompt Engineering [core], AI-Assisted Troubleshooting [core], Google Gemini, Workflow Automation'
WHERE id = '9c978d64-9581-4d91-a835-565d108d4ed1';


-- ─────────────────────────────────────────────────────────────
-- VERIFICATION QUERY
-- ─────────────────────────────────────────────────────────────
SELECT id, hero_title_role, availability_status, availability_badge, years_exp, deployed_systems
  FROM public.portfolio_profile_settings WHERE id = 'main_profile';
SELECT title, company, period, sort_order, is_published
  FROM public.portfolio_experience ORDER BY sort_order;
SELECT title, sort_order, is_published
  FROM public.portfolio_skills WHERE is_published = true ORDER BY sort_order;
SELECT title, category, is_published
  FROM public.portfolio_projects ORDER BY sort_order;
 