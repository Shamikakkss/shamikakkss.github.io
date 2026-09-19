-- ============================================================================
--  seed-reviews.sql — initial rows for public.portfolio_reviews
--  Run AFTER supabase-schema.sql (SQL Editor -> New query -> paste -> Run).
--  Safe to re-run: ON CONFLICT (review_key) updates the row instead of
--  duplicating it. Add more clients any time by copying a block below with
--  a new, unique review_key.
-- ============================================================================

insert into public.portfolio_reviews
  (review_key, reviewer_name, reviewer_country, country_code, rating, quote, source, source_url, is_published, sort_order)
values
  ('themattmayo', 'themattmayo', 'United States', 'us', 5,
   'Awesome experience. Super responsive, had the final design in less time than promised. Exceeded all expectations.',
   'Fiverr', 'https://www.fiverr.com/s_sdesigns', true, 1),

  ('sami_serson', 'sami_serson', 'Netherlands', 'nl', 5,
   'Amazing, wasn''t expecting those results. Will hire him again for further projects.',
   'Fiverr', 'https://www.fiverr.com/s_sdesigns', true, 2),

  ('luciebhlmann', 'luciebhlmann', 'Mexico', 'mx', 5,
   'I am very satisfied with the quality and creativity of the work. The process was smooth and really fast!',
   'Fiverr', 'https://www.fiverr.com/s_sdesigns', true, 3),

  ('jevanteq', 'jevanteq', 'United States', 'us', 5,
   'Great work and fast turnaround. Love it.',
   'Fiverr', 'https://www.fiverr.com/s_sdesigns', true, 4),

  ('superlanka', 'superlanka', 'Sri Lanka', 'lk', 5,
   'Very fast quality service. He finds what we need with changes in a very short time. Highly recommend.',
   'Fiverr', 'https://www.fiverr.com/s_sdesigns', true, 5),

  ('weronikaswitala', 'weronikaswitala', 'United Kingdom', 'gb', 5,
   'Amazing seller, so communicative and helpful! Couldn''t be any better. So so happy!',
   'Fiverr', 'https://www.fiverr.com/s_sdesigns', true, 6),

  ('chargls07', 'chargls07', 'United States', 'us', 5,
   'Great design work, extremely fast and very good communication. Delivers exactly what was needed!',
   'Fiverr', 'https://www.fiverr.com/s_sdesigns', true, 7),

  ('maurizio812003', 'maurizio812003', 'Italy', 'it', 5,
   'I''m now a repeat client and I''m very happy with the results every time.',
   'Fiverr', 'https://www.fiverr.com/s_sdesigns', true, 8)

on conflict (review_key) do update set
  reviewer_name    = excluded.reviewer_name,
  reviewer_country = excluded.reviewer_country,
  country_code     = excluded.country_code,
  rating           = excluded.rating,
  quote            = excluded.quote,
  source           = excluded.source,
  source_url       = excluded.source_url,
  is_published     = excluded.is_published,
  sort_order       = excluded.sort_order;


-- Optional: the stats line above the cards ("109 reviews · 103 five-star
-- ratings") is manual, since it can reflect a bigger platform history than
-- the individual quotes stored above. Set it here, or leave it out to let
-- the page fall back to counting the rows in this table.
update public.portfolio_profile_settings
set
  reviews_platform_name    = 'Fiverr',
  reviews_platform_url     = 'https://www.fiverr.com/s_sdesigns',
  reviews_total_count      = '109',
  reviews_five_star_count  = '103'
where id = 'main_profile';
