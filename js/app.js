/* ============================================================
   RABBIT GRILL — site behaviour
   No dependencies. Everything degrades to a working page.
   ============================================================ */
(function () {
  "use strict";

  var doc = document;
  var root = doc.documentElement;
  var reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  var shot = root.hasAttribute("data-shot");
  var still = reduce || shot;

  function $(s, c) { return (c || doc).querySelector(s); }
  function $$(s, c) { return Array.prototype.slice.call((c || doc).querySelectorAll(s)); }

  /* ---------------------------------------------------------
     safe storage — private windows and blocked site data throw
     --------------------------------------------------------- */
  var store = {
    get: function (k) { try { return localStorage.getItem(k); } catch (e) { return null; } },
    set: function (k, v) { try { localStorage.setItem(k, v); } catch (e) {} }
  };

  /* ---------------------------------------------------------
     LANGUAGE  EN / ไทย
     English is captured off the DOM once and never duplicated
     in markup, so the two languages cannot drift apart.
     --------------------------------------------------------- */
  var i18n = (function () {
    var nodes = [];
    var cur = "en";

    function collect() {
      nodes = $$("[data-th]");
      nodes.forEach(function (el) {
        if (!("en" in el.dataset)) el.dataset.en = el.innerHTML.trim();
      });
    }

    function apply(lang) {
      cur = lang === "th" ? "th" : "en";
      nodes.forEach(function (el) {
        var v = cur === "th" ? el.dataset.th : el.dataset.en;
        if (typeof v === "string") el.innerHTML = v;
      });
      root.lang = cur === "th" ? "th" : "en";
      $$("[data-lang-btn]").forEach(function (b) {
        b.setAttribute("aria-pressed", String(b.dataset.langBtn === cur));
      });
      // swap any alternate href/labels (e.g. maps query, aria-labels)
      $$("[data-th-label]").forEach(function (el) {
        var en = el.dataset.enLabel || (el.dataset.enLabel = el.getAttribute("aria-label") || "");
        el.setAttribute("aria-label", cur === "th" ? el.dataset.thLabel : en);
      });
      store.set("rg-lang", cur);
      doc.dispatchEvent(new CustomEvent("rg:lang", { detail: { lang: cur } }));
    }

    return {
      init: function () {
        collect();
        /* ?lang=th makes a Thai link shareable, and gives QA a stable entry point */
        var forced = new URLSearchParams(location.search).get("lang");
        var saved = store.get("rg-lang");
        var want = forced || saved || (navigator.language && /^th/i.test(navigator.language) ? "th" : "en");
        if (want === "th") apply("th"); else apply("en");
        $$("[data-lang-btn]").forEach(function (b) {
          b.addEventListener("click", function () { apply(b.dataset.langBtn); });
        });
      },
      get: function () { return cur; },
      refresh: function () { collect(); apply(cur); }
    };
  })();

  /* ---------------------------------------------------------
     REVEALS
     --------------------------------------------------------- */
  /* Reveals are measured, not observed.
     This used to be an IntersectionObserver, and it hid photographs. IO delivers
     its callbacks as part of the rendering lifecycle, so in any context that is
     not painting normally — an embedded viewer, a backgrounded frame — it can
     deliver NOTHING AT ALL, not even the initial report for an element filling
     the viewport. Everything gated on it then stays at opacity 0 or clipped
     forever, which is the worst possible failure for a page whose whole job is
     showing food. getBoundingClientRect always tells the truth, so we ask it.

     Three ways in, so content cannot be stranded:
       1. a rAF-throttled sweep on scroll and resize — the normal path
       2. a sweep at init, on load, and once the webfonts settle
       3. a backstop that opens everything if no scroll ever arrives, which is
          what happens when the page is embedded and an outer document scrolls */
  function reveals() {
    var els = $$("[data-reveal], .lines, .heatline");
    if (!els.length) return;

    function show(el) { el.classList.add("is-in"); }

    if (still) { els.forEach(show); return; }

    // stagger children inside a group
    $$("[data-stagger]").forEach(function (g) {
      var step = parseInt(g.dataset.stagger, 10) || 90;
      $$("[data-reveal], .lines", g).forEach(function (c, i) {
        c.style.setProperty("--d", (i * step) + "ms");
      });
    });

    var pending = els.slice();
    window.__rgSweep = function () { sweep(); };   // the router re-runs this on page switch
    var ticking = false;
    var scrolled = false;
    var backstop = 0;

    function sweep() {
      ticking = false;
      var vh = window.innerHeight || root.clientHeight || 800;
      for (var i = pending.length - 1; i >= 0; i--) {
        var r = pending[i].getBoundingClientRect();
        if (r.top < vh * 0.92 && r.bottom > -120) { show(pending[i]); pending.splice(i, 1); }
      }
      if (!pending.length) stop();
    }

    function onScroll() {
      scrolled = true;
      if (!ticking) { ticking = true; requestAnimationFrame(sweep); }
    }

    function stop() {
      removeEventListener("scroll", onScroll);
      removeEventListener("resize", onScroll);
      clearTimeout(backstop);
    }

    addEventListener("scroll", onScroll, { passive: true });
    addEventListener("resize", onScroll);
    addEventListener("load", sweep);
    // wheel and touchmove still fire when the document that actually scrolls is
    // an outer one, which is the embedded case
    addEventListener("wheel", onScroll, { passive: true });
    addEventListener("touchmove", onScroll, { passive: true });
    if (doc.fonts && doc.fonts.ready) doc.fonts.ready.then(sweep);

    // No scroll signal by now means there is not going to be one — the page is
    // embedded and something else is doing the scrolling. Open everything
    // rather than leave photographs clipped forever. Anyone who has scrolled
    // inside this window keeps the progressive reveal.
    backstop = setTimeout(function () {
      if (!scrolled) { pending.forEach(show); pending.length = 0; }
      stop();
    }, 2500);

    sweep();
    requestAnimationFrame(sweep);
  }

  /* ---------------------------------------------------------
     HEAT LINE — measure each path so the dash draw works
     --------------------------------------------------------- */
  function heatlines() {
    $$(".heatline [data-draw]").forEach(function (p, i) {
      var len = 0;
      try { len = p.getTotalLength(); } catch (e) { len = 240; }
      if (!len || !isFinite(len)) len = 240;
      p.style.setProperty("--len", Math.ceil(len));
      p.style.setProperty("--d", (i * 70) + "ms");
    });
  }

  /* ---------------------------------------------------------
     HERO — grill-bar mask opens, then content
     --------------------------------------------------------- */
  function hero() {
    var h = $(".hero");
    if (!h) return;
    $$(".hero__bars i", h).forEach(function (b, i) {
      b.style.setProperty("--d", (i * 68) + "ms");
    });
    if (still) { h.classList.add("is-lit"); return; }
    requestAnimationFrame(function () {
      requestAnimationFrame(function () { h.classList.add("is-lit"); });
    });
  }

  /* ---------------------------------------------------------
     NAV — transparent over the hero, solid once past it
     --------------------------------------------------------- */
  function nav() {
    var n = $(".nav");
    if (!n) return;
    var fixed = doc.body.dataset.nav === "solid";
    var bar = $(".bar");
    var trigger = 60;

    function tick() {
      var y = window.pageYOffset || root.scrollTop;
      if (!fixed) n.classList.toggle("is-solid", y > trigger);
      if (bar) bar.classList.toggle("is-up", y > (window.innerHeight * 0.55));
    }
    tick();
    addEventListener("scroll", tick, { passive: true });
    addEventListener("resize", tick);

    /* mobile sheet */
    var sheet = $(".sheet");
    var open = $(".burger");
    var close = $(".sheet__x");
    if (!sheet || !open) return;
    var last = null;

    function setOpen(v) {
      sheet.classList.toggle("is-open", v);
      sheet.setAttribute("aria-hidden", String(!v));
      open.setAttribute("aria-expanded", String(v));
      doc.body.style.overflow = v ? "hidden" : "";
      if (v) { last = doc.activeElement; var f = $("a, button", sheet); if (f) f.focus(); }
      else if (last) last.focus();
    }
    open.addEventListener("click", function () { setOpen(true); });
    if (close) close.addEventListener("click", function () { setOpen(false); });
    $$("a", sheet).forEach(function (a) { a.addEventListener("click", function () { setOpen(false); }); });
    addEventListener("keydown", function (e) {
      if (e.key === "Escape" && sheet.classList.contains("is-open")) setOpen(false);
    });
  }

  /* ---------------------------------------------------------
     CURSOR — desktop pointer only, restrained
     --------------------------------------------------------- */
  function cursor() {
    if (still) return;
    if (!matchMedia("(hover: hover) and (pointer: fine)").matches) return;
    var el = doc.createElement("div");
    el.className = "cur";
    el.setAttribute("aria-hidden", "true");
    el.innerHTML = "<span></span>";
    doc.body.appendChild(el);
    var lab = $("span", el);
    var x = 0, y = 0, tx = 0, ty = 0, on = false, raf = 0;

    function loop() {
      tx += (x - tx) * 0.22;
      ty += (y - ty) * 0.22;
      el.style.transform = "translate(" + (tx - el.offsetWidth / 2) + "px," + (ty - el.offsetHeight / 2) + "px)";
      raf = requestAnimationFrame(loop);
    }
    addEventListener("pointermove", function (e) {
      if (e.pointerType !== "mouse") return;
      x = e.clientX; y = e.clientY;
      if (!on) { on = true; el.classList.add("on"); raf = requestAnimationFrame(loop); }
      var t = e.target.closest ? e.target.closest("[data-cursor]") : null;
      if (t) { el.classList.add("lbl"); lab.textContent = t.dataset.cursor; }
      else { el.classList.remove("lbl"); lab.textContent = ""; }
    }, { passive: true });
    addEventListener("pointerleave", function () { on = false; el.classList.remove("on"); cancelAnimationFrame(raf); });
  }

  /* ---------------------------------------------------------
     MENU PAGE — sticky category nav + scrollspy
     --------------------------------------------------------- */
  function menuNav() {
    var links = $$(".mnav a");
    if (!links.length) return;
    var secs = links.map(function (a) { return $(a.getAttribute("href")); }).filter(Boolean);
    if (!secs.length) return;

    function spy() {
      var top = (window.pageYOffset || root.scrollTop) + (parseInt(getComputedStyle(root).getPropertyValue("--nav-h"), 10) || 68) + 70;
      var idx = 0;
      for (var i = 0; i < secs.length; i++) if (secs[i].offsetTop <= top) idx = i;
      links.forEach(function (a, i) { a.classList.toggle("is-active", i === idx); });
      var act = links[idx];
      if (act && act.parentNode.scrollWidth > act.parentNode.clientWidth) {
        var p = act.parentNode;
        var want = act.offsetLeft - p.clientWidth / 2 + act.clientWidth / 2;
        p.scrollTo ? p.scrollTo({ left: want, behavior: still ? "auto" : "smooth" }) : (p.scrollLeft = want);
      }
    }
    spy();
    addEventListener("scroll", spy, { passive: true });
    addEventListener("resize", spy);
  }

  /* ---------------------------------------------------------
     PAGE ROUTER — only in the single-file build (body[data-spa])

     The four pages get folded into one document for sharing, and
     the first version simply stacked them: ~32,000px of scroll
     with the nav jumping you up and down inside it. A designer
     reading it said, correctly, that you should not have to
     scroll back and forth to move between pages.

     So in the merged build the nav does what it does on the real
     site: it SWITCHES. One .page is visible at a time, the rest
     are display:none, and every in-page link resolves to the page
     that owns its target.
     --------------------------------------------------------- */
  function router() {
    if (!doc.body.hasAttribute("data-spa")) return null;
    var pages = $$(".page");
    if (!pages.length) return null;

    function pageOf(hash) {
      if (!hash || hash === "#" || hash === "#top") return "top";
      var el = null;
      try { el = doc.querySelector(hash); } catch (e) { return null; }
      if (!el) return null;
      var host = el.closest ? el.closest(".page") : null;
      return host ? host.dataset.page : null;
    }

    function show(name, hash) {
      var found = false;
      pages.forEach(function (p) {
        var on = p.dataset.page === name;
        p.hidden = !on;
        if (on) found = true;
      });
      if (!found) { pages[0].hidden = false; name = pages[0].dataset.page; }

      $$("[data-nav-to]").forEach(function (a) {
        if (a.dataset.navTo === name) a.setAttribute("aria-current", "page");
        else a.removeAttribute("aria-current");
      });

      // a switched page starts at the top unless a specific anchor was asked for
      var target = hash && hash !== "#" + name && hash !== "#top" ? doc.querySelector(hash) : null;
      var prev = root.style.scrollBehavior;
      root.style.scrollBehavior = "auto";
      if (target && target.closest(".page") && !target.classList.contains("page")) {
        target.scrollIntoView({ block: "start" });
      } else {
        window.scrollTo(0, 0);
      }
      root.style.scrollBehavior = prev;

      doc.body.dataset.page = name;
      if (window.RG && window.RG.sweep) window.RG.sweep();
    }

    doc.addEventListener("click", function (e) {
      var a = e.target.closest ? e.target.closest('a[href^="#"]') : null;
      if (!a) return;
      var hash = a.getAttribute("href");
      if (hash === "#" ) return;
      var name = pageOf(hash);
      if (!name) return;                       // not ours — let the browser handle it
      e.preventDefault();
      if (history.replaceState) history.replaceState(null, "", hash);
      show(name, hash);
    });

    addEventListener("hashchange", function () {
      var name = pageOf(location.hash);
      if (name) show(name, location.hash);
    });

    show(pageOf(location.hash) || "top", location.hash);
    return true;
  }

  /* ---------------------------------------------------------
     HASH LANDING
     Arriving on a #section lands before the webfonts have swapped
     and before the images have decoded, so the target has usually
     moved by the time the page settles. Re-land once it has.
     --------------------------------------------------------- */
  function hashLanding() {
    if (!location.hash || location.hash === "#top") return;
    var tries = 0;
    var done = false;

    // the moment the reader takes over, stop correcting — being yanked back to
    // a heading you have already scrolled past is worse than landing slightly off
    function surrender() { done = true; }
    addEventListener("wheel", surrender, { passive: true, once: true });
    addEventListener("touchstart", surrender, { passive: true, once: true });
    addEventListener("keydown", surrender, { once: true });

    function land() {
      if (done) return;
      var el = null;
      try { el = doc.querySelector(location.hash); } catch (e) { return; }
      if (!el) return;
      var prev = root.style.scrollBehavior;
      root.style.scrollBehavior = "auto";     // never animate a corrective jump
      el.scrollIntoView({ block: "start" });
      root.style.scrollBehavior = prev;
      if (++tries < 3) setTimeout(land, 260);
    }
    addEventListener("load", land);
    if (doc.fonts && doc.fonts.ready) doc.fonts.ready.then(land);
  }

  /* ---------------------------------------------------------
     YEAR
     --------------------------------------------------------- */
  function year() {
    $$("[data-year]").forEach(function (e) { e.textContent = new Date().getFullYear(); });
  }

  /* ---------------------------------------------------------
     BOOT
     --------------------------------------------------------- */
  function boot() {
    doc.body.classList.remove("no-js");
    i18n.init();
    heatlines();
    reveals();
    hero();
    nav();
    cursor();
    menuNav();
    if (!router()) hashLanding();   // the router does its own landing
    year();
    if (window.RGCarve) window.RGCarve.init();
  }

  if (doc.readyState === "loading") doc.addEventListener("DOMContentLoaded", boot);
  else boot();

  window.RG = { i18n: i18n, $: $, $$: $$, still: still,
    sweep: function () { if (window.__rgSweep) window.__rgSweep(); } };
})();
