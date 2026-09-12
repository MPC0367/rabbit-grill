/* ============================================================
   THE CARVING BOARD  —  Rabbit Grill signature interaction

   Their prime rib is not priced per plate. It is priced per
   100 g off the counter — 490 THB / 100 g, straight from their
   own menu. So the interaction is the ordering decision itself:
   drag along the joint to say how much of it you are taking,
   and watch the weight and the bill move together.

   Their own caption for it: "ตัดทำได้หมด" — we will cut it
   however you like.

   The rib is their photograph. The arithmetic is their price.
   Nothing here is invented, and nothing is a 3-D model.
   ============================================================ */
(function () {
  "use strict";

  var SRC_W = 1800, SRC_H = 1118;   // img/primerib-board.jpg
  var LINE_X0 = 250, LINE_X1 = 1545;// the cut line at 0 g and at the full joint
  var MEAT_Y0 = 15, MEAT_Y1 = 1030;
  var LEAN = -290;                  // the slices run down and to the left in that frame
  var MAX = 12;                     // 12 x 100 g
  var GRAMS = 100;
  var BAHT = 490;                   // THB per 100 g — their menu price
  var START = 7;

  window.RGCarve = { init: init };

  function init() {
    var board = document.querySelector("[data-carve]");
    if (!board) return;
    var canvas = board.querySelector("canvas");
    if (!canvas) return;

    var out = {
      cuts: document.querySelector("[data-out=cuts]"),
      grams: document.querySelector("[data-out=grams]"),
      baht: document.querySelector("[data-out=baht]")
    };

    var ctx = canvas.getContext("2d");
    var still = (window.RG && window.RG.still) ||
                matchMedia("(prefers-reduced-motion: reduce)").matches ||
                document.documentElement.hasAttribute("data-shot");

    var img = new Image();
    var ready = false;
    var cuts = START;       // committed value
    var cf = START;         // eased value actually drawn
    var hover = -1;         // pointer position, source px, -1 = none
    var dragging = false;
    var raf = 0;
    var canFilter = typeof ctx.filter === "string";

    img.decoding = "async";
    img.src = (window.RG_IMG && window.RG_IMG["primerib-board"]) || "img/primerib-board.jpg";
    img.onload = function () { ready = true; resize(); readout(true); };
    img.onerror = function () { board.classList.add("is-failed"); };

    /* ---------------- sizing ---------------- */
    function resize() {
      var w = board.clientWidth;
      if (!w) return;
      var dpr = Math.min(window.devicePixelRatio || 1, 2);
      var h = w * SRC_H / SRC_W;
      canvas.style.width = w + "px";
      canvas.style.height = h + "px";
      canvas.width = Math.round(w * dpr);
      canvas.height = Math.round(h * dpr);
      var s = (w * dpr) / SRC_W;
      ctx.setTransform(s, 0, 0, s, 0, 0);   // from here on we draw in source pixels
      paint();
    }

    /* ---------------- geometry ---------------- */
    function lineTop(v) { return LINE_X0 + (v / MAX) * (LINE_X1 - LINE_X0); }
    function lineBot(v) { return lineTop(v) + LEAN; }

    /* the wedge to the right of the cut — the part you are leaving behind */
    function pathRight(v) {
      ctx.beginPath();
      ctx.moveTo(lineTop(v), -300);
      ctx.lineTo(SRC_W + 400, -300);
      ctx.lineTo(SRC_W + 400, SRC_H + 300);
      ctx.lineTo(lineBot(v), SRC_H + 300);
      ctx.closePath();
    }

    /* ---------------- painting ---------------- */
    function paint() {
      if (!ready) return;
      ctx.clearRect(0, 0, SRC_W, SRC_H);
      ctx.drawImage(img, 0, 0, SRC_W, SRC_H);

      // everything past the cut recedes: cooler, darker, out of the order
      if (cf < MAX - 0.01) {
        ctx.save();
        pathRight(cf);
        ctx.clip();
        if (canFilter) {
          ctx.filter = "grayscale(.62) brightness(.52) contrast(.95)";
          ctx.drawImage(img, 0, 0, SRC_W, SRC_H);
          ctx.filter = "none";
        } else {
          ctx.fillStyle = "rgba(14,11,7,.58)";
          ctx.fillRect(0, 0, SRC_W, SRC_H);
        }
        ctx.restore();
      }

      if (cf > 0.01) drawCut(cf);
      drawBracket(cf);
      if (hover >= 0 && !still && !dragging) drawHover(hover);
    }

    function drawCut(v) {
      var xT = lineTop(v), xB = lineBot(v);
      ctx.save();
      ctx.lineCap = "round";

      // shadow falling into the gap the knife opened
      ctx.strokeStyle = "rgba(8,5,2,.85)";
      ctx.lineWidth = 22;
      if (canFilter) ctx.filter = "blur(8px)";
      ctx.beginPath(); ctx.moveTo(xT + 8, MEAT_Y0); ctx.lineTo(xB + 8, MEAT_Y1); ctx.stroke();
      if (canFilter) ctx.filter = "none";

      // the cut face, lit
      var g = ctx.createLinearGradient(0, MEAT_Y0, 0, MEAT_Y1);
      g.addColorStop(0, "rgba(255,190,132,0)");
      g.addColorStop(0.10, "rgba(255,190,132,.85)");
      g.addColorStop(0.85, "rgba(242,150,96,.65)");
      g.addColorStop(1, "rgba(255,190,132,0)");
      ctx.strokeStyle = g;
      ctx.lineWidth = 3.5;
      ctx.beginPath(); ctx.moveTo(xT, MEAT_Y0); ctx.lineTo(xB, MEAT_Y1); ctx.stroke();
      ctx.restore();
    }

    /* a butcher measure across the portion being taken */
    function drawBracket(v) {
      var y = 74;
      var x0 = 92, x1 = lineTop(v);
      ctx.save();
      ctx.strokeStyle = "rgba(194,86,42,.96)";
      ctx.fillStyle = "rgba(194,86,42,.96)";
      ctx.lineWidth = 3;
      ctx.lineCap = "butt";

      ctx.beginPath();
      ctx.moveTo(x0, y); ctx.lineTo(Math.max(x0, x1), y);
      ctx.moveTo(x0, y - 13); ctx.lineTo(x0, y + 13);
      ctx.moveTo(x1, y - 13); ctx.lineTo(x1, y + 13);
      ctx.stroke();

      var g = Math.round(v * GRAMS / 10) * 10;
      var label = g + " g";
      ctx.font = '600 42px Oswald, "Arial Narrow", sans-serif';
      ctx.textBaseline = "middle";
      var w = ctx.measureText(label).width;
      var lx = Math.max(x0 + 16, x1 + 22);
      if (lx + w > SRC_W - 40) lx = x1 - w - 22;

      ctx.fillStyle = "rgba(12,9,5,.72)";
      ctx.fillRect(lx - 10, y - 26, w + 20, 52);
      ctx.fillStyle = "#F3ECDD";
      ctx.fillText(label, lx, y + 1);
      ctx.restore();
    }

    function drawHover(x) {
      var v = valueAt(x);
      var xT = lineTop(v), xB = lineBot(v);
      ctx.save();
      ctx.globalAlpha = 0.62;
      ctx.strokeStyle = "rgba(243,236,221,.9)";
      ctx.lineWidth = 2;
      ctx.setLineDash([10, 10]);
      ctx.beginPath(); ctx.moveTo(xT, MEAT_Y0 - 30); ctx.lineTo(xB, MEAT_Y1 + 30); ctx.stroke();
      ctx.restore();
    }

    /* ---------------- easing ---------------- */
    function tick() {
      var d = cuts - cf;
      if (Math.abs(d) < 0.012) { cf = cuts; paint(); raf = 0; return; }
      cf += d * 0.22;
      paint();
      raf = requestAnimationFrame(tick);
    }
    function nudge() {
      if (still) { cf = cuts; paint(); return; }
      if (!raf) raf = requestAnimationFrame(tick);
    }

    /* ---------------- readout ---------------- */
    var shown = { cuts: START, grams: START * GRAMS, baht: START * BAHT };
    var rraf = 0;
    function paintOut() {
      if (out.cuts) out.cuts.textContent = Math.round(shown.cuts);
      if (out.grams) out.grams.firstChild.nodeValue = String(Math.round(shown.grams / 10) * 10);
      if (out.baht) out.baht.firstChild.nodeValue = Math.round(shown.baht).toLocaleString("en-US");
    }
    function readout(instant) {
      var want = { cuts: cuts, grams: cuts * GRAMS, baht: cuts * BAHT };
      if (instant || still) { shown = want; paintOut(); return; }
      cancelAnimationFrame(rraf);
      (function step() {
        var done = true;
        ["cuts", "grams", "baht"].forEach(function (k) {
          var diff = want[k] - shown[k];
          if (Math.abs(diff) < 0.6) shown[k] = want[k];
          else { shown[k] += diff * 0.24; done = false; }
        });
        paintOut();
        if (!done) rraf = requestAnimationFrame(step);
      })();
    }

    function set(n, used) {
      n = Math.max(0, Math.min(MAX, n));
      if (used) board.classList.add("is-used");
      if (n === cuts) return;
      cuts = n;
      nudge(); readout(); aria();
    }

    /* ---------------- input ---------------- */
    /* the whole board width is live, so the gesture never hits a dead edge */
    var DRAG_X0 = 200, DRAG_X1 = 1640;
    function srcX(e) {
      var r = board.getBoundingClientRect();
      return ((e.clientX - r.left) / r.width) * SRC_W;
    }
    function valueAt(x) {
      var t = (x - DRAG_X0) / (DRAG_X1 - DRAG_X0);
      return Math.round(Math.max(0, Math.min(1, t)) * MAX);
    }

    board.addEventListener("pointerdown", function (e) {
      if (!ready) return;
      dragging = true;
      if (board.setPointerCapture) board.setPointerCapture(e.pointerId);
      set(valueAt(srcX(e)), true);
      e.preventDefault();
    });
    board.addEventListener("pointermove", function (e) {
      if (!ready) return;
      var px = srcX(e);
      if (dragging) { set(valueAt(px), true); }
      else { hover = px; if (!still) paint(); }
    });
    function end() { dragging = false; hover = -1; paint(); }
    board.addEventListener("pointerup", end);
    board.addEventListener("pointercancel", end);
    board.addEventListener("pointerleave", function () { if (!dragging) { hover = -1; paint(); } });

    /* the board is a real slider for keyboard and assistive tech */
    board.setAttribute("role", "slider");
    board.setAttribute("tabindex", "0");
    board.setAttribute("aria-valuemin", "0");
    board.setAttribute("aria-valuemax", String(MAX * GRAMS));
    function aria() {
      board.setAttribute("aria-valuenow", String(cuts * GRAMS));
      board.setAttribute("aria-valuetext",
        cuts * GRAMS + " grams, " + (cuts * BAHT).toLocaleString("en-US") + " baht");
    }
    aria();
    board.addEventListener("keydown", function (e) {
      var k = e.key;
      if (k === "ArrowRight" || k === "ArrowUp") { set(cuts + 1, true); e.preventDefault(); }
      else if (k === "ArrowLeft" || k === "ArrowDown") { set(cuts - 1, true); e.preventDefault(); }
      else if (k === "Home") { set(0, true); e.preventDefault(); }
      else if (k === "End") { set(MAX, true); e.preventDefault(); }
    });

    var less = document.querySelector("[data-carve-less]");
    var more = document.querySelector("[data-carve-more]");
    if (less) less.addEventListener("click", function () { set(cuts - 1, true); });
    if (more) more.addEventListener("click", function () { set(cuts + 1, true); });

    if (window.ResizeObserver) new ResizeObserver(resize).observe(board);
    else addEventListener("resize", resize);

    // the bracket label is set in Oswald; repaint once the webfont lands
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(function () { paint(); });

    resize();
  }
})();
