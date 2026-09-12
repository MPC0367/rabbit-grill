/* ============================================================
   THE MENU, MADE LOOKABLE

   Desktop  — point at a dish and its photograph rises next to
              the cursor. One shared <figure>, one image in
              flight at a time, so a 39-row menu costs nothing
              until you actually go looking.

   Mobile   — you cannot hover, so the menu reads itself to you:
              whichever row is nearest the middle of the screen
              takes the spotlight and opens its own photograph
              underneath. Scroll and the light moves with you.

   Both paths share one hook: data-img on the <li>. Pictures are
   fetched the first time a row is lit and then cached.
   ============================================================ */
(function () {
  "use strict";

  var doc = document;
  var reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  var shot = doc.documentElement.hasAttribute("data-shot");

  function rows() {
    return Array.prototype.slice.call(doc.querySelectorAll(".mrow[data-img]"));
  }

  /* The path is derived, not stored, so the markup stays small. In the
     single-file artifact build there are no files to fetch, so the same
     name is looked up in the inlined data-URI map first. */
  function src(row) {
    var n = row.dataset.img;
    return (window.RG_IMG && window.RG_IMG[n]) || ("img/" + n + ".jpg");
  }

  var cache = Object.create(null);
  function preload(row) {
    var s = src(row);
    if (cache[s]) return cache[s];
    var i = new Image();
    i.decoding = "async";
    i.src = s;
    cache[s] = i;
    return i;
  }

  /* =========================================================
     DESKTOP — the hover plate
     ========================================================= */
  function hoverPlate(list) {
    var fig = doc.createElement("figure");
    fig.className = "dishpop";
    fig.setAttribute("aria-hidden", "true");
    fig.innerHTML = '<span class="dishpop__frame"><img alt="" src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7"></span><figcaption></figcaption>';
    doc.body.appendChild(fig);

    var img = fig.querySelector("img");
    var cap = fig.querySelector("figcaption");
    var current = null;
    var tx = 0, ty = 0, x = 0, y = 0, raf = 0, live = false;

    function loop() {
      x += (tx - x) * 0.18;
      y += (ty - y) * 0.18;
      fig.style.transform = "translate3d(" + Math.round(x) + "px," + Math.round(y) + "px,0)";
      raf = live ? requestAnimationFrame(loop) : 0;
    }

    function place(e) {
      var w = fig.offsetWidth || 300;
      var h = fig.offsetHeight || 240;
      var pad = 18;

      // the price is the thing you are reading while you point, so treat the
      // price cell's left edge as a wall the plate is not allowed to cross
      var priceEl = current && current.querySelector(".mrow__p");
      var wall = priceEl ? priceEl.getBoundingClientRect().left - 16 : innerWidth - pad;

      var left = e.clientX + pad;
      if (left + w > wall) left = e.clientX - w - pad;      // flip to the left
      if (left < pad) left = Math.max(pad, wall - w);       // no room either side

      var top = e.clientY - h / 2;
      top = Math.max(pad + 56, Math.min(top, innerHeight - h - pad));
      tx = left; ty = top;
    }

    list.forEach(function (row) {
      row.addEventListener("pointerenter", function (e) {
        if (e.pointerType && e.pointerType !== "mouse") return;
        current = row;
        preload(row);
        img.src = src(row);
        cap.textContent = row.dataset.name || "";
        place(e);
        // jump to position on first show, then ease
        x = tx; y = ty;
        fig.style.transform = "translate3d(" + x + "px," + y + "px,0)";
        fig.classList.add("is-on");
        row.classList.add("is-lit");
        if (!live) { live = true; raf = requestAnimationFrame(loop); }
      });
      row.addEventListener("pointermove", function (e) {
        if (current === row) place(e);
      });
      row.addEventListener("pointerleave", function () {
        if (current !== row) return;
        current = null;
        fig.classList.remove("is-on");
        row.classList.remove("is-lit");
        live = false;
        cancelAnimationFrame(raf); raf = 0;
      });

      /* keyboard users get the same picture, anchored to the row */
      row.setAttribute("tabindex", "0");
      row.addEventListener("focus", function () {
        var r = row.getBoundingClientRect();
        preload(row);
        img.src = src(row);
        cap.textContent = row.dataset.name || "";
        var w = fig.offsetWidth || 300, h = fig.offsetHeight || 240;
        tx = x = Math.min(r.right + 18, innerWidth - w - 18);
        ty = y = Math.max(74, Math.min(r.top - h / 3, innerHeight - h - 18));
        fig.style.transform = "translate3d(" + x + "px," + y + "px,0)";
        fig.classList.add("is-on");
        row.classList.add("is-lit");
      });
      row.addEventListener("blur", function () {
        fig.classList.remove("is-on");
        row.classList.remove("is-lit");
      });
    });
  }

  /* =========================================================
     MOBILE — the spotlight follows the scroll
     ========================================================= */
  function spotlight(list) {
    var lit = null;
    var ticking = false;

    function open(row) {
      if (row === lit) return;
      if (lit) {
        lit.classList.remove("is-spot");
        var old = lit.querySelector(".mrow__shot");
        if (old) old.classList.remove("is-open");
      }
      lit = row;
      if (!row) return;
      row.classList.add("is-spot");

      var shotEl = row.querySelector(".mrow__shot");
      if (!shotEl) {
        shotEl = doc.createElement("span");
        shotEl.className = "mrow__shot";
        var im = doc.createElement("img");
        im.alt = "";
        im.loading = "lazy";
        im.decoding = "async";
        im.src = src(row);
        shotEl.appendChild(im);
        row.appendChild(shotEl);
      }
      // next frame so the height transition has a start value
      requestAnimationFrame(function () { shotEl.classList.add("is-open"); });
    }

    function pick() {
      ticking = false;
      var mid = innerHeight * 0.46;
      var best = null, bestD = 1e9;
      for (var i = 0; i < list.length; i++) {
        var r = list[i].getBoundingClientRect();
        if (r.bottom < 90 || r.top > innerHeight - 60) continue;
        var d = Math.abs(r.top + r.height / 2 - mid);
        if (d < bestD) { bestD = d; best = list[i]; }
      }
      open(best);
    }

    function onScroll() {
      if (!ticking) { ticking = true; requestAnimationFrame(pick); }
    }

    addEventListener("scroll", onScroll, { passive: true });
    addEventListener("resize", onScroll);
    pick();

    return { destroy: function () {
      removeEventListener("scroll", onScroll);
      removeEventListener("resize", onScroll);
      open(null);
    } };
  }

  /* =========================================================
     BOOT — pick the right behaviour, and switch if the device does
     ========================================================= */
  function boot() {
    var list = rows();
    if (!list.length) return;

    var canHover = matchMedia("(hover: hover) and (pointer: fine)").matches;
    var wide = matchMedia("(min-width: 861px)").matches;

    if (shot) {
      // QA settle mode: light one row so the interaction shows up in a still.
      // Headless capture cannot hover, so both states are staged by hand.
      var target = list[1] || list[0];
      target.classList.add("is-lit", "is-spot");

      if (wide && canHover) {
        var r = target.getBoundingClientRect();
        var fig = doc.createElement("figure");
        fig.className = "dishpop is-on";
        fig.innerHTML = '<span class="dishpop__frame"><img alt="" src="' + src(target) +
                        '"></span><figcaption>' + (target.dataset.name || "") + "</figcaption>";
        doc.body.appendChild(fig);
        fig.style.transform = "translate3d(" +
          Math.round(Math.min(r.right + 40, innerWidth - 380)) + "px," +
          Math.round(Math.max(90, r.top - 40)) + "px,0)";
      } else {
        var s = doc.createElement("span");
        s.className = "mrow__shot is-open";
        s.innerHTML = '<img alt="" src="' + src(target) + '">';
        target.appendChild(s);
      }
      return;
    }

    if (canHover && wide) hoverPlate(list);
    else if (!reduce) spotlight(list);
    else {
      // reduced motion on a touch device: show every picture, no movement
      list.forEach(function (row) {
        var s = doc.createElement("span");
        s.className = "mrow__shot is-open";
        s.innerHTML = '<img alt="" loading="lazy" src="' + src(row) + '">';
        row.appendChild(s);
        row.classList.add("is-spot");
      });
    }
  }

  if (doc.readyState === "loading") doc.addEventListener("DOMContentLoaded", boot);
  else boot();
})();
