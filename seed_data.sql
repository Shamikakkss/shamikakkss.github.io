-- ============================================================
-- Complete Supabase Seed SQL Script for Sachintha Shyamika Portfolio
-- Run this in your Supabase SQL Editor (SQL Editor -> New Query)
-- ============================================================

-- CREATE TABLES (If missing in Supabase)

CREATE TABLE IF NOT EXISTS public.portfolio_profile_settings (
  id text PRIMARY KEY DEFAULT 'main_profile',
  availability_status text,
  availability_badge text,
  hero_title_name text,
  hero_title_role text,
  hero_roles text[],
  hero_subtitle text,
  years_exp text,
  deployed_systems text,
  freelance_clients text,
  cgpa_value text,
  cgpa_label text,
  cgpa_note text,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.portfolio_uiux (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  slug text UNIQUE NOT NULL,
  title text NOT NULL,
  category text,
  card_desc text,
  modal_desc text,
  tagline text,
  tools text[],
  images text[],
  banner_url text,
  external_url text,
  badge_text text,
  is_published boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.portfolio_graphics (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  slug text UNIQUE NOT NULL,
  title text NOT NULL,
  category text,
  card_desc text,
  tools text[],
  image_url text,
  gallery_urls text[],
  client_name text,
  badge_text text,
  external_url text,
  is_published boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.portfolio_experience (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  period text NOT NULL,
  title text NOT NULL,
  company text,
  achievements text[],
  link_url text,
  link_label text,
  icon text DEFAULT 'fa-briefcase',
  icon_style text DEFAULT 'primary',
  is_published boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.portfolio_education (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  semester_key text UNIQUE NOT NULL,
  semester_title text NOT NULL,
  module_count_text text,
  gpa_text text NOT NULL,
  is_pending boolean DEFAULT false,
  modules jsonb DEFAULT '[]'::jsonb,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.portfolio_skills (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  icon text DEFAULT 'fa-code',
  theme_accent text DEFAULT 'primary',
  tags text NOT NULL,
  is_published boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.portfolio_certifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  issuer text NOT NULL,
  issue_date text,
  credential_url text,
  badge_icon text DEFAULT 'fa-certificate',
  is_published boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now()
);


-- ROW LEVEL SECURITY (RLS) POLICIES FOR PUBLIC READ & ADMIN ACCESS

ALTER TABLE public.portfolio_profile_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_uiux ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_graphics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_education ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_certifications ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "Public Read Profile" ON public.portfolio_profile_settings FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "Admin Profile All" ON public.portfolio_profile_settings FOR ALL USING (true);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Public Read UIUX" ON public.portfolio_uiux FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "Admin UIUX All" ON public.portfolio_uiux FOR ALL USING (true);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Public Read Graphics" ON public.portfolio_graphics FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "Admin Graphics All" ON public.portfolio_graphics FOR ALL USING (true);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Public Read Experience" ON public.portfolio_experience FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "Admin Experience All" ON public.portfolio_experience FOR ALL USING (true);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Public Read Education" ON public.portfolio_education FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "Admin Education All" ON public.portfolio_education FOR ALL USING (true);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Public Read Skills" ON public.portfolio_skills FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "Admin Skills All" ON public.portfolio_skills FOR ALL USING (true);
EXCEPTION WHEN others THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY "Public Read Certifications" ON public.portfolio_certifications FOR SELECT USING (true);
EXCEPTION WHEN others THEN NULL; END $$;
DO $$ BEGIN
  CREATE POLICY "Admin Certifications All" ON public.portfolio_certifications FOR ALL USING (true);
EXCEPTION WHEN others THEN NULL; END $$;


-- ============================================================
-- SEED DATA INSERTS
-- ============================================================

-- 1. PROFILE & AVAILABILITY SETTINGS
INSERT INTO public.portfolio_profile_settings (
  id,
  availability_status,
  availability_badge,
  hero_title_name,
  hero_title_role,
  hero_roles,
  hero_subtitle,
  years_exp,
  deployed_systems,
  freelance_clients,
  cgpa_value,
  cgpa_label,
  cgpa_note
) VALUES (
  'main_profile',
  'Open for Internship & Full-Time Opportunities',
  'Available for Hire',
  'Sachintha',
  'IT Professional & Full-Stack Developer.',
  ARRAY['IT Professional.', 'Full-Stack Developer.', 'IT Support Specialist.', 'Software Engineer.', 'IT Assistant.', 'IT Executive.', 'UI/UX Designer.', 'Web Developer.', 'Problem Solver.', 'Freelancer.'],
  'IT undergraduate skilled in Full-Stack Web Development and IT Support. I build production web systems, troubleshoot hardware/software issues, and apply network fundamentals to deliver practical technical solutions.',
  '3+',
  '6+',
  '40+ Global',
  '3.70',
  'HNDIT Cumulative GPA — Semester I–III',
  'Average across 3 completed semesters. Semester IV result is pending.'
) ON CONFLICT (id) DO UPDATE SET
  availability_status = EXCLUDED.availability_status,
  hero_title_name = EXCLUDED.hero_title_name,
  hero_title_role = EXCLUDED.hero_title_role,
  hero_roles = EXCLUDED.hero_roles,
  hero_subtitle = EXCLUDED.hero_subtitle,
  years_exp = EXCLUDED.years_exp,
  deployed_systems = EXCLUDED.deployed_systems,
  freelance_clients = EXCLUDED.freelance_clients,
  cgpa_value = EXCLUDED.cgpa_value,
  cgpa_note = EXCLUDED.cgpa_note;


-- 2. UI/UX CASE STUDIES
INSERT INTO public.portfolio_uiux (
  slug, title, category, card_desc, modal_desc, tagline, tools, images, banner_url, external_url, badge_text, is_published, sort_order
) VALUES (
  'food-delivery-app',
  'Food Delivery App',
  'Mobile App',
  'Complete UI/UX case study for a multi-vendor food ordering & delivery mobile application.',
  'A mobile app design case study featuring landing page, sign-in, account creation, order placement, order history, live conversation, and customer support chat screens.',
  'Figma Mobile App Design',
  ARRAY['Figma'],
  ARRAY['uiux/project-01/01-landing-page.png', 'uiux/project-01/02-sign-in.png', 'uiux/project-01/03-create-account.png', 'uiux/project-01/04-place-order.png', 'uiux/project-01/05-my-orders.png', 'uiux/project-01/06-order-conversation.png', 'uiux/project-01/07-support-chat.png'],
  'uiux/project-01/01-landing-page.png',
  'https://www.figma.com/',
  'Mobile App',
  true,
  1
) ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  card_desc = EXCLUDED.card_desc;


-- 3. GRAPHIC DESIGN SHOWCASE
INSERT INTO public.portfolio_graphics (
  slug, title, category, card_desc, tools, image_url, gallery_urls, client_name, badge_text, external_url, is_published, sort_order
) VALUES (
  'ruugraphics-brand-kit',
  'RuuGraphics Brand & Promotional Suite',
  'Full Branding Kit',
  'Comprehensive brand identity suite including logos, stationery mockups, and promotional flyers.',
  ARRAY['Illustrator', 'Photoshop'],
  'graphics/project-01/01-logo.jpg',
  ARRAY['graphics/project-01/01-logo.jpg', 'graphics/project-01/02-logo.jpg', 'graphics/project-01/03.jpg', 'graphics/project-01/04.jpg', 'graphics/project-01/mockup 04.jpg', 'graphics/project-01/mockup 08.jpg'],
  'RuuGraphics',
  'Branding Kit',
  'https://www.fiverr.com/s_sdesigns',
  true,
  1
) ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  card_desc = EXCLUDED.card_desc;


-- 4. WORK EXPERIENCE
INSERT INTO public.portfolio_experience (
  period, title, company, achievements, link_url, link_label, icon, icon_style, is_published, sort_order
) VALUES 
(
  '2023 Jan — Present · 2 yrs 7 mos',
  'Freelance Designer & Digital Service Provider',
  'Level 1 Seller · Fiverr.com · Remote / Worldwide Clients',
  ARRAY[
    'Handled end-to-end client communication, requirement clarification, and structured delivery cycles across global remote engagements.',
    'Maintained Level 1 Seller status through high quality, reliable communication, and consistent on-time delivery.',
    'Strengthened product-thinking habits: expectation setting, iterative improvements, and handling urgent requests under deadlines.',
    'Built strong ownership and execution discipline now applied to software project delivery.'
  ],
  'https://www.fiverr.com/s_sdesigns',
  'Visit My Fiverr Profile',
  'fa-star',
  'warm',
  true,
  1
),
(
  '2024 Jan — Present · 1 yr 7 mos',
  'Junior Web Systems Developer (Project-Based)',
  'Freelance & Academic Projects · Remote / Sri Lanka',
  ARRAY[
    'Built and supported RuuGraphics end-to-end, including admin workflows, real-time tracking, payment flows, and secure file handling.',
    'Developed and maintained PHP/MySQL systems (Fund Management and Student Management) with transaction logic and reporting.',
    'Performed practical debugging across UI, API, and database layers to restore system functionality quickly.',
    'Implemented authentication and access controls (OTP, RBAC, JWT patterns) to improve operational security.',
    'Gained strong exposure to production-style workflows: deployment, updates, issue fixes, and user-focused improvements.'
  ],
  'https://github.com/Shamikakkss',
  'View My GitHub',
  'fa-laptop-code',
  'primary',
  true,
  2
),
(
  '5+ Years Practical Experience',
  'IT Support & Hardware Troubleshooting',
  'Personal & Hands-on Experience · System & Network Maintenance',
  ARRAY[
    'Diagnosed and resolved PC/laptop hardware and software issues, including OS installation/recovery, driver setups, and fault-finding.',
    'Configured home Wi-Fi networks, routers, IP settings, and resolved local network connectivity issues.',
    'Developed strong systematic analytical skills and technical patience when debugging hardware and environment-level failures.'
  ],
  NULL,
  NULL,
  'fa-screwdriver-wrench',
  'accent',
  true,
  3
);


-- 5. EDUCATION & SEMESTER GPAS
INSERT INTO public.portfolio_education (
  semester_key, semester_title, module_count_text, gpa_text, is_pending, modules, sort_order
) VALUES 
(
  'sem1',
  'Semester I',
  '6 Modules',
  'GPA 3.90',
  false,
  '[{"code":"HNDIT1012","name":"Visual Application Programming"},{"code":"HNDIT1022","name":"Web Design"},{"code":"HNDIT1032","name":"Computer and Network Systems"},{"code":"HNDIT1042","name":"Information Management and Information Systems"},{"code":"HNDIT1052","name":"ICT Project (Individual)"},{"code":"HNDIT1062","name":"Communication Skills"}]'::jsonb,
  1
),
(
  'sem2',
  'Semester II',
  '8 Modules',
  'GPA 3.65',
  false,
  '[{"code":"HNDIT2012","name":"Fundamentals of Programming"},{"code":"HNDIT2022","name":"Software Development"},{"code":"HNDIT2032","name":"System Analysis and Design"},{"code":"HNDIT2042","name":"Data Communication and Computer Networks"},{"code":"HNDIT2052","name":"Principles of User Interface Design"},{"code":"HNDIT2062","name":"ICT Project (Group)"},{"code":"HNDIT2072","name":"Technical Writing"},{"code":"HNDIT2082","name":"Human Value & Professional Ethics"}]'::jsonb,
  2
),
(
  'sem3',
  'Semester III',
  '7 Modules',
  'GPA 3.54',
  false,
  '[{"code":"HNDIT3012","name":"Object Oriented Programming"},{"code":"HNDIT3022","name":"Web Programming"},{"code":"HNDIT3032","name":"Data Structures and Algorithms"},{"code":"HNDIT3042","name":"Database Management Systems"},{"code":"HNDIT3052","name":"Operating Systems"},{"code":"HNDIT3062","name":"Information and Computer Security"},{"code":"HNDIT3072","name":"Statistics for IT"}]'::jsonb,
  3
),
(
  'sem4',
  'Semester IV',
  '6 Modules',
  'Result Pending',
  true,
  '[{"code":"HNDIT4012","name":"Enterprise Application Development"},{"code":"HNDIT4022","name":"Software Quality Assurance"},{"code":"HNDIT4032","name":"Cloud Computing & DevOps"},{"code":"HNDIT4042","name":"Mobile Application Development"},{"code":"HNDIT4052","name":"Comprehensive Project"},{"code":"HNDIT4062","name":"Industrial Training"}]'::jsonb,
  4
) ON CONFLICT (semester_key) DO UPDATE SET
  gpa_text = EXCLUDED.gpa_text,
  is_pending = EXCLUDED.is_pending;


-- 6. TECHNICAL SKILLS (ALL 11 CARDS)
TRUNCATE TABLE public.portfolio_skills;

INSERT INTO public.portfolio_skills (title, icon, theme_accent, tags, is_published, sort_order) VALUES
('Frontend & Frameworks', 'fa-layer-group', 'primary', 'JavaScript (ES6+) [main], HTML5 / CSS3 [main], React.js [main], Next.js 16 [main], TypeScript [core], Tailwind CSS v4 [core], Responsive Design [core], Leaflet Maps, WordPress', true, 1),
('Backend & Databases', 'fa-server', 'primary', 'Node.js / Express.js [main], PHP / MySQL [main], Firebase / Firestore [core], Supabase Storage [core], MongoDB Atlas [core], PostgreSQL (Neon) [core], Prisma ORM [core], REST APIs, Real-Time Sync', true, 2),
('Auth, Payments & Integrations', 'fa-lock', 'accent', 'JWT Auth / OTP [main], PayHere Gateway [main], Firebase Auth [core], Clerk Auth [core], EmailJS [core], RBAC Security [core], Bcrypt, Binance API', true, 3),
('Scripting & Programming', 'fa-code', 'accent', 'JavaScript [main], PHP [main], TypeScript [core], SQL [core], C#, Java, OOP Principles, Automation Mindset', true, 4),
('Documentation & Communication', 'fa-pen-nib', 'warm', 'User-Friendly Explanations [main], Clear Written Updates [main], Task & Issue Logs [core], SOP-Style Documentation [core], Requirement Gathering, Cross-Team Collaboration, Client Brief Handling, Presentation Skills', true, 5),
('Tools & Platforms', 'fa-tools', 'primary', 'VS Code [main], Git / GitHub [main], GitHub Pages [core], Vercel [core], Visual Studio, NetBeans, Chrome DevTools, Postman, Docker (Learning) [learning]', true, 6),
('Cyber Security', 'fa-shield-halved', 'accent', 'Network Security [core], RBAC & Auth Hardening [core], Ethical Hacking [learning], Kali Linux [learning], Penetration Testing [learning], Basic Networking (TCP/IP), Security Tools', true, 7),
('UI/UX & Graphic Design', 'fa-swatchbook', 'warm', 'Figma [main], Adobe Illustrator [main], Adobe Photoshop [core], Canva [core], Brand Identity, Logo Design, Landing Page Design, Design Systems', true, 8),
('IT Support & Hardware', 'fa-computer', 'primary', 'Windows Install / Config / Recovery [main], PC / Laptop Setup & Fault-Finding [main], Wi-Fi / Router Setup [core], Driver & Peripheral Config [core], MS Office Suite, Google Workspace, Ticket Handling, Remote Support', true, 9),
('Academic Foundation (HNDIT Coursework)', 'fa-graduation-cap', 'accent', 'Data Structures & Algorithms [main], Database Management Systems [main], System Analysis & Design [core], Software Engineering Practices [core], Software Quality Assurance [core], Operating Systems [core], IT Project Management [core], Statistics for IT, Machine Learning Fundamentals, Enterprise Architecture', true, 10),
('AI Productivity & Learning Tools', 'fa-robot', 'primary', 'ChatGPT [main], Claude AI (Anthropic) [main], Prompt Engineering [core], Knowledge Search & Summarization [core], Google Gemini, Workflow Automation, AI-Assisted Troubleshooting', true, 11);


-- 7. CERTIFICATIONS & ACHIEVEMENTS
TRUNCATE TABLE public.portfolio_certifications;

INSERT INTO public.portfolio_certifications (title, issuer, issue_date, credential_url, badge_icon, is_published, sort_order) VALUES
('IT Essentials', 'Cisco Networking Academy', '2024', 'https://www.netacad.com/', 'fa-certificate', true, 1),
('Web Designing for Beginners', 'University of Moratuwa', '2024', 'https://www.mrt.ac.lk/', 'fa-code', true, 2);

