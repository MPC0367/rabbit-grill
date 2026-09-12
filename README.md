# Rabbit Grill Khao Yai — website

**โรงย่างเนื้อ เขาใหญ่** · 339 Moo 11, Nong Nam Daeng, Pak Chong, Nakhon Ratchasima

Static, dependency-free, bilingual EN/ไทย. Four pages. Built 2026-08-29.

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File serve.ps1
```
→ http://localhost:8333 (also registered as `rabbit-grill` in `NOVA/.claude/launch.json`)

---

## The idea

**Fire does the cooking. You choose the cut.**

Rabbit Grill call themselves *โรงย่างเนื้อสไตล์ Fire Cooking* — a fire-cooking
grill house — on their own Instagram bio and menu cover. The site is built the
way their printed menu is built: **cream paper bands interrupted by full-bleed
fire**. That alternation is the art direction, and it comes straight from their
own artwork rather than from a steakhouse mood board.

### Signature interaction — the carving board (`js/carve.js`)

Their prime rib is not priced per plate. It is **490 THB per 100 g**, off the
counter. So the signature interaction is the ordering decision itself: drag
along the joint, and the portion you are taking stays lit while the rest
recedes, with weight and price climbing together. Their own caption for it is
*"ตัดทำได้หมด"* — we will cut it however you like.

Real photograph, real arithmetic, no 3-D meat. It is a genuine ordering tool as
much as a piece of motion: a table can work out what 800 g actually costs
before they get in the car.

It is a proper `role="slider"` — arrow keys, Home/End, and ± buttons all drive
it, and `prefers-reduced-motion` renders it statically.

### Recurring device — the heat line

A thin rule that starts as rigid parallel grill bars and breaks into drift, or
reverses depending on which way through the page you are. Drawn on scroll via
`stroke-dashoffset`. Used at section transitions only.

---

## Content policy — read this before editing

Everything on this site traces to a source. `doc/RESEARCH.md` records every fact
and where it came from. **The site does not claim anything that could not be
verified**, and three things are deliberately withheld:

> **Updated in the second pass.** Two of the three items below were resolved —
> see the second-pass section at the foot of this file. Only the pet policy is
> still withheld.

| Item | Status |
|---|---|
| **Pet policy** | **Still withheld.** The brief described an air-conditioned pet area from customer reports. Checked twice, across Instagram, the whole Facebook set, Wongnai, the short-video reviews and Google's 33 user photos: no dog appears anywhere and no policy is stated on any surface. **No policy is published.** The section asks the visitor to ring instead — true, useful, and invents nothing. |
| **Hours** | **Resolved.** Closed Wednesdays, from the restaurant's own Facebook notice. 11:00–21:00, from their Google and Wongnai listings — attributed as third-party in the copy. `openingHoursSpecification` is now emitted. |
| **Map coordinates** | **Resolved.** 14.6303212, 101.4045925, read off their own Google Business listing and verified in a browser. `geo` and `hasMap` are now emitted, and every map button points at the listing by CID. |
| **Google rating** | 4.5 from 58 reviews, verified. Shown as an attributed, linked fact and deliberately **not** marked up as `aggregateRating`. |

Other things this site does **not** say, because nothing supports them: awards,
Michelin, dry-aging, beef provenance beyond the menu's own wording, suppliers,
ratings, review counts, testimonials, reservations, parking, opening date, or
any ownership link to Rosebay Homecooking Cafe (adjacency is stated as a
landmark only, with the non-affiliation spelled out).

The chef line is real but is **rendered as an attributed quote** — it is their
own Facebook announcement of 23 April 2026, not independently verified
biography.

### To publish the withheld items

Edit `data/site.json` only:
- `hours.verified: true` + fill the schedule → then add `openingHours` to the JSON-LD in `index.html` and `visit.html`.
- `pets.verified: true` + fill species / size / zones / leash / air-conditioning → then replace the ask-module copy in `index.html` and `visit.html`.
- `address.coords_verified: true` + add lat/long → then add `geo` to the JSON-LD.

---

## Where the content lives

| File | Holds |
|---|---|
| `data/menu.json` | **Single source of truth for the menu.** 39 dishes + 38 drinks, all with Thai names and real prices. |
| `data/site.json` | Hours, contact, address, socials, pet policy, chef claim, announcement bar, reservations. Every entry carries a `verified` flag and a `_source` or `_note`. |
| `doc/RESEARCH.md` | Provenance for every fact on the site. |
| `doc/menu-food.pdf`, `menu-beverage.pdf`, `menu-avocado.jpg` | Their own menu cards, pulled from the Google Drive links in their Instagram linktree. |

### Rebuilding the menu page

`menu.html` is **generated** from `data/menu.json` between HTML markers, so the
prices are real static markup for search engines and for anyone with JavaScript
off, while still living in one editable file:

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File _qa/build.ps1
```

