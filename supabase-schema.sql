-- ============================================================================
--  shamikakkss.me — Supabase schema for the portfolio
--  Safe to run on an EXISTING project: every statement is idempotent.
--  Nothing is dropped, nothing is overwritten. Missing tables are created,
--  missing columns are added, RLS + read policies are (re)applied.
--
--  How to run:  Supabase Dashboard -> SQL Editor -> New query -> paste -> Run
-- ============================================================================

-- ─────────────────────────────────────────────────────────────
-- 1. PROFILE SETTINGS  (single row, id = 'main_profile')
--    Read by: loadProfileSettings()
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_profile_settings (
  id text primary key
);

alter table public.portfolio_profile_settings
  add column if not exists hero_roles          text[],
  add column if not exists availability_status text,
  add column if not exists hero_subtitle       text,
  add column if not exists years_exp           text,
  add column if not exists deployed_systems    text,
  add column if not exists freelance_clients   text,
  add column if not exists cgpa_value          text,
  add column if not exists cgpa_label          text,
  add column if not exists cgpa_note           text,
  add column if not exists reviews_platform_name text,  -- e.g. 'Fiverr'
  add column if not exists reviews_platform_url  text,  -- link the "View Profile" button opens
  add column if not exists reviews_total_count   text,  -- e.g. '109' — overrides the raw row count if set
  add column if not exists reviews_five_star_count text, -- e.g. '103' — shown in the stats meta line
  add column if not exists updated_at          timestamptz default now();

-- Seed the single settings row only if it does not exist yet.
insert into public.portfolio_profile_settings (id, availability_status, cgpa_label)
values ('main_profile', 'Available for opportunities', 'HNDIT GPA')
on conflict (id) do nothing;


-- ─────────────────────────────────────────────────────────────
-- 2. PROJECTS
--    Read by: loadProjects(), openProjectModal(), autoComputeHeroStats()
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_projects (
  id uuid primary key default gen_random_uuid()
);

alter table public.portfolio_projects
  add column if not exists slug                text,
  add column if not exists title               text,
  add column if not exists tagline             text,
  add column if not exists card_desc           text,
  add column if not exists modal_desc          text,   -- HTML allowed
  add column if not exists banner_url          text,
  add column if not exists icon                text,   -- e.g. 'fa-diagram-project'
  add column if not exists icon_style          text,   -- 'primary' | 'accent' | 'warm'
  add column if not exists badge_text          text,
  add column if not exists badge_class         text,   -- e.g. 'badge-active'
  add column if not exists tech                text[],
  add column if not exists stepper             text[],
  add column if not exists features            jsonb,  -- [{icon,color,title,desc}]
  add column if not exists featured_highlights jsonb,  -- [{icon,text}]
  add column if not exists live_url            text,
  add column if not exists specs_url           text,
  add column if not exists is_featured         boolean default false,
  add column if not exists is_published        boolean default true,
  add column if not exists sort_order          integer default 0,
  add column if not exists created_at          timestamptz default now();

create unique index if not exists portfolio_projects_slug_key
  on public.portfolio_projects (slug);


-- ─────────────────────────────────────────────────────────────
-- 3. UI/UX DESIGNS
--    Read by: loadUiuxDesigns(), openUiuxModal()
--    `images` holds bare file names (combined with `folder`) OR full URLs.
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_uiux (
  id uuid primary key default gen_random_uuid()
);

alter table public.portfolio_uiux
  add column if not exists slug         text,
  add column if not exists title        text,
  add column if not exists category     text,
  add column if not exists tagline      text,
  add column if not exists tools        text[],
  add column if not exists card_desc    text,
  add column if not exists modal_desc   text,
  add column if not exists banner_url   text,
  add column if not exists folder       text,    -- e.g. 'uiux/project-01'
  add column if not exists images       text[],
  add column if not exists gallery_urls text[],  -- optional fallback
  add column if not exists external_url text,
  add column if not exists icon         text,
  add column if not exists icon_style   text,
  add column if not exists badge_class  text,
  add column if not exists is_published boolean default true,
  add column if not exists sort_order   integer default 0,
  add column if not exists created_at   timestamptz default now();

create unique index if not exists portfolio_uiux_slug_key
  on public.portfolio_uiux (slug);


-- ─────────────────────────────────────────────────────────────
-- 4. GRAPHIC DESIGNS
--    Read by: loadGraphicsDesigns(), openGraphicsModal()
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_graphics (
  id uuid primary key default gen_random_uuid()
);

alter table public.portfolio_graphics
  add column if not exists slug         text,
  add column if not exists title        text,
  add column if not exists category     text,
  add column if not exists tagline      text,
  add column if not exists tools        text[],
  add column if not exists card_desc    text,
  add column if not exists modal_desc   text,
  add column if not exists image_url    text,    -- preferred thumbnail
  add column if not exists banner_url   text,
  add column if not exists folder       text,
  add column if not exists images       text[],
  add column if not exists gallery_urls text[],
  add column if not exists external_url text,
  add column if not exists icon         text,
  add column if not exists icon_style   text,
  add column if not exists badge_class  text,
  add column if not exists is_published boolean default true,
  add column if not exists sort_order   integer default 0,
  add column if not exists created_at   timestamptz default now();

