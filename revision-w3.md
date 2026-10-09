# Revision Notes — Wave 3 (CI convergence)

**Date:** 2026-10-05
**Scope:** One workflow shape per book; gates that cannot drift
**Author:** automated review pass

Part of a workspace-wide standard for all six books, documented at
[`viz-base/AUTHOR-STANDARDS.md`](https://github.com/rsquaredacademy-publications/viz-base/blob/master/AUTHOR-STANDARDS.md).
This file records only what changed in **this** repository.

---

## Summary

- Rename `deploy.yml` to `render.yml`.
- Replace the 16-entry hand-maintained slug list with `scripts/verify-slugs.sh`,
  derived from `_quarto.yml`.
- Replace the static sitemap with generation at build time.
- Add `scripts/verify-sitemap.sh`.
- Add a cross-reference gate.

---

## 1. The slug gate was a hand-maintained list

The old gate listed 16 slugs across two `for` loops, which had to be edited by
hand whenever a chapter was added:

```yaml
for f in index 00-author 01-import-1 ... 14-solutions; do
for f in appendices/arrow-duckdb appendices/legacy-magrittr appendices/rosetta-pandas; do
```

Replaced with `scripts/verify-slugs.sh`, which reads `book.chapters` and
`book.appendices` from `_quarto.yml` via `yq`. It covers all 19 in one pass.

---

## 2. The sitemap is now generated, not copied

**A correction to an earlier claim.** In the wave-3 planning I reported this
book's sitemap as broken, with three appendix URLs 404ing. That was wrong — I
had tested against `data-wrangling.rsquaredacademy.com` instead of the real
host, `wrangle-r.rsquaredacademy.com`. The appendix URLs are correct and return
HTTP 200.

The sitemap was nonetheless unverifiable, because nothing compared it against
the pages actually built. That is now fixed rather than asserted:

- `scripts/make-sitemap.sh` generates the sitemap from the rendered pages after
  the HTML render. The root `sitemap.xml` is deleted.
- `_quarto.yml` no longer lists `sitemap.xml` under `resources`, since there is
  no root copy to copy in.

**The generator recurses.** A flat listing would emit `/arrow-duckdb.html` for a
page served at `/appendices/arrow-duckdb.html` — a 404 for a crawler following
the sitemap. This book has three appendices in a subdirectory, so it is exactly
the case that made recursion necessary.

---

## 3. The sitemap gate compares sets, not counts

Counting is not sufficient. viz-base had 17 entries for 17 pages while omitting
`privacy.html`, because a bare `/` root entry offset the missing page. A
count-based gate passes that.

`scripts/verify-sitemap.sh` compares the set of rendered pages against the set
of URLs and names what disagrees:

```
SITEMAP is missing rendered pages:
  privacy.html
```

---

## Verification

- Slug gate: all 19 chapters pass against committed `docs/`; exit non-zero when a
  page is removed.
- Sitemap gate: all 19 pages covered; regenerating produces identical output, so
  no churn.
- Negative controls: removing `03-pipes` from the stage makes the sitemap gate
  exit 1; removing `14-solutions` makes the slug gate exit 1.
- Workflow parses as valid YAML; 18 steps.
- CI green (6m59s, deployed to Netlify).

---

## Commits

| SHA | Message |
|:--|:--|
| `fad6d72` | ci: replace hand-maintained gates with derived ones, regenerate sitemap |

---

## Not done here

- **Still uses lualatex** for the PDF. House standard is Typst, but callouts are
  unavailable there — `viz-base/AUTHORING.md:64-66` documents `:::{.callout-tip}`
  failing with `error: unknown variable: callout`. Wave 5.
- **No `make-sitemap.sh` existed before this wave**; the other books that had one
  kept near-duplicate copies. This one is now recursive and sorted.
- **Solutions are a rendered book chapter** (`14-solutions.qmd`), not a
  `solutions/` folder — the only book structured this way. Wave 6.
- **Exercises in only 6 of 14 chapters.** The other 8 have no practice section;
  `14-solutions.qmd` honestly lists these as "Open stubs". Wave 7.
- **~39 MB of tracked fixtures at the repo root** rather than in `data/`:
  `analytics_raw.csv` alone is 34.8 MB. Referenced by chapters, so they should
  be **moved to `data/`**, not deleted — that touches chunk paths across many
  files, hence wave 9.
- Only book using `00-`…`14-` filename prefixes; house standard is bare topical
  slugs. Wave 8.