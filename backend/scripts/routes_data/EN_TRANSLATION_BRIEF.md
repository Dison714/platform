# EN translation brief — Routes category (shared rules for all 8 articles)

Translate the RU source at `backend/scripts/routes_data/ru/<baseSlug>.md` into natural,
fluent English. This is a travel-blog article for a Bali motorbike rental company
(MDB Motor Rental), not a literal/word-for-word translation — read for meaning and
write it the way a native English travel writer would, while preserving every fact
(numbers, dates already trimmed to month+year, quotes' substance, prices, times).

## Hard rules

1. **Catalog-correct bike model names** — use exactly these forms regardless of what
   the RU text says (RU has some inconsistencies vs the catalog; EN must be correct):
   - Honda PCX160 (not "Honda PCX")
   - Honda ADV160 (not "Honda ADV")
   - Yamaha Nmax (not "Yamaha Nmax 155" — no "155")
   - Yamaha XMAX250 (not "Yamaha Xmax 250" — one word, XMAX in caps, no space before 250)
   - Kawasaki Versys-X 250 (not "Kawasaki Versys" alone)
   - Suzuki V-Strom 250 (RU already correct, keep as-is)
   - Honda CB150X (RU already correct)
   - Keeway Road Falcon 250 (RU already correct)

2. **Place names — keep exactly as spelled in the RU source.** They're already
   English/Latin proper nouns embedded in the Russian text (Tirta Gangga, Lahangan
   Sweet, Gembleng Waterfall, etc.) — do not respell, do not invent alternate
   spellings. This does not need the transliteration glossary (that's only for
   non-Latin scripts — ja/ko/zh-Hans/ar/hi); EN keeps the same Latin spelling as RU.

3. **Google Maps links — copy verbatim, do not re-verify or change.** Every
   `[Name](https://maps.app.goo.gl/...)` link keeps its exact URL. These were
   already verified (62 links, matched against the source report) — just carry
   the markdown link through with the location name translated/kept as appropriate
   in the surrounding English sentence, URL untouched.

4. **Video blocks — keep the exact markdown structure and URLs, translate only the alt text.**
   Example: `![Video: sunrise through the trees at the viewpoint (Kawasaki Versys-X 250, clip 1 of 12)](https://cdn.bikebalirent.com/blog/versys-east-bali-01.mp4 "https://cdn.bikebalirent.com/blog/versys-east-bali-01-poster.webp")`
   — the `.mp4`/`-poster.webp` URLs must be byte-identical to the RU source, only the
   `![...]` alt text changes language.

5. **WhatsApp/Telegram links — keep the wa.me/t.me URL structure, translate only the prefill message naturally.**
   Format: `[WhatsApp](https://wa.me/6282146433303?text=<url-encoded English message>)`
   and `[Telegram](https://t.me/Bali_rent_main?text=<same encoded message>)`.
   Write a natural English message referencing the article's own EN title, e.g.
   "Hi! I have a question about your article \"<EN title>\"." — do NOT translate
   the Russian prefill literally word-for-word; phrase it the way an English
   speaker would actually message a rental company. URL-encode the final message
   yourself (spaces as %20, punctuation encoded, matching how the existing live
   EN deposit-safety articles do it).

6. **Internal cross-links — rewrite to the EN URL for each target** (all `/en/blog/...`,
   not `/ru/blog/...`):
   - Pillar ("Bali Motorbike Routes: A Guide from MDB Motor Rental's Drivers and Clients" — translate the RU title naturally, this is just descriptive) → `/en/blog/best-bike-routes-in-bali-curated-list`
   - East Bali/Amed article → `/en/blog/east-bali-amed-route`
   - Sekumpul waterfalls article → `/en/blog/sekumpul-waterfalls-route`
   - Kintamani sunrise article → `/en/blog/kintamani-sunrise-route`
   - Ubud one-day article → `/en/blog/ubud-route-rice-terraces-and-temples`
   - Bedugul-Munduk-Lovina article → `/en/blog/bedugul-munduk-lovina-route`
   - Bukit peninsula article → `/en/blog/bukit-peninsula-route`
   - Volcano treks article → `/en/blog/bali-volcano-treks-route`
   - The braking-technique guide (cited in East Bali, Kintamani, Bedugul-Munduk-Lovina) → `/en/blog/how-to-brake-safely-on-balis-hills-and-mountain-roads`
   - The no-license legal article (cited in Ubud) → `/en/blog/riding-in-bali-without-a-license-the-real-risks`
   For each cross-link, translate the link TEXT (the article title shown to the reader)
   into natural English matching that article's own EN title — you don't need the
   exact final EN title of sibling articles you're not translating right now; use a
   natural, accurate English rendering of the RU title being linked.

7. **Bike model catalog links (`/bikes?...`) — keep the URL exactly as in RU, only translate the surrounding link text if the link text is a plain model name (which per rule 1 should use the catalog-correct EN name).**

8. **Do not touch or re-derive dates/quotes/facts** — the RU source is already final for this review round. Translate what's there faithfully.

## Output

Write the translated body (matching the RU file's scope — no H1 title line, no
italic metadata line, just the article body starting from the intro paragraph)
to `backend/scripts/routes_data/en/<baseSlug>.md`.

Also report back, in your final message:
- The English title (translated from the RU H1) — natural, SEO-reasonable, not a literal word-for-word translation.
- A 1-2 sentence English excerpt (plain text, no markdown syntax — no `[]()`, no `*emphasis*`) suitable for a meta description / article listing card.
- Confirmation of how many Google Maps links, video blocks, and WhatsApp/Telegram CTAs you preserved (counts should match the RU source exactly).
