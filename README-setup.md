# shamikakkss.me — Unfold build

Your portfolio rebuilt on the Colorlib **Unfold** template: dark theme, `#D63447` accent,
right-aligned menu. All content still comes from the same Supabase project — no data
was moved or renamed.

## Structure

```
index.html            the page
config.js             Supabase URL + anon key (the only place they live)
css/style.css         Unfold dark theme, untouched
css/custom.css        my additions: skill cards, timeline, certs, modal, gallery, toasts
js/scripts-dist.js    Unfold's bundled libraries, untouched
js/main.js            Unfold's script — two lines commented out, see below
js/portfolio.js       all Supabase loading and rendering
supabase-schema.sql   creates/repairs tables, columns, RLS, storage bucket (safe to re-run)
seed-reviews.sql      initial rows for the Reviews section (safe to re-run)
supabase-check.html   diagnostic page — delete once everything is green
```

## Two edits inside `js/main.js`

Both are commented, not deleted:

- `siteIstotope()` — Unfold initialised the portfolio grid at page load, before the
  Supabase rows existed, so the grid measured as empty. `portfolio.js` now calls its own
  isotope init right after the cards are injected.
- `contactForm()` — Unfold posted to `php/send-email.php`. GitHub Pages cannot run PHP,
  so the form goes to Web3Forms instead (same access key as your old site).

## Files you still need to drop in

- `Sachintha Shyamika.pdf` — the CV download button points at it
- `aboutme Image.png` — used by the About section and as the Open Graph preview.
  Right now `images/about_me_pic2.jpg` is a placeholder; swap the `<img>` in the
  About block once your photo is in.

## Where each section gets its content

| Section | Source |
|---|---|
| Hero badge, subtitle, rotating roles | `portfolio_profile_settings` (row `main_profile`) |
| Portfolio grid — **Development** filter | `portfolio_projects` |
| Portfolio grid — **UI/UX** filter | `portfolio_uiux` |
| Portfolio grid — **Graphics** filter | `portfolio_graphics` |
| What I Do cards | `portfolio_skills` |
| The four counters | `portfolio_profile_settings`, else computed from the data |
| Journey → Work | `portfolio_experience` |
| Journey → Academic | `portfolio_education` |
| Certifications | `portfolio_certifications` |
| Design Gallery carousel | `gallery` storage bucket (+ optional `captions.json`) |
| Contact form | Web3Forms |

Projects, UI/UX and graphics now share **one** filterable grid instead of three separate
sections — that is how Unfold's portfolio is built. A filter button hides itself when its
category has no published rows, and the whole portfolio section hides if all three are empty.

## Clicking a card

Opens a dark modal in the Unfold style showing banner, tagline, description, key features,
process steps, tech/tools and a screenshot grid (screens open in Fancybox). It uses whatever
columns the row has and silently skips the rest, so a sparse row still looks fine.

## Field formats worth repeating

- `tags` on `portfolio_skills` is **one comma-separated string**:
  `React [main], Node.js [core], Rust [learning]` — the markers set the dot colour.
- `tech`, `tools`, `achievements`, `stepper`, `images`, `hero_roles` are Postgres text arrays.
- `features` is JSON: `[{"icon":"fa-lock","title":"RBAC","desc":"…"}]`
- `icon` / `badge_icon` take Font Awesome 6 solid names, e.g. `fa-diagram-project`.
- `modal_desc` is injected as HTML — only put your own markup there.
- `period` on `portfolio_experience` must contain a 4-digit year; the Years Experience
  counter is derived from the earliest one found.

## First run

1. SQL Editor → paste `supabase-schema.sql` → Run. Nothing is dropped; it only fills gaps.
2. Open `supabase-check.html` and confirm every row is green.
3. Push to GitHub Pages. `CNAME` already points at `shamikakkss.me`.

## Licence note

Unfold is free under CC BY 3.0 **on the condition that the Colorlib credit in the footer
stays**. I left it in place. Removing it requires buying a licence from Colorlib.

## The anon key

It is meant to be public and is safe in the repo. RLS is what protects the data:
anonymous visitors can read published rows and nothing else. Never put the
**service_role** key in this folder.