`_qa/build.ps1` **must stay UTF-8 with BOM** or PowerShell 5.1 mangles every
Thai string inside it.

---

## Photography

All 42 dish photographs are **theirs**, carved out of their own menu PDFs. Each
PDF page is a single embedded JPEG, so the pages were extracted byte-wise into
`doc/pages/*.jpg` and the individual plates cropped from those.

> **The menu artwork has a handwritten dish name and price sitting in a corner of
> nearly every photograph.** Those duplicate the site's own typography and read
> as artifacts, so every rectangle in `_qa/extract-images.ps1` is tuned to crop
> *inside* the label. If you re-cut them, check the contact sheet first.

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File _qa/extract-images.ps1   # re-cut
powershell -NoProfile -ExecutionPolicy Bypass -File _qa/contact.ps1          # -> _qa/contact.png
```

No stock photography is used anywhere. Nothing is AI-generated.

---

## Bilingual

English lives in the markup. Thai lives in `data-th` attributes. On load the
English is captured off the DOM once (`js/app.js` → `i18n`), so the two
languages **cannot drift apart** — there is only ever one copy of the English.

- Toggle in the nav, remembered in `localStorage` (wrapped in try/catch — private windows throw).
- `?lang=th` makes a Thai link shareable and gives QA a stable entry point.
- Thai display type gets its own size ramp and leading (`:lang(th) .dsp`), or the tone marks collide with the tight Latin leading.

---

## Type & palette

Read off their own printed menu, not invented:

| Token | Value | Where it comes from |
|---|---|---|
| `--paper` | `#F3ECDD` | menu card ground |
| `--ink` | `#17150F` | their food photography, not pure black |
| `--forest` | `#1E4230` | the wordmark on the menu cover |
| `--oxblood` | `#6E1621` | the wordmark variant + "NEW SEASONAL" badge |
| `--taupe` | `#6B5E4B` | the category chips |
| `--ember` | `#CB6234` | the coals |

**Three families, three jobs** — down from four.

- **Cormorant Garamond** — the identity, because their wordmark is a fine serif. Wordmark upright; italic carries dish names, pull quotes and captions.
- **Oswald** — the voice, because their drinks menu is set in condensed caps. Headlines, labels, prices, buttons.
- **Noto Sans Thai** — everything you actually read, and all Thai.

A fourth face (Architects Daughter, a script standing in for the handwritten dish
names on the printed menu) was cut. It was a family too many, and being Latin-only
it made a second problem worse: **none of the Latin faces carry Thai glyphs** —
measured, all three render Thai at exactly the generic-fallback width — so every
Thai headline and caption was dropping to an uncontrolled system font instead of
the one Thai face the page loads. `"Noto Sans Thai"` now sits inside the `--serif`
and `--disp` stacks so Thai resolves to it in every role.

Nine real faces, and **no synthetic weights**: an `<h3>` inherits 700, which is not
a weight we load, so `.dish__name` sets 600 explicitly and the italic 600 is
requested. Worth re-checking after any type change — a faux bold on a
high-contrast serif is very visible.

Every colour pair on the site passes **WCAG AA for normal text** (verified; the
lowest is 4.55:1). `--ember-ink` exists because the ember accent needs darkening
for small text on paper, and the fill ember needed lightening to clear 4.5:1
against the ink text sitting on it.

---

## QA harness

The in-app browser pane will not reliably composite a scrolled page (and it
freezes CSS transitions when hidden — a `getComputedStyle` reading of a
mid-transition property there is an artifact, not a bug). Screenshots use
headless Edge instead:

```bash
powershell -File _qa/shot.ps1  -Page index.html -Target carve -Name x -Off -40 -Lang th
powershell -File _qa/mshot.ps1 -Page index.html -Target top   -Sheet          # 390px
```

