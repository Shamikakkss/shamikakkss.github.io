# Portfolio Redesign — Complete Data, Database & Coding Implementation Plan

## 1. Project Objective

Create a completely new portfolio design/template while preserving the existing portfolio's actual information and database.

### Main rule

> **Change the design, not the data.**

The new website must use:

- New template
- New layout
- New typography
- New colors
- New animations
- New component design
- New responsive behavior

But it must preserve the existing:

- Profile information
- Hero information
- Projects
- Project images
- Project descriptions
- Tools
- Links
- Experience
- Education
- Semester results
- Modules
- Skills
- Certifications
- Existing Supabase database

The database remains the **source of truth**.

---

# 2. Data vs Design: Most Important Rule

The project must clearly separate **content/data** from **presentation/design**.

## Database controls

These values should normally come from Supabase:

```text
Name
Professional roles
Availability
Hero description
Statistics
Projects
Project titles
Project descriptions
Project categories
Project tools
Project images
Project links
Experience
Experience dates
Experience descriptions
Experience achievements
Education
Semester GPA
Semester modules
Skills
Skill categories
Skill levels/tags
Certifications
Certificate issuer
Certificate dates
Certificate links
```

## Frontend code controls

These values can be hard-coded because they are UI/design structure:

```text
Section structure
Section IDs
CSS classes
Fonts
Colors
Spacing
Grid sizes
Card styles
Border radius
Animations
Breakpoints
Navigation structure
Icon choices
Loading skeletons
Button styling
Modal structure
```

### Example

This is acceptable:

```html
<section id="projects">
    <div class="section-heading">
        <span class="eyebrow">Selected Work</span>
        <h2>Projects</h2>
    </div>

    <div id="project-grid"></div>
</section>
```

`Selected Work` and `Projects` are UI labels, so they can be hard-coded.

This is NOT recommended:

```html
<div class="project-card">
    <h3>Food Delivery App</h3>
    <p>Complete UI/UX case study...</p>
</div>
```

because the actual project content belongs to Supabase.

---

# 3. Existing Backend Strategy

Do not create a new portfolio database just because the design is changing.

Keep the existing Supabase project and tables.

Expected tables:

```text
portfolio_profile_settings
portfolio_uiux
portfolio_graphics
portfolio_experience
portfolio_education
portfolio_skills
portfolio_certifications
```

The new frontend should connect to the same Supabase project.

---

# 4. Existing Data Model

## 4.1 Profile

Table:

```text
portfolio_profile_settings
```

Expected fields:

```text
id
availability_status
availability_badge
hero_title_name
hero_title_role
hero_roles
hero_subtitle
years_exp
deployed_systems
freelance_clients
cgpa_value
cgpa_label
cgpa_note
```

### Used by

- Hero
- Availability badge
- Main title
- Rotating roles
- Subtitle
- Statistics
- Education highlight

---

# 5. UI/UX Projects

Table:

```text
portfolio_uiux
```

Fields:

```text
id
slug
title
category
card_desc
modal_desc
tagline
tools
images
banner_url
external_url
badge_text
is_published
sort_order
created_at
```

### Important

Do not create an array of projects manually in JavaScript.

Wrong:

```javascript
const projects = [
    {
        title: "Food Delivery App",
        category: "Mobile App"
    }
];
```

Correct:

```javascript
async function getUIUXProjects() {
    const { data, error } = await supabase
        .from("portfolio_uiux")
        .select("*")
        .eq("is_published", true)
        .order("sort_order", { ascending: true });

    if (error) {
        console.error("UIUX project loading error:", error);
        return [];
    }

    return data || [];
}
```

---

# 6. Graphic Design Projects

Table:

```text
portfolio_graphics
```

Fields:

```text
id
slug
title
category
card_desc
tools
image_url
gallery_urls
client_name
badge_text
external_url
is_published
sort_order
created_at
```

Query:

```javascript
async function getGraphicProjects() {
    const { data, error } = await supabase
        .from("portfolio_graphics")
        .select("*")
        .eq("is_published", true)
        .order("sort_order", { ascending: true });

    if (error) {
        console.error("Graphic project loading error:", error);
        return [];
    }

    return data || [];
}
```

---

# 7. Experience

Table:

```text
portfolio_experience
```

Fields:

```text
id
period
title
company
achievements
link_url
link_label
icon
icon_style
is_published
sort_order
created_at
```

Query:

```javascript
async function getExperience() {
    const { data, error } = await supabase
        .from("portfolio_experience")
        .select("*")
        .eq("is_published", true)
        .order("sort_order", { ascending: true });

    if (error) {
        console.error("Experience loading error:", error);
        return [];
    }

    return data || [];
}
```

The new UI should render these records as a timeline.

---

# 8. Education

Table:

```text
portfolio_education
```

Fields:

```text
id
semester_key
semester_title
module_count_text
gpa_text
is_pending
modules
sort_order
created_at
```

Query:

```javascript
async function getEducation() {
    const { data, error } = await supabase
        .from("portfolio_education")
        .select("*")
        .order("sort_order", { ascending: true });

    if (error) {
        console.error("Education loading error:", error);
        return [];
    }

    return data || [];
}
```

Education cards should be generated from the returned data.

---

# 9. Skills

Table:

```text
portfolio_skills
```

The skills section should be entirely data-driven.

Do not write:

```javascript
const skills = [
    "JavaScript",
    "React",
    "PHP",
    "MySQL"
];
```

Instead:

```javascript
async function getSkills() {
    const { data, error } = await supabase
        .from("portfolio_skills")
        .select("*")
        .order("sort_order", { ascending: true });

    if (error) {
        console.error("Skills loading error:", error);
        return [];
    }

    return data || [];
}
```

The renderer converts the database records into category cards and skill badges.

---

# 10. Certifications

Table:

```text
portfolio_certifications
```

Fields:

```text
id
title
issuer
issue_date
credential_url
badge_icon
is_published
sort_order
created_at
```

Query:

```javascript
async function getCertifications() {
    const { data, error } = await supabase
        .from("portfolio_certifications")
        .select("*")
        .eq("is_published", true)
        .order("sort_order", { ascending: true });

    if (error) {
        console.error("Certification loading error:", error);
        return [];
    }

    return data || [];
}
```

---

# 11. Supabase Connection

Keep the existing Supabase connection approach.

Example:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
<script src="config.js"></script>
<script src="js/app.js"></script>
```

`config.js`:

```javascript
window.SUPABASE_URL = "YOUR_SUPABASE_URL";
window.SUPABASE_ANON_KEY = "YOUR_PUBLIC_ANON_KEY";
```

Client:

```javascript
const supabase = window.supabase.createClient(
    window.SUPABASE_URL,
    window.SUPABASE_ANON_KEY
);
```

## Security rule

Only the public Supabase anon/publishable key can be used in browser code.

Never put:

```text
service_role key
database password
private API secret
```

inside frontend files.

---

# 12. Recommended File Structure

Use a clean separation:

```text
portfolio/
│
├── index.html
├── config.js
│
├── css/
│   ├── reset.css
│   ├── variables.css
│   ├── base.css
│   ├── layout.css
│   ├── components.css
│   ├── sections.css
│   ├── animations.css
│   └── responsive.css
│
├── js/
│   ├── app.js
│   ├── supabase.js
│   ├── data/
│   │   ├── profile.js
│   │   ├── projects.js
│   │   ├── experience.js
│   │   ├── education.js
│   │   ├── skills.js
│   │   └── certifications.js
│   │
│   ├── render/
│   │   ├── renderProfile.js
│   │   ├── renderProjects.js
│   │   ├── renderExperience.js
│   │   ├── renderEducation.js
│   │   ├── renderSkills.js
│   │   └── renderCertifications.js
│   │
│   ├── navigation.js
│   ├── modal.js
│   ├── animations.js
│   └── utils.js
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── Preview/
│
└── README.md
```

A simpler project can combine some files, but the logical separation should remain.

---

# 13. Supabase Data Layer

Create one data layer rather than putting Supabase queries everywhere.

## supabase.js

```javascript
const supabaseClient = window.supabase.createClient(
    window.SUPABASE_URL,
    window.SUPABASE_ANON_KEY
);

