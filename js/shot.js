/* ============================================================
   QA settle mode — ?shot=<id>  (and ?shot=top, ?shot=full)

   The in-app browser pane will not reliably composite a scrolled
   page, so screenshots are taken with headless Edge instead.
   Headless Edge has two habits that break naive capture:

   1. it lays the page out at a SHORTER viewport during load and
      only resizes to the real window immediately before raster,
      so every vh-based height grows and any offset computed at
      load lands short. Hence: re-apply on resize, idempotently.
   2. programmatic scrollTo yields an unrasterised background, so
      we shift the document with margin-top instead of scrolling.
   ============================================================ */
(function () {
  var q = new URLSearchParams(location.search);
  if (!q.has("shot")) return;

  var target = q.get("shot") || "top";
  var off = parseInt(q.get("off"), 10) || 0;
  var root = document.documentElement;

  root.setAttribute("data-shot", "");
  if (target === "full") root.classList.add("shot-full");

  function apply() {
    var body = document.body;
    if (!body) return;

    // idempotent: always reset the shift before measuring
    body.style.marginTop = "0px";

    var all = document.querySelectorAll("[data-reveal], .lines, .heatline, .hero, .bar");
    for (var i = 0; i < all.length; i++) {
      all[i].classList.add("is-in");
      if (all[i].classList.contains("hero")) all[i].classList.add("is-lit");
      if (all[i].classList.contains("bar")) all[i].classList.add("is-up");
    }
    if (q.has("sheet")) {
      var sh = document.querySelector(".sheet");
      if (sh) { sh.classList.add("is-open"); sh.setAttribute("aria-hidden", "false"); }
    }

    var nav = document.querySelector(".nav");
    if (nav && target !== "top" && target !== "full") nav.classList.add("is-solid");

    if (target === "top" || target === "full") return;

    var el = document.getElementById(target) || document.querySelector(target);
    if (!el) return;
    var top = el.getBoundingClientRect().top;   // margin is 0 right now
    body.style.marginTop = (-(top) + off) + "px";
  }

  apply();
  document.addEventListener("DOMContentLoaded", apply);
  window.addEventListener("load", apply);
  window.addEventListener("resize", apply);            // the mandatory one
  if (document.fonts && document.fonts.ready) document.fonts.ready.then(apply);
  window.__rgShot = apply;
})();