`?shot=<id>` is a settle mode in `js/shot.js`: it zeroes transitions, reveals
everything, and **shifts the document with `margin-top` rather than scrolling**
(programmatic `scrollTo` yields an unrasterised background). It re-applies on
`resize`, which is mandatory — headless Edge lays out at a shorter viewport
during load and only resizes to the real window just before rasterising, so
every `vh` height grows and any offset computed at load lands short.

Mobile shots go through `_qa/mobile.html`, an iframe wrapper, because headless
Edge silently clamps its own window to ~492px wide.

Shots land in `_qa/shots/`.

### Verified

- No horizontal overflow at 375 / 390 / 430 / 768 / 1024 / 1366 / 1920 on all four pages
- No console errors on any page
- No broken links, no broken images, no missing `alt`, no duplicate `id`s
- Carve interaction correct via drag, arrow keys, Home/End and ± buttons
- Mobile sheet opens/closes, locks body scroll, moves focus, closes on Escape
- Every colour pair passes WCAG AA

---

## Known gaps

1. **No photography of the restaurant itself.** No exterior, interior, chef,
   guests, or Khao Yai landscape exists in any accessible source. Rather than
   use stock, the "place" band is deliberately typographic. A single real shoot
   would materially improve the site — exterior at golden hour, the grill in
   use, a full table, and the pet-friendly area if it exists.
2. **No reviews.** Their Facebook shows "Not yet rated (0 reviews)". Nothing is
   fabricated to fill the gap.
3. **Menu spelling.** Three unambiguous typos on their card are corrected on the
   site and recorded in `doc/RESEARCH.md`: *APPERTIZER* → Appetizers,
   *Australalain* → Australian, *Creme Brulee Lamon* → Crème Brûlée Lemon. Their
   "Sauteed" spelling is kept as-is.
4. **Domain.** Canonical URLs and OG images point at `rabbitgrillkhaoyai.com`,
   which is a placeholder — change it before launch.

---

# Second pass — venue photography, a lookable menu, and the artifact

## The menu is now the interaction

`js/dishpop.js` + the `.mrow[data-img]` hook that `_qa/build.ps1` emits.

- **Desktop** — point at a dish and its photograph rises beside the cursor. One
  shared `<figure>`, one image in flight, so a 39-row menu costs nothing until you
  go looking. The plate treats the price cell's left edge as a wall it will not
  cross, because the price is the thing you are reading while you point. Keyboard
  focus gets the same picture, anchored to the row.
- **Mobile** — you cannot hover, so the menu reads itself to you: whichever row is
  nearest the middle of the screen takes the spotlight, opens its own photograph
  underneath, and hands the light on as you scroll.
- **Reduced motion on touch** — every picture is simply shown, nothing moves.

## Real photographs of the place

The first build had none, and said so. It now has eleven, all harvested from the
restaurant's own Facebook page at full resolution — the building at night, the
open kitchen with guests sitting at it, the pass on a busy night, a cook at work,
and actual fire on the grate. See `doc/RESEARCH.md` for the harvesting recipe;
`_qa/fetch-fb-photos.ps1` holds the URLs and `_qa/extract-venue.ps1` the crops.

This is what changed the feel of the site. The room band, the full-bleed fire, the
place band and the pet module are all built on them, and the page reads as a busy
neighbourhood grill rather than a quiet steakhouse.

## Hours, finally

**Closed Wednesdays** — the restaurant's own Facebook notice. **11:00–21:00** —
their Google and Wongnai listings, which the copy attributes rather than claiming.
`openingHoursSpecification` and verified `geo` are now in the JSON-LD.

**4.5 from 58 Google reviews** is shown as an attributed, linked fact, and is
deliberately *not* marked up as `aggregateRating` — a business marking up its own
third-party score is what search engines penalise.

## The shareable artifact

```bash
powershell -NoProfile -ExecutionPolicy Bypass -File _qa/build-artifact.ps1
```

Folds the four pages into one self-contained document — `index` chrome plus
`#menu`, `#fire`, `#visit` — inlines both stylesheets, all three scripts, and every
photograph, then rewrites the cross-page links to in-page anchors and drops the
duplicate nav / sheet / footer / action bar / JSON-LD the inner pages carried in.

**Each image blob is stored exactly once**, in `window.RG_IMG`, and the markup
carries only `data-img-src="name"` plus a 1×1 placeholder that a hydrate pass
fills in. Pasting the data URI at every `<img src>` instead produced a 14.5 MB
file, because several photographs appear three or four times across the merged
pages; storing each once brings it to 8.5 MB against a 16 MB ceiling. `carve.js`
and `dishpop.js` both resolve names through `RG_IMG` first and fall back to
`img/name.jpg`, so the same source runs as four pages or as one file.