export default supabaseClient;
```

If ES modules are not being used, expose it globally instead:

```javascript
window.supabaseClient = window.supabase.createClient(
    window.SUPABASE_URL,
    window.SUPABASE_ANON_KEY
);
```

---

# 14. Profile Data

Example:

```javascript
async function getProfile() {
    const { data, error } = await supabaseClient
        .from("portfolio_profile_settings")
        .select("*")
        .eq("id", "main_profile")
        .single();

    if (error) {
        console.error("Profile error:", error);
        throw error;
    }

    return data;
}
```

Render:

```javascript
async function loadProfile() {
    try {
        const profile = await getProfile();

        document.querySelector("#hero-name").textContent =
            profile.hero_title_name || "";

        document.querySelector("#hero-role").textContent =
            profile.hero_title_role || "";

        document.querySelector("#hero-subtitle").textContent =
            profile.hero_subtitle || "";

        document.querySelector("#years-exp").textContent =
            profile.years_exp || "0";

        document.querySelector("#deployed-systems").textContent =
            profile.deployed_systems || "0";

        document.querySelector("#freelance-clients").textContent =
            profile.freelance_clients || "0";

    } catch (error) {
        console.error(error);
    }
}
```

---

# 15. Rotating Hero Roles

`hero_roles` comes from the database.

Do not write the role list manually in the new HTML.

Example:

```javascript
function startRoleRotation(roles) {
    if (!Array.isArray(roles) || roles.length === 0) {
        return;
    }

    const element = document.querySelector("#hero-role");

    let index = 0;

    element.textContent = roles[index];

    setInterval(() => {
        index = (index + 1) % roles.length;
        element.textContent = roles[index];
    }, 2500);
}
```

Use:

```javascript
const profile = await getProfile();

startRoleRotation(profile.hero_roles);
```

---

# 16. Rendering UI/UX Project Cards

HTML:

```html
<div id="uiux-project-grid" class="project-grid">
    <div class="loading-skeleton"></div>
    <div class="loading-skeleton"></div>
    <div class="loading-skeleton"></div>
</div>
```

JavaScript:

```javascript
function renderUIUXProjects(projects) {
    const container = document.querySelector("#uiux-project-grid");

    if (!projects.length) {
        container.innerHTML = "";
        return;
    }

    container.innerHTML = projects.map(project => `
        <article class="project-card"
                 data-project-id="${project.id}">

            <div class="project-image">
                <img
                    src="${escapeAttribute(project.banner_url || "")}"
                    alt="${escapeAttribute(project.title || "Project")}"
                    loading="lazy"
                >
            </div>

            <div class="project-content">

                <span class="project-category">
                    ${escapeHTML(project.category || "")}
                </span>

                <h3>
                    ${escapeHTML(project.title || "")}
                </h3>

                <p>
                    ${escapeHTML(project.card_desc || "")}
                </p>

                <div class="project-tools">
                    ${renderTools(project.tools)}
                </div>

                <button
                    class="project-view-button"
                    data-project-id="${project.id}">
                    View Project
                </button>

            </div>

        </article>
    `).join("");
}
```

---

# 17. Important: Escape Database Content

Even if the database belongs to the portfolio owner, database content should not be inserted into HTML blindly.

Avoid:

```javascript
container.innerHTML = `<h3>${project.title}</h3>`;
```

Use escaping helpers.

Example:

```javascript
function escapeHTML(value = "") {
    return String(value)
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}
```

For URL attributes, validate/escape the URL as well.

---

# 18. Project Tools Renderer

Database tools may be stored as an array or JSON.

Create one helper:

```javascript
function renderTools(tools) {
    if (!tools) return "";

    const list = Array.isArray(tools)
        ? tools
        : String(tools)
            .split(",")
            .map(item => item.trim())
            .filter(Boolean);

    return list.map(tool => `
        <span class="tool-badge">
            ${escapeHTML(tool)}
        </span>
    `).join("");
}
```

This means the UI does not need to know whether a project has:

```text
Figma
```

or:

```text
Illustrator, Photoshop
```

The database controls it.

---

# 19. Combining UI/UX and Graphic Projects

The new portfolio can have one "Work" section.

Load both:

```javascript
const [uiuxProjects, graphicProjects] = await Promise.all([
    getUIUXProjects(),
    getGraphicProjects()
]);
```

Normalize them:

```javascript
const projects = [
    ...uiuxProjects.map(project => ({
        ...project,
        type: "uiux"
    })),

    ...graphicProjects.map(project => ({
        ...project,
        type: "graphics"
    }))
];
```

Now the UI can filter:

```text
All
UI/UX
Graphic Design
```

without duplicating the database.

---

# 20. Project Filter

HTML:

```html
<div class="project-filters">
    <button data-filter="all">All</button>
    <button data-filter="uiux">UI/UX</button>
    <button data-filter="graphics">Graphic Design</button>