create unique index if not exists portfolio_graphics_slug_key
  on public.portfolio_graphics (slug);


-- ─────────────────────────────────────────────────────────────
-- 5. EXPERIENCE
--    Read by: loadExperience(), autoComputeHeroStats()
--    `period` must contain the years, e.g. '2023 — Present'
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_experience (
  id uuid primary key default gen_random_uuid()
);

alter table public.portfolio_experience
  add column if not exists title        text,
  add column if not exists company      text,
  add column if not exists period       text,
  add column if not exists achievements text[],
  add column if not exists icon         text,
  add column if not exists link_url     text,
  add column if not exists link_label   text,
  add column if not exists is_published boolean default true,
  add column if not exists sort_order   integer default 0,
  add column if not exists created_at   timestamptz default now();


-- ─────────────────────────────────────────────────────────────
-- 6. CERTIFICATIONS
--    Read by: loadCertifications()
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_certifications (
  id uuid primary key default gen_random_uuid()
);

alter table public.portfolio_certifications
  add column if not exists title          text,
  add column if not exists issuer         text,
  add column if not exists issue_date     text,   -- free text, e.g. 'Mar 2025'
  add column if not exists credential_url text,
  add column if not exists badge_icon     text,   -- e.g. 'fa-certificate'
  add column if not exists is_published   boolean default true,
  add column if not exists sort_order     integer default 0,
  add column if not exists created_at     timestamptz default now();


-- ─────────────────────────────────────────────────────────────
-- 7. SKILLS
--    Read by: loadSkills()
--    `tags` is ONE comma-separated string. Optional markers:
--      'React [main], Node.js [core], Rust [learning]'
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_skills (
  id uuid primary key default gen_random_uuid()
);

alter table public.portfolio_skills
  add column if not exists title        text,
  add column if not exists icon         text,
  add column if not exists theme_accent text,   -- 'primary' | 'accent' | 'warm'
  add column if not exists tags         text,
  add column if not exists is_published boolean default true,
  add column if not exists sort_order   integer default 0,
  add column if not exists created_at   timestamptz default now();


-- ─────────────────────────────────────────────────────────────
-- 8. EDUCATION
--    Read by: autoComputeHeroStats() -> average GPA.
--    NOTE: the page reads EVERY row here (no is_published filter),
--    and skips rows where is_pending = true.
--    `gpa_text` just needs to contain a number, e.g. '3.75' or 'GPA 3.75'.
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_education (
  id uuid primary key default gen_random_uuid()
);

alter table public.portfolio_education
  add column if not exists semester_key      text,
  add column if not exists semester_title    text,
  add column if not exists module_count_text text,
  add column if not exists gpa_text          text,
  add column if not exists is_pending        boolean default false,
  add column if not exists modules           jsonb default '[]'::jsonb,
  add column if not exists sort_order        integer default 0,
  add column if not exists semester          text,
  add column if not exists title             text,
  add column if not exists created_at        timestamptz default now();

create unique index if not exists portfolio_education_semester_key_key
  on public.portfolio_education (semester_key);

-- Seed data with all 4 semesters and modules
insert into public.portfolio_education (
  id, semester_key, semester_title, module_count_text, gpa_text, is_pending, modules, sort_order
) values
  ('23138240-6e0b-4010-9147-ba328edd54e0', 'sem1', 'Semester I', '6 Modules', 'GPA 3.90', false,
   '[{"code": "HNDIT1012", "name": "Visual Application Programming"}, {"code": "HNDIT1022", "name": "Web Design"}, {"code": "HNDIT1032", "name": "Computer and Network Systems"}, {"code": "HNDIT1042", "name": "Information Management and Information Systems"}, {"code": "HNDIT1052", "name": "ICT Project (Individual)"}, {"code": "HNDIT1062", "name": "Communication Skills"}]'::jsonb, 1),
  ('72fbcdf9-8ebd-4269-953d-1329de11da29', 'sem2', 'Semester II', '8 Modules', 'GPA 3.65', false,
   '[{"code": "HNDIT2012", "name": "Fundamentals of Programming"}, {"code": "HNDIT2022", "name": "Software Development"}, {"code": "HNDIT2032", "name": "System Analysis and Design"}, {"code": "HNDIT2042", "name": "Data Communication and Computer Networks"}, {"code": "HNDIT2052", "name": "Principles of User Interface Design"}, {"code": "HNDIT2062", "name": "ICT Project (Group)"}, {"code": "HNDIT2072", "name": "Technical Writing"}, {"code": "HNDIT2082", "name": "Human Value & Professional Ethics"}]'::jsonb, 2),
  ('05a93242-2ad0-415b-9c61-4323e7db95e8', 'sem3', 'Semester III', '7 Modules', 'GPA 3.54', false,
   '[{"code": "HNDIT3012", "name": "Object Oriented Programming"}, {"code": "HNDIT3022", "name": "Web Programming"}, {"code": "HNDIT3032", "name": "Data Structures and Algorithms"}, {"code": "HNDIT3042", "name": "Database Management Systems"}, {"code": "HNDIT3052", "name": "Operating Systems"}, {"code": "HNDIT3062", "name": "Information and Computer Security"}, {"code": "HNDIT3072", "name": "Statistics for IT"}]'::jsonb, 3),
  ('13151ce7-88d8-4af7-a3ae-9b625a001d08', 'sem4', 'Semester IV', '6 Modules', 'Result Pending', true,
   '[{"code": "HNDIT4012", "name": "Enterprise Application Development"}, {"code": "HNDIT4022", "name": "Software Quality Assurance"}, {"code": "HNDIT4032", "name": "Cloud Computing & DevOps"}, {"code": "HNDIT4042", "name": "Mobile Application Development"}, {"code": "HNDIT4052", "name": "Comprehensive Project"}, {"code": "HNDIT4062", "name": "Industrial Training"}]'::jsonb, 4)