Published at https://claude.ai/code/artifact/62bf37a0-4955-4880-b494-98ae1ae180de
(private until shared from the page's own share menu).

## What the artifact does NOT carry

`js/shot.js`, the QA settle mode. It is stripped at build time — the harness is for
the local four-page site only.

## Still open

- **No pet policy anywhere.** Confirmed a second time across Google's 33 user
  photos, the whole Facebook set, Instagram and the short-video reviews: no dog
  appears and no policy is stated. The ask-first module stands.
- **Two untapped photo sources**, both listed in `doc/RESEARCH.md`: a 28-photo
  blogger album on Facebook, and Google's own 33 user photos (which include a
  dry-age display fridge and a frame showing the Rabbit Grill and Rosebay
  buildings together).
- **Domain** is still the `rabbitgrillkhaoyai.com` placeholder.

---

# Fix — the reveal system was hiding photographs

**Symptom:** dish photographs never appeared; the text beside them did.

**Cause:** every reveal on the site was gated on an `IntersectionObserver`.
IO delivers its callbacks as part of the browser's rendering lifecycle, so in any
context that is not painting normally — an embedded viewer, a backgrounded frame,
a throttled tab — it can deliver **nothing at all**, not even the initial report
for an element filling the viewport. Verified directly: observing `.hero` while it
occupied the whole viewport produced zero callbacks. Anything gated on it then sits
at `opacity: 0`, or `clip-path: inset(0 0 100% 0)` for the `mask` variant, forever.
For a page whose entire job is showing food, that is the worst possible failure.

**Fix (`js/app.js` → `reveals()`):** reveals are now *measured*, not observed.
`getBoundingClientRect()` always tells the truth, so we ask it, on a rAF-throttled
sweep. Three ways in, so nothing can be stranded:

1. sweep on `scroll` / `resize` — the normal progressive path;
2. sweep at init, on `load`, and once the webfonts settle;
3. a 2.5 s backstop that opens everything **if no scroll signal ever arrives** —
   which is what happens when the page is embedded and an outer document does the
   scrolling. `wheel` and `touchmove` also count as signals, since they fire even
   when the inner document is not the thing scrolling.

Anyone who scrolls inside the window keeps the full progressive reveal.

**Also fixed while in there**

- `html { scroll-behavior: smooth }` across the artifact's ~32,000 px single page
  made every section jump an interminable animated crawl. The artifact build now
  overrides it to `auto`; the four-page site keeps smooth scrolling, where the
  distances are short.
- Landing on a `#section` happens before the webfonts swap, so the target has
  moved by the time the page settles. `hashLanding()` re-lands after `load` and
  after `fonts.ready` — and **surrenders on the first wheel / touch / keypress**,
  because being yanked back to a heading you have already scrolled past is worse
  than landing slightly off.

**Verified after the fix:** artifact 141/141 reveals, 11/11 line-headings, 3/3
heat lines all open (previously 0/141); menu 16/16, fire 31/31, visit 30/30; no
broken images, nothing unhydrated, no console errors on any page.

> **QA note.** Two failure modes in this harness look exactly like site bugs and
> are not: the Browser pane freezes CSS transitions and never delivers
> IntersectionObserver callbacks when it is not compositing, and headless Edge
> returns a background-only PNG after any programmatic scroll. Confirm a suspected
> bug in a second context before fixing it — and confirm a fix by inspecting
> *classes*, which are truthful, rather than computed transition values, which are not.

---

# Design review pass — a graphic designer read it, and was right

Six notes came back. All six are addressed.

### 1. "Hard to understand what this is about or where to navigate"

Added **wayfinding** (`.ways`) directly under the hero: three doors — Menu, The
Fire, Visit — each an image with a one-line description. A first-time visitor now
sees what is here and where to go without scrolling to find out.

### 2. "Pages could be separated through the nav instead of scrolling back and forth"

The sharpest note, and it was about the **artifact**, where the four pages had been
folded into ~32,000px of continuous scroll with the nav jumping you around inside it.