</div>
```

JavaScript:

```javascript
function filterProjects(projects, filter) {
    if (filter === "all") {
        return projects;
    }

    return projects.filter(project =>
        project.type === filter
    );
}
```

---

# 21. Project Details

Do not hard-code a separate page for every project.

Use the project record.

When the user clicks:

```text
View Project
```

use the project ID:

```javascript
async function getUIUXProjectById(id) {
    const { data, error } = await supabaseClient
        .from("portfolio_uiux")
        .select("*")
        .eq("id", id)
        .single();

    if (error) {
        console.error(error);
        return null;
    }

    return data;
}
```

Then populate the modal/detail page.

---

# 22. UI/UX Gallery

If `images` is an array:

```javascript
function renderGallery(images = []) {
    return images.map((image, index) => `
        <img
            src="${escapeAttribute(image)}"
            alt="Project screen ${index + 1}"
            loading="lazy"
        >
    `).join("");
}
```

Do not manually create:

```text
screen1
screen2
screen3
screen4
```

The database array controls the number of images.

---

# 23. Graphic Gallery

Use:

```text
gallery_urls
```

in the same way.

```javascript
function renderGraphicGallery(images = []) {
    return images.map((image, index) => `
        <figure class="gallery-item">
            <img
                src="${escapeAttribute(image)}"
                alt="Graphic design project image ${index + 1}"
                loading="lazy"
            >
        </figure>
    `).join("");
}
```

---

# 24. Experience Rendering

```javascript
function renderExperience(items) {
    const container = document.querySelector("#experience-list");

    container.innerHTML = items.map(item => `
        <article class="experience-item">

            <div class="experience-period">
                ${escapeHTML(item.period || "")}
            </div>

            <div class="experience-content">

                <h3>
                    ${escapeHTML(item.title || "")}
                </h3>

                <p class="experience-company">
                    ${escapeHTML(item.company || "")}
                </p>

                <ul>
                    ${renderAchievements(item.achievements)}
                </ul>

                ${
                    item.link_url
                    ? `
                        <a
                            href="${escapeAttribute(item.link_url)}"
                            target="_blank"
                            rel="noopener noreferrer">
                            ${escapeHTML(item.link_label || "View")}
                        </a>
                    `
                    : ""
                }

            </div>

        </article>
    `).join("");
}
```

---

# 25. Achievement Renderer

If achievements are stored as an array:

```javascript
function renderAchievements(achievements = []) {
    return achievements.map(achievement => `
        <li>
            ${escapeHTML(achievement)}
        </li>
    `).join("");
}
```

---

# 26. Education Rendering

```javascript
function renderEducation(semesters) {
    const container = document.querySelector("#education-list");

    container.innerHTML = semesters.map(semester => `
        <article class="semester-card">

            <div class="semester-header">
                <span>
                    ${escapeHTML(semester.semester_title || "")}
                </span>

                ${
                    semester.is_pending
                    ? `<span class="pending-badge">Result Pending</span>`
                    : `<strong>${escapeHTML(semester.gpa_text || "")}</strong>`
                }
            </div>

            <p>
                ${escapeHTML(semester.module_count_text || "")}
            </p>

            <div class="semester-modules">
                ${renderModules(semester.modules)}
            </div>

        </article>
    `).join("");
}
```

---

# 27. Module Renderer

```javascript
function renderModules(modules = []) {
    return modules.map(module => `
        <div class="module-row">
            <span class="module-code">
                ${escapeHTML(module.code || "")}
            </span>

            <span class="module-name">
                ${escapeHTML(module.name || "")}
            </span>
        </div>
    `).join("");
}
```

---

# 28. Skills Rendering

Skills should be grouped by category.

Concept:

```text
Frontend & Frameworks
    JavaScript
    HTML5
    CSS3
    React
    ...

Backend & Databases
    PHP
    MySQL
    ...

UI/UX & Graphic Design
    Figma
    Illustrator
    Photoshop
    ...
