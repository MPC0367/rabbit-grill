# Rabbit Grill Khao Yai — source research
Compiled 2026-08-29. Every line below traces to a named source. Anything not here is NOT verified.

## Identity
- Trading name: **Rabbit Grill Khao Yai**
- Thai descriptor: **โรงย่างเนื้อ** (on the staff apron, menu cover photo)
- IG bio (own words): `โรงย่างเนื้อสไตล์ Fire Cooking`
- FB intro (own words): `โรงย่างเนื้อแห่งเขาใหญ่ ที่ยึดความคลาสสิกของการย่างแบบดั้งเดิม คัดเฉพาะเนื้อคุณภาพดี ถูกย่างด้วยไฟอย่างพิถีพิถัน`
- Menu cover (own words, EN): "Rabbit Grill is a fire-grill restaurant that carefully selects quality ingredients and brings them to life through our style of fire cooking."

## Contact / place
- Address: 339 หมู่ 11 ตำบลหนองน้ำแดง, อ.ปากช่อง, จ.นครราชสีมา  (FB About)
- Phone: **099 245 5444** (FB About)
- Email: **rabbitgrill2026@gmail.com** (FB About)
- Links hub: linktr.ee/rabbitgrill (IG bio)
- IG: @rabbitgrill.khaoyai — 928 followers at capture
- FB: Rabbit Grill Khao Yai (id 61572023661554) — 3.3K followers, "Not yet rated (0 reviews)"
- Shares the property with **Rosebay Homecooking Café** (Wongnai reviewer). Relationship/ownership NOT verified.

## Chef  (their own claim, FB post 23 April)
`Rabbit Grill โรงย่างเนื้อเขาใหญ่ สไตล์ Home Cooking โดยเชฟผู้เชี่ยวชาญด้านเนื้อ เชฟบัส Top Chef Thailand`
=> "Chef Bas", described by the restaurant as a beef specialist, Top Chef Thailand.
**Render only as an attributed restaurant claim.** Season/placing/full name NOT independently confirmed.

## Their own copy lines (IG post overlays — usable verbatim)
- "Different perspectives. One Rabbit Grill."
- "Every great dish begins with raw care."
- "Every detail begins with a pair of hands, and every plate carries the story of the craft behind it."
- "A New Chapter of Fire & Flavor"
- `ตัดทำได้หมด`   (we'll cut it however you like)
- `ทุกเพศทุกวัย`   (all ages, everyone)
- "Fire Cooking, Rabbit Grill Khao Yai — Coming May"

## Hours  — NOT CONFIRMED BY THE RESTAURANT
Wongnai lists a close at 21:00 and a price band of 251–500 THB/head.
Third-party day-coverage is inconsistent. **Do not present hours as authoritative.**
Single source of truth: data/site.js -> HOURS. `verified:false` until the restaurant confirms.

## Pet friendly — NOT VERIFIED
No pet policy appears on their IG, FB About, FB posts, Wongnai listing or any search result.
The brief asserted an air-conditioned pet area from "customer reports"; I could not source it.
**No pet policy is published.** data/site.js -> PETS.verified=false renders an honest
"call us before you come" module instead. Flip to true + fill fields once confirmed.

## Do NOT claim
awards - Michelin - dry-aging - specific beef provenance beyond the menu's own wording -
supplier names - ratings - review counts - testimonials - reservation system - parking -
opening date - founder story - "the same owners as Rosebay" - pet policy - delivery.

## Assets
- doc/menu-food.pdf (14pp) + doc/menu-beverage.pdf (4pp) + doc/menu-avocado.jpg
  = their own current menus, pulled from the Google Drive links in the IG linktree.
  Each PDF page is a single embedded JPEG -> extracted to doc/pages/*.jpg.
  These carry the real brand artwork AND all the food photography used on the site.
- Brand colours read off that artwork: cream #F5EFE0 / #E7DFCB, forest green wordmark,
  oxblood wordmark variant + "NEW SEASONAL" badge, taupe category chips.
- Menu type system: fine serif wordmark + condensed grotesk drink headings + handwritten dish names.

## Typos in the source menu (corrected on the site, recorded here)
- "APPERTIZER"        -> APPETIZERS   (category label)
- "Australalain Striploin" -> Australian Striploin
- "Creme Brulee Lamon"     -> Crème Brûlée Lemon
Dish wording is otherwise reproduced exactly, including their "Sauteed" spelling.

---

# Second pass — 2026-08-29, venue photography and the Google listing

## Their own Facebook photographs (the big unlock)
The `/photos` tab redirects to login, but the public `/p/` profile page exposes
nine `/photo/?fbid=…` permalinks plus the cover, and **those permalinks render
logged-out in a real browser**, with the full 2048px original in the DOM.
`fetch()` does not work — it returns the login shell — so they must be read off
the page after a real navigation. Harvested by `_qa/fetch-fb-photos.ps1` into
`img/raw/`; every query parameter is part of the signature, and the URLs expire
after a few hours.

That gave the site what it had been missing entirely:
- **the building at night**, dark green frontage, โรงย่างเนื้อ เขาใหญ่ lit in the window
- **the open kitchen with guests seated right at it**, copper heat lamps, staff in RABBIT GRILL tees
- **the pass on a full night**, and a cook finishing a dish with a torch
- **real fire** — meat on the grate with flames through the bars, twice
- raw cuts on the prep counter

## HOURS — now largely resolved
- **Closed every Wednesday.** The restaurant's own Facebook card says so in as many
  words (fbid 122120344280734122, saved as `img/raw/fb-closed-wed.jpg`).
- **11:00 – 21:00.** Their Google listing and the Wongnai listing agree. This is
  third-party, not the restaurant's own statement, and the site says so.

## Google Business listing — verified in a browser this session
- `https://maps.google.com/?cid=8515251904881320690`
- Name **RABBIT GRILL KHAO YAI โรงย่างเนื้อ**, phone **099 245 5444** (matches Facebook)
- **4.5 from 58 reviews**
- Plus code **JCJ3+CGF**, Mo Kra Hat, Nong Nam Daeng, Pak Chong 30130
- Coordinates **14.6303212, 101.4045925**
- Categorised by Google as a butcher shop, which is why plain restaurant searches miss it
- The listing is **unclaimed** — no owner-uploaded photos, and the hours are not owner-set

The rating is displayed as an attributed, linked fact. It is deliberately **not**
emitted as `aggregateRating` in the JSON-LD: a business marking up its own
third-party score is what search engines penalise.

## Still nothing on pets
Across Google's 33 user photos, the whole Facebook set, Instagram and the
short-video reviews, **no dog or pet appears anywhere, and no pet policy is
stated on any surface.** The ask-first module stands.

## Leads not yet mined
- The blogger page เจริญพุงพเนจร (JpHappybelly) visited 27 May 2026 and posted a
  **28-photo album** — its first frames are a clean daytime exterior and the open
  kitchen with a cook working. The logged-out DOM only exposes five thumbnails;
  the rest need paging through the viewer one at a time.
- Google's own gallery holds 20 items plus 13 more on individual reviews, including
  a dry-age display fridge and a frame showing the Rabbit Grill and Rosebay
  buildings together. `lh3.googleusercontent.com` URLs need a `=s0` or
  `=w2048-h1536-k-no` suffix or they 404.