The artifact now behaves like the real site: `js/app.js` → `router()`, active only
under `body[data-spa]`, shows **one `.page` at a time**. The nav switches, scroll
resets to the top, `aria-current` follows, and deep links (`#beef`, `#directions`)
resolve to their owning page via `closest('.page')`. The four-page site is
untouched — same source, two behaviours.

### 3. "Too many fonts — limit to 3. Especially the 01 The idea page"

Already down to three families in the previous pass, but *The idea* still stacked
five different treatments in one column. Removed the italic Thai line that
duplicated the eyebrow, so the section is now eyebrow → headline → lede → quote —
which is what the reviewer said actually held together. The right column also went
from two small tiles to one tall photograph, which fixed the imbalance beside it.

### 4. "Format is not consistent between the chapters"

There were **three different section-header arrangements** across the pages. There
is now one component, `.shead`, used by every section on every page, with an
optional `.shead--split` for sections that carry a supporting line. Same eyebrow,
same rhythm, same margins.

### 5. "The number for section 04 and the chapter number are too similar"

A real collision, and worse than reported — the site had **three** numbering
systems in the same visual language: section eyebrows (01–08), the featured dish
items (01–04), and the menu category kickers (01–08). `fire.html` also had **two
sections both numbered 04**, and the menu jumped 01 → 09.

- Featured dish numerals: **removed.** Four picks are not a sequence, so they were
  encoding nothing.
- Menu category kickers: **removed** from the generator, for the same reason.
- Section numbers: kept, renumbered 01..n per page, and given a distinct treatment
  (ember rule + ember numeral) so they cannot be mistaken for anything inside a section.

### 6. "The Thai translation might be too direct instead of storytelling"

Correct. The tells were structural rather than vocabulary: `คือที่ทางของ` (a calque
of "is a place for"), `ถูก`+verb passives, `ส่วนหนึ่งของความสนุกคือ` translated word
for word, `จึงขอให้สอบถามโดยตรง` officialese, and Facebook/Instagram transliterated
where Thai brands leave them in Latin.

29 strings rewritten (`_qa/apply-thai.ps1`, which reports any line that fails to
land rather than failing silently). Examples:

| | before | after |
|---|---|---|
| The idea | ของอร่อย เกิดขึ้น รอบกองไฟ | เรื่องดี ๆ มักเริ่มต้น รอบกองไฟ |
| Cut to order | หั่นตามที่สั่ง | หั่นตามสั่ง |
| Into Khao Yai | เข้าสู่เขาใหญ่ | มุ่งหน้าเขาใหญ่ |
| With a dog? | ขับรถมา พร้อมน้องหมา? | พาน้องหมา มาด้วยไหม |
| No booking | ติดต่อทางโทรศัพท์ … เฟซบุ๊ก / อินสตาแกรม | โทรมาได้เลย … Facebook / Instagram |

**Every fact is unchanged** — 490 ฿ / 100 g, 11:00–21:00, ปิดวันพุธ, the address,
the Google/Wongnai sourcing caveat, 39 จาน. Their own lines *ตัดทำได้หมด* and
*ทุกเพศทุกวัย* are deliberately untouched.

> **Still worth a native copywriter's eye** on three judgement calls: whether
> `มุ่งหน้าเขาใหญ่` or the warmer `ขึ้นเขาใหญ่` sits better at display size; whether
> to restore `กี่ขีด` in the carve line (1 ขีด = 100 g, so it is factually
> consistent and very natural for buying meat by weight); and the deliberate
> distribution of `นั่งชิด` so it appears once rather than in three sections.

**Verified after:** artifact 116/116 reveals, three font families, no duplicate ids,
no broken images, no console errors, no horizontal overflow at 375/390/430/768/
1024/1366/1920 on all five documents, and the nav walk switches pages cleanly.

---

# Thai localisation audit — full site

Every user-facing Thai string was inventoried, scoped, rewritten page-by-page as
native Thai copywriting rather than translation, then edited for consistency.

**Scope: 267 Thai strings, 156 unique → 126 rewritable, 30 protected.**