```

The database determines what appears.

Example:

```javascript
function renderSkills(categories) {
    const container = document.querySelector("#skills-grid");

    container.innerHTML = categories.map(category => `
        <article class="skill-category">

            <div class="skill-category-header">
                <h3>
                    ${escapeHTML(category.title || category.category || "")}
                </h3>
            </div>

            <div class="skill-tags">
                ${renderSkillTags(category)}
            </div>

        </article>
    `).join("");
}
```

The exact field names must follow the existing schema rather than assuming new fields.

---

# 29. Certifications Rendering

```javascript
function renderCertifications(certifications) {
    const container =
        document.querySelector("#certifications-grid");

    container.innerHTML = certifications.map(cert => `
        <article class="certificate-card">

            ${
                cert.badge_icon
                ? `
                    <img
                        src="${escapeAttribute(cert.badge_icon)}"
                        alt=""
                        loading="lazy"
                    >
                `
                : ""
            }

            <h3>
                ${escapeHTML(cert.title || "")}
            </h3>

            <p>
                ${escapeHTML(cert.issuer || "")}
            </p>

            <time>
                ${escapeHTML(cert.issue_date || "")}
            </time>

            ${
                cert.credential_url
                ? `
                    <a
                        href="${escapeAttribute(cert.credential_url)}"
                        target="_blank"
                        rel="noopener noreferrer">
                        View Credential
                    </a>
                `
                : ""
            }

        </article>
    `).join("");
}
```

---

# 30. App Initialization

Use one main initialization function.

```javascript
async function initPortfolio() {
    try {
        await loadProfile();

        const [
            uiuxProjects,
            graphicProjects,
            experience,
            education,
            skills,
            certifications
        ] = await Promise.all([
            getUIUXProjects(),
            getGraphicProjects(),
            getExperience(),
            getEducation(),
            getSkills(),
            getCertifications()
        ]);

        renderUIUXProjects(uiuxProjects);
        renderGraphicProjects(graphicProjects);
        renderExperience(experience);
        renderEducation(education);
        renderSkills(skills);
        renderCertifications(certifications);

    } catch (error) {
        console.error("Portfolio initialization failed:", error);
    }
}

document.addEventListener("DOMContentLoaded", initPortfolio);
```

---

# 31. Better Parallel Loading

Do not load everything one-by-one if it is independent.

Avoid:

```javascript
await getProfile();
await getUIUXProjects();
await getGraphicProjects();
await getExperience();
await getEducation();
```

Prefer:

```javascript
const [
    profile,
    uiuxProjects,
    graphicProjects,
    experience,
    education,
    skills,
    certifications
] = await Promise.all([
    getProfile(),
    getUIUXProjects(),
    getGraphicProjects(),
    getExperience(),
    getEducation(),
    getSkills(),
    getCertifications()
]);
```

This can reduce waiting time.

---

# 32. Loading State

Every dynamic section needs a loading state.

Example:

```html
<div id="projects-loading" class="loading-state">
    Loading projects...
</div>
```

After loading:

```javascript
document.querySelector("#projects-loading")
    ?.remove();
```

For a premium UI, use skeleton cards instead of plain text.

---

# 33. Error State

Example:

```javascript
function showSectionError(selector, message) {
    const container = document.querySelector(selector);

    if (!container) return;

    container.innerHTML = `
        <div class="section-error">
            <p>${escapeHTML(message)}</p>
            <button onclick="location.reload()">
                Try Again
            </button>
        </div>
    `;
}
```

Do not allow one failed database query to destroy the entire website.

---

# 34. Empty State

If no published projects exist:

```javascript
if (!projects.length) {
    container.innerHTML = `
        <div class="empty-state">
            No projects available right now.
        </div>
    `;
}
```

Alternatively, hide that section if the design requires it.

---

# 35. What Must Be Hard-Coded

Hard-code only UI constants.

Example:

```javascript
const SITE_CONFIG = {
    sections: [
        "Home",
        "About",
        "Work",
        "Skills",
        "Experience",
        "Education",
        "Certifications",
        "Contact"
    ]
};
```

This is acceptable because navigation structure is part of the template.

Other acceptable constants:

```javascript
const ROLE_INTERVAL = 2500;
const MOBILE_BREAKPOINT = 768;
const PROJECTS_PER_PAGE = 12;
```

These are technical/UI settings, not user content.

---

# 36. What Must NOT Be Hard-Coded

Do not hard-code:

```javascript
const name = "Sachintha";
const role = "Full-Stack Developer";
const gpa = "3.90";
const years = "5+";
```

Do not hard-code:

```javascript
const projects = [...]
```

Do not hard-code:

```javascript
const experience = [...]
```

Do not hard-code:

```javascript
const skills = [...]
```

Do not hard-code:

```javascript
const certifications = [...]
```

If an admin changes the database, the website should automatically reflect the change.

---

# 37. Contact Information

If contact details are currently stored in the database, retrieve them from there.

If a particular contact link is intentionally a permanent design constant and is not part of the current database schema, it can remain in a configuration file.

Example:

```javascript
const CONTACT_CONFIG = {
    github: "YOUR_EXISTING_GITHUB_URL",
    linkedin: "YOUR_EXISTING_LINKEDIN_URL"
};
```

Do not invent new contact details.

---

# 38. Footer

Static design:

```html
<footer>
    <div class="footer-inner">
        <div class="footer-brand">
            <span class="footer-name"></span>
            <span class="footer-role"></span>
        </div>

        <div id="footer-links"></div>

        <p class="copyright">
            © 2026 All Rights Reserved.
        </p>
    </div>