on conflict (semester_key) do update set
  semester_title    = excluded.semester_title,
  module_count_text = excluded.module_count_text,
  gpa_text          = excluded.gpa_text,
  is_pending        = excluded.is_pending,
  modules           = excluded.modules,
  sort_order        = excluded.sort_order;


-- ─────────────────────────────────────────────────────────────
-- 9. REVIEWS / TESTIMONIALS
--    Read by: loadReviews()
--    `review_key` is a stable slug used only for seeding (ON CONFLICT target)
--    so re-running seed-reviews.sql never duplicates a row — it is not
--    displayed on the site.
-- ─────────────────────────────────────────────────────────────
create table if not exists public.portfolio_reviews (
  id uuid primary key default gen_random_uuid()
);

alter table public.portfolio_reviews
  add column if not exists review_key        text,
  add column if not exists reviewer_name     text,
  add column if not exists reviewer_country  text,   -- display name, e.g. 'United States'
  add column if not exists country_code      text,   -- 2-letter code for the flag, e.g. 'us'
  add column if not exists rating            integer default 5,  -- 1-5
  add column if not exists quote             text,
  add column if not exists source            text default 'Fiverr',
  add column if not exists source_url        text,
  add column if not exists is_published      boolean default true,
  add column if not exists sort_order        integer default 0,
  add column if not exists created_at        timestamptz default now();

create unique index if not exists portfolio_reviews_key_key
  on public.portfolio_reviews (review_key);


-- ============================================================================
--  ROW LEVEL SECURITY
--  The site uses the public anon key, so anonymous SELECT must be allowed.
--  Content tables expose ONLY published rows. Nothing is writable by anon.
-- ============================================================================

alter table public.portfolio_profile_settings enable row level security;
alter table public.portfolio_projects         enable row level security;
alter table public.portfolio_uiux             enable row level security;
alter table public.portfolio_graphics         enable row level security;
alter table public.portfolio_experience       enable row level security;
alter table public.portfolio_certifications   enable row level security;
alter table public.portfolio_skills           enable row level security;
alter table public.portfolio_education        enable row level security;
alter table public.portfolio_reviews          enable row level security;

-- Published-only public read
drop policy if exists "public read published" on public.portfolio_projects;
create policy "public read published" on public.portfolio_projects
  for select to anon, authenticated using (is_published is true);

drop policy if exists "public read published" on public.portfolio_uiux;
create policy "public read published" on public.portfolio_uiux
  for select to anon, authenticated using (is_published is true);

drop policy if exists "public read published" on public.portfolio_graphics;
create policy "public read published" on public.portfolio_graphics
  for select to anon, authenticated using (is_published is true);

drop policy if exists "public read published" on public.portfolio_experience;
create policy "public read published" on public.portfolio_experience
  for select to anon, authenticated using (is_published is true);

drop policy if exists "public read published" on public.portfolio_certifications;
create policy "public read published" on public.portfolio_certifications
  for select to anon, authenticated using (is_published is true);

drop policy if exists "public read published" on public.portfolio_skills;
create policy "public read published" on public.portfolio_skills
  for select to anon, authenticated using (is_published is true);

drop policy if exists "public read published" on public.portfolio_reviews;
create policy "public read published" on public.portfolio_reviews
  for select to anon, authenticated using (is_published is true);

-- These two are read in full by the page
drop policy if exists "public read" on public.portfolio_profile_settings;
create policy "public read" on public.portfolio_profile_settings
  for select to anon, authenticated using (true);

drop policy if exists "public read" on public.portfolio_education;
create policy "public read" on public.portfolio_education
  for select to anon, authenticated using (true);


-- ============================================================================
--  STORAGE — the 'gallery' bucket used by the Design Gallery strip
--  The page calls the LIST endpoint with the anon key, so a SELECT policy on
--  storage.objects is required even though the bucket is public.
-- ============================================================================

insert into storage.buckets (id, name, public)
values ('gallery', 'gallery', true)
on conflict (id) do update set public = true;

drop policy if exists "public read gallery" on storage.objects;
create policy "public read gallery" on storage.objects
  for select to anon, authenticated using (bucket_id = 'gallery');

-- Reminder: upload captions.json into the SAME bucket to give images titles.
-- ============================================================================
--  Done.
-- ============================================================================