The protected set is the point of the exercise as much as the rewrite. Never
reworded: every dish and drink name (they come off the restaurant's own menu card),
their quoted self-descriptions, and the address. `_qa/thai-scope.ps1` derives that
set from `data/menu.json` rather than a hand-list, so it stays correct as the menu
changes.

```bash
powershell -File _qa/thai-inventory.ps1    # -> _qa/thai-inventory.tsv   every string + its element
powershell -File _qa/thai-scope.ps1        # -> thai-rewritable.tsv / thai-protected.tsv
powershell -File _qa/apply-thai-audit.ps1  # applies _qa/thai-final.json, reports misses, guards facts
```

### What was wrong

The tells were structural, not vocabulary — English syntax wearing Thai words:

| pattern | example found | fixed to |
|---|---|---|
| calque of "is a place for" | `Rabbit Grill คือที่ทางของอาหารย่าง` | `Rabbit Grill เป็นร้านอาหารย่าง…` |
| `ถูก` + verb passive | `ถูกย่างด้วยไฟ` | `ย่างด้วยไฟ` |
| word-for-word connective | `ส่วนหนึ่งของความสนุกคือการได้ขับรถมา` | `สนุกตั้งแต่ทางมาแล้ว` |
| officialese | `จึงขอให้สอบถามโดยตรง` | `ถามมาตรง ๆ ดีกว่าเดา` |
| signage Thai | `เข้าสู่เขาใหญ่` | `มุ่งหน้าเขาใหญ่` |
| noun where a verb belongs | `เรื่องของเตาไฟ` (a button) | `อ่านเรื่องเตาไฟ` |
| literal CTA | `พาฉันไปที่นั่น` | `กดนำทางเลย` |
| transliterated brands | `เฟซบุ๊ก` / `อินสตาแกรม` | `Facebook` / `Instagram` |
| English em dash inside Thai | `คำของร้านเอง — อินสตาแกรม` | `คำของร้านเอง · Instagram` |

**28 strings changed. 98 were already right and were left alone** — the audit
returns `changed:false` with a reason rather than churning good copy.

### Consistency enforced

A glossary now governs repeated concepts: `คนคุมเตา` for the person at the grill
(was `คนย่าง` in one place), `คิดราคาตามน้ำหนัก` for weight pricing (was
`ขายเป็นน้ำหนัก`), `…ของร้านเอง` for every attribution, `มาจากหน้า Google กับ Wongnai`
for the hours source, and one shape for source captions:
`[whose words] · [platform] · [date]`.

CTAs now name their action and no two buttons to different places share a label:
`ดูเมนู` / `ดูเมนูทั้งหมด` / `ดูเมนูเนื้อทั้งหมด` by scope; `เส้นทาง` (nav) /
`เส้นทางไปร้าน` (hero) / `กดนำทางเลย` (module) / `เปิดใน Google Maps` (contact).

Pronouns were counted, not guessed: `คุณ` now appears **twice** site-wide, both as
`โต๊ะคุณ` where it earns warmth. `เรา` survives 8 times, each load-bearing.

### Strings that had no Thai at all

The audit also looked for the opposite failure — user-facing text with no `data-th`.
Most hits were correct (brand names, the email, dish names in English above their
Thai). Four were genuinely missing and now have Thai: the hero's
`Prime Rib · 490 ฿ / 100 g`, the `Scroll` cue, the drinks column headers
(`Hot`/`Iced`, `250 ml`/`500 ml` — now localisable from `menu.json` via
`colA_th`/`colB_th`), and the Facebook link label on Visit.

### A real bug this audit caught

`menu.html` began with the literal text `MISS  Ready to order?` **before the
`<!DOCTYPE>`** — which silently put the page into **quirks mode**.

Cause: in PowerShell, `Write-Output` inside a function becomes part of its *return
value*. An earlier helper logged `Write-Output "MISS …"` on a no-match and then
`return $Html`, so the caller received `@("MISS …", $html)` and wrote both to disk.
Diagnostics inside a function that returns a value must use `Write-Host`. Fixed at
the source in `_qa/add-thai-headings.ps1`, and the stray text removed.

### Verified after

All five documents in **standards mode** with a doctype · no horizontal overflow ·
no console errors · zero banned translation-Thai patterns · zero transliterated
brand names · zero English em dashes inside Thai · every price, time, weight,
count, address fragment and attribution hedge unchanged (guarded by
`apply-thai-audit.ps1`, which fails loudly rather than silently).

### Left for a native speaker

Three judgement calls, all flagged by the editor pass: whether `ครัวเปิด ตอนกำลังยุ่ง`
should be `ตอนไฟกำลังแรง`; whether Visit's softened `โทรเช็กอีกทีก็ดี` is firm enough
for a 200 km drive; and that `เนื้อ ไฟ เวลา` is one shared string across Home §05 and
The Fire's hero, so changing one changes both.