</footer>
```

If name/role is already in Supabase, populate them from the same profile object.

Do not maintain the same information in three different files.

---

# 39. Single Source of Truth

Avoid this situation:

```text
Name in index.html
Name in config.js
Name in database
Name in footer.js
```

That creates synchronization problems.

Instead:

```text
Supabase Profile
       ↓
profile object
       ↓
Hero
Footer
About
SEO
```

One database value can feed multiple UI locations.

---

# 40. SEO Data

The title and meta description can be generated from profile information.

Example:

```javascript
document.title =
    `${profile.hero_title_name} — ${profile.hero_title_role}`;

document
    .querySelector('meta[name="description"]')
    ?.setAttribute(
        "content",
        profile.hero_subtitle || ""
    );
```

If the title is a deliberate SEO constant, it can also remain in HTML.

---

# 41. Image Strategy

Database stores the image path/URL.

Frontend displays it.

Example:

```text
Supabase
    banner_url
       ↓
JavaScript
       ↓
<img src="...">
```

Do not copy image URLs into separate JavaScript arrays.

Do not rename existing image files without updating their database references.

---

# 42. GitHub Pages Compatibility

Because GitHub Pages is static:

```text
HTML
CSS
JavaScript
Supabase
```

are appropriate.

Do not add PHP to the public frontend.

Do not require a Node.js server for normal page rendering.

Supabase acts as the backend/data service.

---

# 43. Relative Asset Paths

Use:

```text
assets/images/profile.webp
Preview/project.html
```

Avoid machine-specific paths:

```text
C:\Users\...
```

Always test the website from the GitHub Pages URL, not only from a local file.

---

# 44. New Template Integration

When using a template, separate it into two layers.

## Template layer

```text
Header
Hero structure
Cards
Grid
Typography
Animations
Navigation
Buttons
Footer
```

## Portfolio data layer

```text
Profile
Projects
Experience
Education
Skills
Certifications
```

The template must never replace the data layer.

---

# 45. Recommended New Page Sections

```text
01 Header
02 Hero
03 About
04 Selected Work
05 Skills
06 Experience
07 Education
08 Certifications
09 Contact
10 Footer
```

---

# 46. Hero

Hard-coded:

```text
Hero layout
CTA button structure
Decorative shapes
Animation
```

Database:

```text
Name
Role
Rotating roles
Subtitle
Availability
Statistics
```

Example:

```html
<h1 id="hero-name"></h1>

<div class="hero-role">
    <span id="hero-role"></span>
</div>

<p id="hero-subtitle"></p>

<div class="hero-stats">
    <div>
        <strong id="years-exp"></strong>
        <span>Years Experience</span>
    </div>

    <div>
        <strong id="deployed-systems"></strong>
        <span>Systems</span>
    </div>

    <div>
        <strong id="freelance-clients"></strong>
        <span>Clients</span>
    </div>
</div>
```

---

# 47. About

The visual layout is hard-coded.

The actual personal/profile data should come from Supabase wherever the existing schema supports it.

Do not create duplicate profile objects just for the About section.

Reuse:

```javascript
profile
```

---

# 48. Work

Database:

```text
portfolio_uiux
portfolio_graphics
```

UI:

```text
Project cards
Filter
Hover effects
Gallery
Modal/detail page
```

---

# 49. Skills

Database:

```text
portfolio_skills
```

UI:

```text
Category cards
Skill badges
Main/core/learning styling
Hover animations
```

---

# 50. Experience

Database:

```text
portfolio_experience
```

UI:

```text
Timeline
Period
Title
Company
Achievements
External link
```

---

# 51. Education

Database:

```text
portfolio_education
```

UI:

```text
Semester cards
GPA
Pending badge
Module accordion
Timeline
```

---

# 52. Certifications

Database:

```text
portfolio_certifications
```

UI:

```text
Certificate cards
Issuer
Date
Badge
Credential link
```

---

# 53. Database Query Rules

Every public query should:

1. Select only required data when practical.
2. Filter unpublished records.
3. Apply predictable sorting.
4. Handle errors.
5. Return an empty array instead of breaking the page.

Example:

```javascript
const { data, error } = await supabaseClient
    .from("portfolio_uiux")
    .select("*")
    .eq("is_published", true)
    .order("sort_order", { ascending: true });
