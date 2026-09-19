/* ==========================================================================
   portfolio.js — pulls every dynamic section from Supabase and renders it
   into the Unfold markup. Credentials live in config.js only.

   Tables: portfolio_profile_settings, portfolio_projects, portfolio_uiux,
           portfolio_graphics, portfolio_skills, portfolio_experience,
           portfolio_education, portfolio_certifications, portfolio_reviews
   Storage: the "gallery" bucket.
   ========================================================================== */

(function () {
  'use strict';

  var WEB3FORMS_KEY = 'e02a1e6a-8f97-4401-8b5b-7cd679e600b9';

  var db = (window.supabase && window.SUPABASE_URL && window.SUPABASE_ANON_KEY)
    ? window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY)
    : null;

  if (!db) {
    console.error('[portfolio] Supabase client not created. Check config.js. ' +
      'Open supabase-check.html to diagnose.');
  }

  /* ---------------------------------------------------------------- utils */

  function esc(v) {
    if (v === null || v === undefined) return '';
    return String(v)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  function el(id) { return document.getElementById(id); }

  function hideSection(id) {
    var s = el(id);
    if (s) s.style.display = 'none';
  }

  function stopLoader(id) {
    var l = el(id);
    if (l) l.remove();
  }

  function toast(msg) {
    var box = el('uf-toasts');
    if (!box) return;
    var t = document.createElement('div');
    t.className = 'uf-toast';
    t.textContent = msg;
    box.appendChild(t);
    requestAnimationFrame(function () {
      requestAnimationFrame(function () { t.classList.add('show'); });
    });
    setTimeout(function () {
      t.classList.remove('show');
      setTimeout(function () { t.remove(); }, 400);
    }, 5000);
  }

  // Base Supabase storage URLs
  var SUPABASE_STORAGE_URL = (window.SUPABASE_URL || 'https://tvwxoexhhjgtqbhcfvwn.supabase.co') + '/storage/v1/object/public/';
  var PROJECT_BANNERS_URL = SUPABASE_STORAGE_URL + 'Project%20Banners/';

  // Resolve image paths from Supabase Storage or relative/absolute URLs
  function resolveImg(name, folder) {
    if (!name) return '';
    if (/^(https?:)?\/\//.test(name)) return name;
    if (name.indexOf('/') !== -1) return name; // already a relative path — serve as-is
    if (folder) return folder.replace(/\/$/, '') + '/' + name;
    return PROJECT_BANNERS_URL + encodeURIComponent(name);
  }

  function thumbOf(item) {
    if (!item) return '';
    var raw = item.banner_url || item.image_url || ((item.images && item.images.length) ? item.images[0] : '');
    if (!raw) return '';
    return resolveImg(raw, item.folder);
  }

  // Returns the ordered image list for a project/UIUX item directly from DB
  function uiuxImages(item) {
    var dbImgs = (item.images || item.gallery_urls || []);
    if (dbImgs.length) {
      return dbImgs.map(function (n) { return resolveImg(n, item.folder); }).filter(Boolean);
    }
    return [];
  }

  /* ------------------------------------------------------- profile / hero */

  var HERO_ROLES = [
    'Full-Stack Developer.', 'Software Engineer.', 'UI/UX Designer.',
    'IT Support Specialist.', 'Problem Solver.', 'Graphic Designer.'
  ];

  function typeLoop() {
    var target = el('uf-typed');
    if (!target) return;
    var idx = 0, chars = 0, deleting = false;
    var text = document.createElement('span');
    var cursor = document.createElement('span');
    cursor.className = 'uf-typed-cursor';
    cursor.innerHTML = '&nbsp;';
    target.innerHTML = '';
    target.appendChild(text);
    target.appendChild(cursor);

    (function step() {
      var current = HERO_ROLES[idx % HERO_ROLES.length];
      if (!deleting) {
        chars++;
        text.textContent = current.slice(0, chars);
        if (chars === current.length) {
          deleting = true;
          return setTimeout(step, 1700);
        }
      } else {
        chars--;
        text.textContent = current.slice(0, chars);
        if (chars === 0) { deleting = false; idx++; }
      }
      setTimeout(step, deleting ? 40 : 85);
    })();
  }

  function setCounter(id, raw, label) {
    var wrap = el(id);
    if (!wrap || raw === undefined || raw === null) return;
    var num = wrap.querySelector('.number-counter');
    var lbl = wrap.querySelector('.counter-label');
    var append = wrap.querySelector('.append-text');
    var strVal = String(raw).trim();
    var m = strVal.match(/^([0-9.]+)(.*)$/);
    if (num && m) {
      var numVal = m[1];
      var suffix = m[2] ? m[2] : (strVal.indexOf('+') !== -1 ? '+' : '');
      num.setAttribute('data-number', numVal);
      jQuery(num).data('number', numVal);   // keep jQuery's data cache in sync
      num.textContent = '0';
      if (append) append.textContent = suffix;
    } else if (num) {
      num.removeAttribute('data-number');
      num.textContent = strVal;
      if (append) append.textContent = '';
    }
    if (lbl && label) lbl.textContent = label;
  }

  async function loadProfile() {
    if (!db) { typeLoop(); return; }
    try {
      var res = await db.from('portfolio_profile_settings')
        .select('*').eq('id', 'main_profile').single();
      var d = res.data;

      if (!d) { typeLoop(); autoStats(); return; }

      if (d.hero_roles && d.hero_roles.length) HERO_ROLES = d.hero_roles;
      if (d.availability_status) {
        var b = el('uf-availability');
        if (b) b.textContent = d.availability_status;
      }
      if (d.hero_subtitle) {
        var s = el('uf-hero-subtitle');
        if (s) s.textContent = d.hero_subtitle;
      }

      setCounter('stat-years', d.years_exp || '3+', 'Years Client Handling Experience');
      setCounter('stat-systems', d.deployed_systems || '10+', 'Deployed Systems');
      setCounter('stat-clients', d.freelance_clients || '40+', 'Global Freelance Clients');
      setCounter('stat-gpa', d.cgpa_value || '3.70', d.cgpa_label || 'HNDIT Cumulative GPA — Semester I–III');

      if (d.cgpa_note) {
        var n = el('uf-gpa-note');
        if (n) n.textContent = d.cgpa_note;
      }

      typeLoop();
      autoStats(d);
    } catch (e) {
      console.warn('[portfolio] profile settings:', e.message);
      typeLoop();
      autoStats();
    }
  }

  // Fills in any stat the settings row left blank, computed from the data.
  async function autoStats(settings) {
    if (!db) return;
    settings = settings || {};
    try {
      if (!settings.deployed_systems) {
        var p = await db.from('portfolio_projects').select('id').eq('is_published', true);
        if (p.data && p.data.length) setCounter('stat-systems', p.data.length + '+', 'Deployed Systems');
      }
      if (!settings.cgpa_value) {
        var e = await db.from('portfolio_education').select('gpa_text, is_pending');
        if (e.data && e.data.length) {
          var total = 0, count = 0;
          e.data.forEach(function (row) {
            if (row.is_pending || !row.gpa_text) return;
            var m = row.gpa_text.match(/\d+(\.\d+)?/);
            if (m) { total += parseFloat(m[0]); count++; }
          });
          if (count) {
            setCounter('stat-gpa', (total / count).toFixed(2), 'HNDIT Cumulative GPA — Semester I–III');
            var note = el('uf-gpa-note');
            if (note) note.textContent = 'Average across ' + count + ' completed semesters. Semester IV result is pending.';
          }
        }
      }
      if (!settings.years_exp) {
        var x = await db.from('portfolio_experience').select('period').eq('is_published', true);
        if (x.data && x.data.length) {
          var min = new Date().getFullYear();
          x.data.forEach(function (row) {
            var years = (row.period || '').match(/\b(19|20)\d\d\b/g) || [];
            years.forEach(function (y) { if (+y < min) min = +y; });
          });
          setCounter('stat-years', Math.max(1, new Date().getFullYear() - min) + '+', 'Years Client Handling Experience');
        }
      }
    } catch (err) { /* stats stay at their static defaults */ }
  }

  /* ------------------------------------------------------------- portfolio */

  var byKey = {};   // "kind:slug" -> row

  function gridItem(item, kind, filterClass, categoryText) {
    var thumb = thumbOf(item);
    if (!thumb) return ''; // Hide items that don't have a banner image

    var key = kind + ':' + item.slug;
    byKey[key] = item;

    // Project icon
    var iconClass = item.icon || (kind === 'uiux' ? 'fa-wand-magic-sparkles' : (kind === 'graphics' ? 'fa-palette' : 'fa-laptop-code'));
    if (iconClass.indexOf('fa-') !== 0) iconClass = 'fa-' + iconClass;

    // Status badge (e.g. PERSONAL PROJECT / COMPLETED / ONGOING / FEATURED)
    var badgeLabel = item.badge_text || (item.is_featured ? 'Featured' : (kind === 'project' ? 'Personal Project' : (kind === 'uiux' ? 'UI/UX Design' : 'Graphic Design')));
    var badgeClass = item.is_featured ? 'is-featured' : 'is-standard';

    // Tech stack pills (compact)
    var techList = (item.tech || item.tools || []);
    var techMarkup = '';
    if (techList && techList.length) {
      techMarkup = '<div class="uf-card-tech">' +
        techList.slice(0, 4).map(function (t) {
          return '<span class="uf-tech-pill">' + esc(t) + '</span>';
        }).join('') +
        '</div>';
    }

    // Description text
    var descText = item.card_desc || item.tagline || categoryText || '';

    // On error, remove the entire card item cleanly so no broken card or fallback is shown
    var onErrorScript = "var it=this.closest('.item'); if(it){ it.remove(); if(window.jQuery && window.jQuery('#posts').data('isotope')) window.jQuery('#posts').isotope('layout'); }";

    var media = '<img src="' + esc(thumb) + '" class="uf-card-img" alt="' + esc(item.title) + '" loading="lazy" onerror="' + onErrorScript + '">';

    return '' +
      '<div class="item ' + filterClass + ' col-sm-6 col-md-6 col-lg-4 isotope-mb-2">' +
        '<div class="portfolio-item isotope-item uf-open" data-key="' + esc(key) + '">' +
          '<div class="uf-card-banner">' +
            media +
            '<div class="uf-banner-overlay">' +
              '<span class="uf-banner-btn"><i class="fas fa-arrow-up-right-from-square"></i></span>' +
            '</div>' +
          '</div>' +
          '<div class="uf-card-body">' +
            '<div class="uf-card-header">' +
              '<div class="uf-card-icon"><i class="fas ' + esc(iconClass) + '"></i></div>' +
              '<span class="uf-card-badge ' + badgeClass + '">' + esc(badgeLabel) + '</span>' +
            '</div>' +
            '<h3 class="uf-card-title">' + esc(item.title) + '</h3>' +
            (descText ? '<p class="uf-card-desc">' + esc(descText) + '</p>' : '') +
            techMarkup +
            '<div class="uf-card-footer">' +
              '<span class="uf-card-link">View Details <i class="fas fa-arrow-right ml-1"></i></span>' +
            '</div>' +
          '</div>' +
        '</div>' +
      '</div>';
  }

  function initIsotope() {
    var $grid = jQuery('#posts');
    if (!$grid.length) return;

    $grid.isotope({ itemSelector: '.item', isFitWidth: true });
    $grid.isotope({ filter: '*' });

    jQuery('#filters').off('click', 'a').on('click', 'a', function (e) {
      e.preventDefault();
      $grid.isotope({ filter: jQuery(this).attr('data-filter') });
      jQuery('#filters a').removeClass('active');
      jQuery(this).addClass('active');
    });

    jQuery('.js-filter').off('click').on('click', function (e) {
      e.preventDefault();
      jQuery('#filters').toggleClass('active');
    });

    $grid.imagesLoaded().progress(function () { $grid.isotope('layout'); });
    jQuery(window).on('resize', function () { $grid.isotope('layout'); });
  }

  async function loadPortfolio() {
    if (!db) { stopLoader('uf-portfolio-loading'); hideSection('portfolio-section'); return; }

    var html = '';

    try {
      var projects = await db.from('portfolio_projects').select('*')
        .eq('is_published', true)
        .order('is_featured', { ascending: false })
        .order('sort_order', { ascending: true });

      (projects.data || []).forEach(function (p) {
        var cats = (p.tech || []).slice(0, 3).join(', ') || 'Development';
        html += gridItem(p, 'project', 'f-dev', cats);
      });
      if (projects.error) console.error('[portfolio] projects:', projects.error.message);
    } catch (e) { console.error('[portfolio] projects:', e.message); }

    try {
      var uiux = await db.from('portfolio_uiux').select('*')
        .eq('is_published', true).order('sort_order', { ascending: true });
      (uiux.data || []).forEach(function (u) {
        html += gridItem(u, 'uiux', 'f-uiux', u.category || 'UI/UX Design');
      });
    } catch (e) { /* section just stays smaller */ }

    try {
      var gfx = await db.from('portfolio_graphics').select('*')
        .eq('is_published', true).order('sort_order', { ascending: true });
      (gfx.data || []).forEach(function (g) {
        html += gridItem(g, 'graphics', 'f-graphics', g.category || 'Graphic Design');
      });
    } catch (e) { /* ditto */ }

    stopLoader('uf-portfolio-loading');

    if (!html) { hideSection('portfolio-section'); return; }

    el('posts').innerHTML = html;
    initIsotope();

    // Hide any filter whose category returned nothing.
    setTimeout(function () {
      ['f-dev', 'f-uiux', 'f-graphics'].forEach(function (cls) {
        if (!document.querySelector('#posts .' + cls)) {
          var btn = document.querySelector('#filters a[data-filter=".' + cls + '"]');
          if (btn) btn.style.display = 'none';
        }
      });
    }, 500);
  }

  /* ----------------------------------------------------------------- modal */

  function openModal(key) {
    var d = byKey[key];
    if (!d) return;
    var kind = key.split(':')[0];

    var banner = thumbOf(d);
    el('uf-modal-banner').innerHTML = banner
      ? '<img src="' + esc(banner) + '" class="uf-modal-banner" alt="' + esc(d.title) + '" ' +
        'onerror="this.parentElement.style.display=\'none\'">'
      : '';

    el('uf-modal-title').textContent = d.title || '';

    var tagline = d.tagline || d.category || (d.badge_text || '');
    var tagEl = el('uf-modal-tagline');
    tagEl.textContent = tagline;
    tagEl.style.display = tagline ? 'block' : 'none';

    // modal_desc may legitimately contain the author's own markup.
    el('uf-modal-desc').innerHTML = d.modal_desc || esc(d.card_desc || '');

    // Key features (projects only)
    var feats = Array.isArray(d.features) ? d.features : [];
    el('uf-modal-features').innerHTML = feats.length
      ? '<div class="uf-modal-h">Key Features</div><div class="row gutter-v3">' +
        feats.map(function (f) {
          return '<div class="col-md-6 mb-3"><div class="uf-feature">' +
            '<i class="fas ' + esc(f.icon || 'fa-check') + '"></i>' +
            '<div><strong>' + esc(f.title || '') + '</strong>' +
            '<span>' + esc(f.desc || '') + '</span></div></div></div>';
        }).join('') + '</div>'
      : '';

    // Build / process steps
    var steps = d.stepper || [];
    el('uf-modal-steps').innerHTML = steps.length
      ? '<div class="uf-modal-h">Process</div><div class="uf-steps">' +
        steps.map(function (s, i) {
          return '<span class="uf-step"><i class="fas fa-check"></i>' + esc(s) + '</span>' +
            (i < steps.length - 1 ? '<span class="uf-step-sep">&rsaquo;</span>' : '');
        }).join('') + '</div>'
      : '';

    // Tech / tools
    var chips = (d.tech || d.tools || []);
    el('uf-modal-tech').innerHTML = chips.length
      ? '<div class="uf-modal-h">' + (kind === 'project' ? 'Tech Stack' : 'Tools') + '</div>' +
        '<div class="uf-tags">' + chips.map(function (t) {
          return '<span class="uf-tag">' + esc(t) + '</span>';
        }).join('') + '</div>'
      : '';

    // Screenshot gallery — use local uiux bundle when DB images absent
    var imgs = (kind === 'uiux') ? uiuxImages(d) :
      (d.images || d.gallery_urls || []).map(function (n) {
        return resolveImg(n, d.folder);
      }).filter(Boolean);
    el('uf-modal-gallery').innerHTML = imgs.length
      ? '<div class="uf-modal-h">Screens</div><div class="uf-modal-gallery">' +
        imgs.map(function (src) {
          return '<a href="' + esc(src) + '" data-fancybox="uf-modal-gallery">' +
            '<img src="' + esc(src) + '" alt="" loading="lazy" onerror="this.parentElement.style.display=\'none\'"></a>';
        }).join('') + '</div>'
      : '';

    // Action buttons
    var btns = [];
    if (d.live_url) btns.push('<a href="' + esc(d.live_url) + '" target="_blank" rel="noopener" class="btn btn-outline-pill btn-custom-light">Visit Live Project</a>');
    if (d.specs_url) btns.push('<a href="' + esc(d.specs_url) + '" target="_blank" rel="noopener" class="btn btn-outline-pill btn-custom-light">View Specifications</a>');
    if (d.external_url) btns.push('<a href="' + esc(d.external_url) + '" target="_blank" rel="noopener" class="btn btn-outline-pill btn-custom-light">View Full Design</a>');
    el('uf-modal-actions').innerHTML = btns.join('');
    el('uf-modal-actions').style.display = btns.length ? 'flex' : 'none';

    el('uf-modal').classList.add('is-open');
    el('uf-modal').scrollTop = 0;
    document.body.style.overflow = 'hidden';
  }

  function closeModal() {
    el('uf-modal').classList.remove('is-open');
    document.body.style.overflow = '';
  }

  /* ---------------------------------------------------------------- skills */

  function tagMarkup(raw) {
    return (raw || '').split(',').map(function (t) { return t.trim(); })
      .filter(Boolean).map(function (t) {
        var cls = '', clean = t;
        if (t.indexOf('[main]') > -1) { cls = 'is-main'; clean = t.replace('[main]', '').trim(); }
        else if (t.indexOf('[core]') > -1) { cls = 'is-core'; clean = t.replace('[core]', '').trim(); }
        else if (t.indexOf('[learning]') > -1) { cls = 'is-learning'; clean = t.replace('[learning]', '').trim(); }
        return '<span class="uf-tag ' + cls + '">' +
          (cls ? '<span class="uf-dot"></span>' : '') + esc(clean) + '</span>';
      }).join('');
  }

  async function loadSkills() {
    var grid = el('uf-skills-grid');
    if (!grid || !db) { stopLoader('uf-skills-loading'); hideSection('services-section'); return; }

    try {
      var r = await db.from('portfolio_skills').select('*')
        .eq('is_published', true).order('sort_order', { ascending: true });

      stopLoader('uf-skills-loading');
      if (r.error) console.error('[portfolio] skills:', r.error.message);
      if (!r.data || !r.data.length) { hideSection('services-section'); return; }

      grid.innerHTML = r.data.map(function (s, i) {
        return '<div class="col-md-6 col-lg-4 mb-4">' +
          '<div class="uf-skill-card">' +
            '<div class="uf-skill-icon"><i class="fas ' + esc(s.icon || 'fa-code') + '"></i></div>' +
            '<h3>' + esc(s.title) + '</h3>' +
            '<div class="uf-tags">' + tagMarkup(s.tags) + '</div>' +
          '</div></div>';
      }).join('');
    } catch (e) {
      stopLoader('uf-skills-loading');
      hideSection('services-section');
    }
  }

  /* ------------------------------------------------------ experience / edu */

  async function loadExperience() {
    var wrap = el('uf-experience');
    if (!wrap || !db) { stopLoader('uf-exp-loading'); return; }

    try {
      var r = await db.from('portfolio_experience').select('*')
        .eq('is_published', true).order('sort_order', { ascending: true });

      stopLoader('uf-exp-loading');
      if (r.error) console.error('[portfolio] experience:', r.error.message);

      if (!r.data || !r.data.length) return;

      wrap.innerHTML = '<div class="uf-timeline">' + r.data.map(function (e) {
        var list = (e.achievements || []).map(function (a) {
          return '<li>' + esc(a) + '</li>';
        }).join('');
        var link = e.link_url
          ? '<p class="mt-3 mb-0"><a href="' + esc(e.link_url) + '" target="_blank" rel="noopener" ' +
            'class="btn btn-outline-pill btn-custom-light">' + esc(e.link_label || 'View Details') + '</a></p>'
          : '';
        return '<div class="uf-tl-item">' +
          '<span class="uf-tl-period">' + esc(e.period) + '</span>' +
          '<h3>' + esc(e.title) + '</h3>' +
          '<div class="uf-tl-company">' + esc(e.company) + '</div>' +
          (list ? '<ul class="uf-tl-list">' + list + '</ul>' : '') +
          link + '</div>';
      }).join('') + '</div>';
    } catch (err) { stopLoader('uf-exp-loading'); }
  }

  async function loadEducation() {
    var wrap = el('uf-education');
    if (!wrap) return;

    if (!db) {
      stopLoader('uf-edu-loading');
      return;
    }

    try {
      var r = await db.from('portfolio_education').select('*')
        .order('sort_order', { ascending: true });

      stopLoader('uf-edu-loading');

      if (!r.data || !r.data.length) return;

      wrap.innerHTML = '<div class="uf-academic-list">' + r.data.map(function (s, idx) {
        var gpa = s.is_pending
          ? '<span class="uf-gpa-badge is-pending">Result Pending</span>'
          : (s.gpa_text ? '<span class="uf-gpa-badge">' +
              (s.gpa_text.toUpperCase().indexOf('GPA') === -1 ? 'GPA ' : '') +
              esc(s.gpa_text) + '</span>' : '');

        var title = s.semester_title || s.semester || ('Semester ' + ['I', 'II', 'III', 'IV'][idx]);
        var subtitle = s.module_count_text || s.title || '';

        var modules = [];
        if (Array.isArray(s.modules) && s.modules.length > 0) {
          modules = s.modules;
        } else if (typeof s.modules === 'string') {
          try { modules = JSON.parse(s.modules); } catch (e) { modules = []; }
        }

        if (!subtitle && modules.length) {
          subtitle = modules.length + ' Modules';
        }

        var modulesHtml = '';
        if (modules && modules.length) {
          modulesHtml = '<div class="uf-modules-body">' +
            '<div class="uf-modules-grid">' +
              modules.map(function (m) {
                var code = m.code ? '<span class="uf-module-code">' + esc(m.code) + '</span>' : '';
                var name = m.name ? '<span class="uf-module-name">' + esc(m.name) + '</span>' : '';
                return '<div class="uf-module-item">' + code + name + '</div>';
              }).join('') +
            '</div>' +
          '</div>';
        }

        var openClass = (idx === 0) ? ' is-open' : '';

        return '<div class="uf-academic-item' + openClass + '">' +
          '<div class="uf-academic-card" role="button" tabindex="0">' +
            '<div class="uf-academic-left">' +
              '<h3 class="uf-academic-title">' + esc(title) + '</h3>' +
              (subtitle ? '<span class="uf-academic-subtitle">' + esc(subtitle) + '</span>' : '') +
            '</div>' +
            '<div class="uf-academic-right">' +
              gpa +
              '<span class="uf-academic-chevron"><i class="fas fa-chevron-down"></i></span>' +
            '</div>' +
          '</div>' +
          modulesHtml +
        '</div>';
      }).join('') + '</div>';

      bindEducationToggles(wrap);
    } catch (err) {
      stopLoader('uf-edu-loading');
    }
  }

  function bindEducationToggles(container) {
    if (!container) return;
    var cards = container.querySelectorAll('.uf-academic-card');
    cards.forEach(function (card) {
      card.onclick = function (e) {
        e.stopPropagation();
        var item = card.closest('.uf-academic-item');
        if (!item) return;
        var hasModules = item.querySelector('.uf-modules-body');
        if (hasModules) {
          item.classList.toggle('is-open');
        }
      };
    });
  }

  async function loadCertifications() {
    var grid = el('uf-certs-grid');
    if (!grid) { stopLoader('uf-certs-loading'); return; }
    if (!db) { stopLoader('uf-certs-loading'); return; }

    try {
      var r = await db.from('portfolio_certifications').select('*')
        .eq('is_published', true).order('sort_order', { ascending: true });

      stopLoader('uf-certs-loading');

      if (!r.data || !r.data.length) {
        var block = el('certs-block');
        if (block) block.style.display = 'none';
        return;
      }

      grid.innerHTML = r.data.map(function (c) {
        var date = c.issue_date ? '<p>' + esc(c.issue_date) + '</p>' : '';
        var link = c.credential_url
          ? '<a href="' + esc(c.credential_url) + '" target="_blank" rel="noopener">Verify</a>'
          : '';
        return '<div class="col-md-6 col-lg-6 mb-4"><div class="uf-cert">' +
          '<div class="uf-cert-icon"><i class="fas ' + esc(c.badge_icon || 'fa-certificate') + '"></i></div>' +
          '<div><h4>' + esc(c.title) + '</h4><p>' + esc(c.issuer) + '</p>' + date + link + '</div>' +
          '</div></div>';
      }).join('');
    } catch (err) {
      stopLoader('uf-certs-loading');
    }
  }

  /* ------------------------------------------------------------- reviews */

  function starsMarkup(rating) {
    var r = Math.max(0, Math.min(5, Math.round(Number(rating) || 5)));
    return '★★★★★☆☆☆☆☆'.slice(5 - r, 10 - r);
  }

  async function loadReviews() {
    var grid = el('uf-reviews-grid');
    var statsBox = el('uf-reviews-stats');
    if (!grid) { stopLoader('uf-reviews-loading'); return; }
    if (!db) { stopLoader('uf-reviews-loading'); hideSection('reviews-section'); return; }

    try {
      var r = await db.from('portfolio_reviews').select('*')
        .eq('is_published', true).order('sort_order', { ascending: true });

      stopLoader('uf-reviews-loading');
      if (r.error) console.error('[portfolio] reviews:', r.error.message);
      if (!r.data || !r.data.length) {
        hideSection('reviews-section');
        return;
      }

      var rows = r.data;

      var settings = {};
      try {
        var s = await db.from('portfolio_profile_settings').select(
          'reviews_platform_name, reviews_platform_url, reviews_total_count, reviews_five_star_count'
        ).eq('id', 'main_profile').single();
        settings = s.data || {};
      } catch (e) { /* fall back to row-derived stats below */ }

      var avg = rows.reduce(function (sum, row) { return sum + (Number(row.rating) || 5); }, 0) / rows.length;
      var totalCount = settings.reviews_total_count || rows.length;
      var fiveStar = settings.reviews_five_star_count ||
        rows.filter(function (row) { return Math.round(Number(row.rating) || 5) >= 5; }).length;
      var platformName = settings.reviews_platform_name || rows[0].source || 'Client';
      var platformUrl = settings.reviews_platform_url || rows[0].source_url || '';

      if (statsBox) {
        statsBox.innerHTML = '<div class="uf-review-summary mb-5 p-4 rounded-lg d-flex align-items-center justify-content-between flex-wrap gap-3" style="background: rgba(18, 18, 24, 0.85); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 16px;">' +
          '<div class="d-flex align-items-center gap-3">' +
            '<div class="text-white font-weight-bold" style="font-size: 38px; line-height: 1;">' + avg.toFixed(1) + ' <span style="font-size: 18px; color: var(--uf-muted); font-weight: 400;">/ 5.0</span></div>' +
            '<div>' +
              '<div style="color: #fbbf24; font-size: 16px; letter-spacing: 2px;">' + starsMarkup(avg) + '</div>' +
              '<div class="uf-muted" style="font-size: 13px;"><strong>' + esc(totalCount) + (String(totalCount).indexOf('+') === -1 ? '+' : '') + ' reviews</strong> &middot; ' +
                esc(fiveStar) + (String(fiveStar).indexOf('+') === -1 ? '+' : '') + ' five-star ratings</div>' +
            '</div>' +
          '</div>' +
          (platformUrl
            ? '<a href="' + esc(platformUrl) + '" target="_blank" rel="noopener noreferrer" class="btn btn-outline-pill btn-custom-light">' +
              '<i class="fas fa-arrow-up-right-from-square mr-2"></i> View ' + esc(platformName) + ' Profile</a>'
            : '') +
          '</div>';
      }

      grid.innerHTML = rows.map(function (rv) {
        var initial = (rv.reviewer_name || '?').trim().charAt(0).toUpperCase();
        var flag = rv.country_code
          ? '<img src="https://flagcdn.com/w40/' + esc(rv.country_code.toLowerCase()) + '.png" ' +
            'alt="' + esc(rv.reviewer_country || '') + '" width="14" class="mr-1">'
          : '';
        return '<div class="col-md-6 col-lg-4 mb-4"><div class="uf-review-card p-4 rounded-lg h-100" style="background: rgba(18, 18, 24, 0.75); border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 16px;">' +
          '<div class="d-flex align-items-center justify-content-between mb-3">' +
            '<span class="badge badge-pill" style="background: rgba(16, 185, 129, 0.12); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.25); font-size: 11px; padding: 4px 10px;">' +
              '<i class="fas fa-check-circle mr-1"></i> Verified ' + esc(rv.source || 'Review') +
            '</span>' +
            '<div style="color: #fbbf24; font-size: 13px;">' + starsMarkup(rv.rating) + '</div>' +
          '</div>' +
          '<p class="text-white-50 mb-4" style="font-size: 14px; line-height: 1.6; font-style: italic;">' +
            '&ldquo;' + esc(rv.quote || '') + '&rdquo;' +
          '</p>' +
          '<div class="d-flex align-items-center gap-2 mt-auto">' +
            '<div class="rounded-circle d-flex align-items-center justify-content-center font-weight-bold text-white" style="width: 36px; height: 36px; background: var(--uf-accent-soft); border: 1px solid rgba(56,189,248,0.3); font-size: 14px;">' + esc(initial) + '</div>' +
            '<div class="ml-2">' +
              '<div class="text-white font-weight-bold" style="font-size: 13.5px;">' + esc(rv.reviewer_name || 'Anonymous') + '</div>' +
              (rv.reviewer_country ? '<div class="uf-muted" style="font-size: 12px;">' + flag + esc(rv.reviewer_country) + '</div>' : '') +
            '</div>' +
          '</div>' +
        '</div></div>';
      }).join('');
    } catch (e) {
      stopLoader('uf-reviews-loading');
      hideSection('reviews-section');
    }
  }

  /* --------------------------------------------------------------- gallery */

  async function loadGallery() {
    var track = el('uf-gallery-track');
    if (!track) return;

    var base = window.SUPABASE_URL, key = window.SUPABASE_ANON_KEY;
    if (!base || !key) { stopLoader('uf-gallery-loading'); hideSection('gallery-section'); return; }

    var BUCKET = 'gallery';
    var images = [], captions = {};

    try {
      var res = await fetch(base + '/storage/v1/object/list/' + BUCKET, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': key,
          'Authorization': 'Bearer ' + key
        },
        body: JSON.stringify({ prefix: '', limit: 100, sortBy: { column: 'name', order: 'asc' } })
      });
      if (!res.ok) throw new Error('storage list ' + res.status);
      var files = await res.json();
      images = (files || []).filter(function (f) {
        return f.name && /\.(jpe?g|png|webp|gif|avif)$/i.test(f.name);
      });
    } catch (e) {
      console.error('[portfolio] gallery:', e.message);
      stopLoader('uf-gallery-loading');
      hideSection('gallery-section');
      return;
    }

    try {
      var cRes = await fetch(base + '/storage/v1/object/public/' + BUCKET + '/captions.json', { cache: 'no-store' });
      if (cRes.ok) captions = await cRes.json();
    } catch (e) { /* captions are optional */ }

    stopLoader('uf-gallery-loading');

    if (!images.length) { hideSection('gallery-section'); return; }

    function pretty(name) {
      return name.replace(/\.[^/.]+$/, '').replace(/[-_]+/g, ' ')
        .replace(/\s+/g, ' ').trim()
        .replace(/\b\w/g, function (c) { return c.toUpperCase(); });
    }

    track.innerHTML = images.map(function (f) {
      var url = base + '/storage/v1/object/public/' + BUCKET + '/' + encodeURIComponent(f.name);
      var meta = captions[f.name] || {};
      return '<div class="uf-gallery-item">' +
        '<a href="' + url + '" data-fancybox="uf-gallery" data-caption="' + esc(meta.title || pretty(f.name)) + '">' +
          '<img src="' + url + '" alt="' + esc(meta.title || pretty(f.name)) + '" loading="lazy">' +
          '<span class="uf-gallery-cap"><strong>' + esc(meta.title || pretty(f.name)) + '</strong>' +
          (meta.description ? '<span>' + esc(meta.description) + '</span>' : '') + '</span>' +
        '</a></div>';
    }).join('');

    jQuery(track).owlCarousel({
      loop: images.length > 4,
      margin: 0,
      nav: true,
      dots: false,
      autoplay: true,
      autoplayTimeout: 3500,
      autoplayHoverPause: true,
      smartSpeed: 800,
      navText: ['<span class="icon-keyboard_arrow_left"></span>', '<span class="icon-keyboard_arrow_right"></span>'],
      responsive: { 0: { items: 1 }, 576: { items: 2 }, 992: { items: 3 }, 1200: { items: 4 } }
    });
  }

  /* ---------------------------------------------------------- contact form */

  function wireContactForm() {
    var form = el('uf-contact-form');
    if (!form) return;

    form.addEventListener('submit', async function (e) {
      e.preventDefault();
      var btn = form.querySelector('input[type=submit]');
      var original = btn.value;
      var data = new FormData(form);

      var name = (data.get('name') || '').toString().trim();
      var email = (data.get('email') || '').toString().trim();
      var message = (data.get('message') || '').toString().trim();

      if (!name || !email || message.length < 5) {
        toast('Please fill in your name, a valid email and a short message.');
        return;
      }

      btn.disabled = true;
      btn.value = 'Sending...';

      try {
        var res = await fetch('https://api.web3forms.com/submit', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
          body: JSON.stringify({
            access_key: WEB3FORMS_KEY,
            name: name,
            email: email,
            subject: 'Portfolio Contact: ' + (data.get('subject') || name),
            message: message,
            from_name: "Sachintha's Web Portfolio"
          })
        });
        var out = await res.json();
        if (res.ok && out.success) {
          form.reset();
          toast("Message sent. I'll get back to you soon.");
        } else {
          toast(out.message || 'Something went wrong. Please try again.');
        }
      } catch (err) {
        toast('Network error. Check your connection and try again.');
      } finally {
        btn.disabled = false;
        btn.value = original;
      }
    });
  }

  /* ------------------------------------------------------------------ init */

  function wireUi() {
    document.addEventListener('click', function (e) {
      var opener = e.target.closest ? e.target.closest('.uf-open') : null;
      if (opener) { e.preventDefault(); openModal(opener.getAttribute('data-key')); return; }
      if (e.target.closest && e.target.closest('.uf-modal-close')) { closeModal(); return; }
      if (e.target.id === 'uf-modal') closeModal();
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') closeModal();
    });

    var tabs = document.querySelectorAll('.uf-tab');
    tabs.forEach(function (tab) {
      tab.addEventListener('click', function () {
        tabs.forEach(function (t) { t.classList.remove('active'); });
        tab.classList.add('active');
        var target = tab.getAttribute('data-tab');
        ['work', 'academic'].forEach(function (p) {
          var panel = el('uf-panel-' + p);
          if (panel) panel.style.display = (p === target) ? 'block' : 'none';
        });
      });
    });

    // Delegated click for expandable academic modules
    document.addEventListener('click', function (e) {
      var card = e.target.closest && e.target.closest('.uf-academic-card');
      if (card) {
        var item = card.closest('.uf-academic-item');
        if (item && item.querySelector('.uf-modules-body')) {
          item.classList.toggle('is-open');
        }
      }
    });

    var copyBioBtn = el('copyBioBtn');
    if (copyBioBtn) {
      copyBioBtn.addEventListener('click', function () {
        var bioToCopy = "Sachintha Shyamika | Full-Stack Developer & Software Engineering Undergraduate (HNDIT)\nPortfolio: https://shamikakkss.me/\nContact: shamikakkss@gmail.com | +94 76 083 5913";
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(bioToCopy).then(function () {
            toast('Bio copied to clipboard!');
          }).catch(function () {
            toast('Could not copy bio to clipboard.');
          });
        }
      });
    }
  }

  jQuery(function () {
    wireUi();
    wireContactForm();
    loadProfile();
    loadPortfolio();
    loadSkills();
    loadExperience();
    loadEducation();
    loadCertifications();
    loadReviews();
    loadGallery();
  });

})();