```

---

# 54. Public vs Admin Data

Public portfolio:

```text
SELECT published records
```

Admin:

```text
INSERT
UPDATE
DELETE
```

Do not give anonymous visitors unrestricted write access.

---

# 55. RLS Security

Avoid policies like:

```sql
USING (true)
```

for public write access.

Public site should generally have:

```text
anon → SELECT
```

Admin should have:

```text
authenticated admin → INSERT
authenticated admin → UPDATE
authenticated admin → DELETE
```

The exact RLS implementation must follow the current Supabase authentication/admin architecture.

---

# 56. Important Security Principle

Never put:

```text
SUPABASE_SERVICE_ROLE_KEY
```

in:

```text
index.html
config.js
browser JavaScript
```

The service-role key bypasses normal RLS protections and must remain server-side.

---

# 57. Admin Compatibility

The existing admin system should continue using the same tables.

Test:

```text
Admin creates project
        ↓
Supabase
        ↓
Public website query
        ↓
New project appears
```

Also test:

```text
Admin edits project
        ↓
Supabase
        ↓
Refresh public website
        ↓
Updated project appears
```

And:

```text
Admin sets is_published = false
        ↓
Public query filters it out
```

---

# 58. Data Flow for Every Section

## Profile

```text
portfolio_profile_settings
        ↓
getProfile()
        ↓
profile object
        ↓
Hero / About / Stats / Footer / SEO
```

## UI/UX

```text
portfolio_uiux
        ↓
getUIUXProjects()
        ↓
projects[]
        ↓
Project Cards / Gallery / Details
```

## Graphics

```text
portfolio_graphics
        ↓
getGraphicProjects()
        ↓
projects[]
        ↓
Design Cards / Gallery / Details
```

## Experience

```text
portfolio_experience
        ↓
getExperience()
        ↓
experience[]
        ↓
Timeline
```

## Education

```text
portfolio_education
        ↓
getEducation()
        ↓
education[]
        ↓
Semester Cards
```

## Skills

```text
portfolio_skills
        ↓
getSkills()
        ↓
skills[]
        ↓
Skill Categories
```

## Certifications

```text
portfolio_certifications
        ↓
getCertifications()
        ↓
certifications[]
        ↓
Certificate Cards
```

---

# 59. Development Order

Follow this exact order.

## Phase 01 — Backup

- Backup existing repository.
- Backup database.
- Keep current `index.html`.
- Keep current `admin.html`.
- Keep existing seed SQL.
- Do not delete old files.

---

## Phase 02 — Database Audit

Record:

- Table names
- Column names
- Data types
- JSON/array fields
- Existing image paths
- Existing URLs
- RLS policies
- Existing admin behavior

Do not redesign the schema unless required.

---

## Phase 03 — Template Preparation

Remove template demo content.

Keep:

- Layout
- Components
- CSS
- Animations
- Navigation
- Responsive styles

Replace:

- Demo name
- Demo projects
- Demo statistics
- Demo testimonials
- Demo social links
- Demo images

---

## Phase 04 — Static UI

Build:

```text
Header
Hero
About
Work
Skills
Experience
Education
Certifications
Contact
Footer
```

At this stage, use temporary placeholders only to build the visual layout.

---

## Phase 05 — Supabase Connection

Connect:

```text
Profile
UI/UX
Graphics
Experience
Education
Skills
Certifications
```

Remove the temporary content after each section is connected.

---

## Phase 06 — Dynamic Rendering

Implement:

```text
Loading
Success
Empty
Error
```

for every dynamic section.

---

## Phase 07 — Project Details

Implement:

```text
Project modal/detail
Gallery
Tools
External links
UI/UX screens
Graphic gallery
```

---

## Phase 08 — Responsive

Test:

```text
360px
390px
430px
768px
1024px
1280px
1440px
1920px
```

---

## Phase 09 — Security

Review:

```text
RLS
Anon access
Admin access
Service role key
Public write access
```

---

## Phase 10 — Final QA

Check every database record against the new website.

---

# 60. Testing Checklist

## Profile

- [ ] Name correct
- [ ] Role correct
- [ ] Rotating roles correct
- [ ] Subtitle correct
- [ ] Availability correct
- [ ] Statistics correct
- [ ] GPA correct

## Projects

- [ ] UI/UX projects load
- [ ] Graphic projects load
- [ ] Correct images
- [ ] Correct titles
- [ ] Correct descriptions
- [ ] Correct categories
- [ ] Correct tools
- [ ] Correct external links
- [ ] Published filtering works
- [ ] Sort order works
- [ ] Galleries work

## Experience

- [ ] Dates correct
- [ ] Titles correct
- [ ] Company/context correct
- [ ] Achievements correct
- [ ] Links work

## Education

- [ ] All semesters load
- [ ] GPA values correct
- [ ] Pending status works
- [ ] Modules correct
- [ ] Module count correct

## Skills

- [ ] All categories load
- [ ] All skills load
- [ ] Tags render correctly
- [ ] No manually duplicated skills

## Certifications

- [ ] Title
- [ ] Issuer
- [ ] Date
- [ ] Badge
- [ ] Credential URL

---

# 61. Final Architecture

```text
                         SUPABASE
                             │
             ┌───────────────┼────────────────┐
             │               │                │
          PROFILE          PROJECTS         OTHER DATA
             │               │                │
             │        ┌──────┴──────┐     ┌───┴────────┐
             │        │             │     │            │
             │       UIUX        Graphics Experience Education
             │                                      Skills
             │                                      Certifications
             │
             └───────────────┬──────────────────────┘
                             │
                             ▼
                       DATA LAYER
                             │
                ┌────────────┼────────────┐
                │            │            │
             Queries      Normalize     Validate
                │            │            │
                └────────────┼────────────┘
                             ▼
                     RENDERING LAYER
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
       Hero               Projects            Skills
        │                    │                    │
   Experience            Education         Certifications
        │                    │                    │
        └────────────────────┼────────────────────┘
                             ▼
                      NEW TEMPLATE UI
                             │
                             ▼
                     User's Portfolio
```

---

# 62. The Most Important Development Rule

Before adding any new hard-coded portfolio information, ask:

> "Can this information already come from Supabase?"

If YES:

```text
Use Supabase.
```

If NO and it is purely UI/design behavior:

```text
Hard-code it.
```

Examples:

```text
"Food Delivery App"
→ Supabase

"RuuGraphics Brand & Promotional Suite"
→ Supabase

"3.90"
→ Supabase

"JavaScript"
→ Supabase

"View Project"
→ Hard-code

"Selected Work"
→ Hard-code

"Menu"
→ Hard-code

2.5 second animation duration
→ Hard-code

CSS color
→ Hard-code
```

---

# 63. Final Result

The final system should work like this:

```text
Admin changes data
        ↓
Supabase database
        ↓
New portfolio queries database
        ↓
JavaScript receives data
        ↓
Renderer creates UI
        ↓
User sees updated portfolio
```

Therefore:

### If the design changes

Database does not need to change.

### If project content changes

CSS does not need to change.

### If a new project is added

No new HTML card needs to be written manually.

### If a project is unpublished

The public site automatically hides it.

### If the order changes

`sort_order` controls the display order.

### If a new certification is added

The certification card is automatically generated.

---

# 64. Definition of Done

The redesign is complete only when all of these are true:

- [ ] New template is fully implemented.
- [ ] Existing data is preserved.
- [ ] Existing Supabase project is reused.
- [ ] Existing database tables are reused.
- [ ] No important portfolio data is duplicated in HTML.
- [ ] No project list is manually hard-coded.
- [ ] Experience is dynamically loaded.
- [ ] Education is dynamically loaded.
- [ ] Skills are dynamically loaded.
- [ ] Certifications are dynamically loaded.
- [ ] Project images come from database references.
- [ ] Project galleries are dynamic.
- [ ] `is_published` works.
- [ ] `sort_order` works.
- [ ] Loading states work.
- [ ] Error states work.
- [ ] Empty states work.
- [ ] Responsive design works.
- [ ] Accessibility basics work.
- [ ] SEO is preserved/improved.
- [ ] Admin changes appear on the new website.
- [ ] Public users cannot perform unauthorized writes.
- [ ] Service-role key is not exposed.
- [ ] GitHub Pages works.
- [ ] All existing portfolio content has been checked.

---

# 65. Final Development Principle

The project should NOT be rebuilt as:

```text
New Template
+
Hard-coded portfolio content
+
Separate database
```

It should be:

```text
New Template
+
Existing Supabase Data
+
Reusable Data Layer
+
Dynamic Rendering
+
Secure RLS
+
Responsive UI
```

### Final architecture statement

> **Supabase controls the portfolio content. JavaScript controls data retrieval and rendering. HTML controls structure. CSS controls presentation. The new template changes the visual experience without changing the existing portfolio information.**
