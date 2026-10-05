# Revision Notes — Wave 2 (toolchain pinning)

**Date:** 2026-10-05
**Scope:** Pin the build toolchain; make PDF/ePub failures fatal
**Author:** automated review pass

Part of a workspace-wide standard for all six books, documented at
[`viz-base/AUTHOR-STANDARDS.md`](https://github.com/rsquaredacademy-education/viz-base/blob/master/AUTHOR-STANDARDS.md). This file records only what changed in
**this** repository.

---

## Summary

- Replace `version: "release"` with an exact Quarto pin.
- Make PDF and ePub renders fatal; remove the `PDF_FAILED` plumbing.
- Add a gate asserting both artifacts exist before assembly.

No content or `_quarto.yml` changes in this book.

---

## 1. Unpinned Quarto

```yaml
- uses: quarto-dev/quarto-actions/setup@v2
  with:
    version: "release"          # floating
```

This book broke with no commit to bisect whenever Quarto shipped anything,
and the **lualatex** PDF path is the most sensitive to upstream change — it
depends on TinyTeX and on callout/tcolorbox support that Quarto's templates
own. Now pinned to `1.10.18`, matching viz-ggplot2, which shares this
toolchain and PDF engine.

## 2. PDF/ePub failures were being swallowed

```yaml
run: quarto render --to pdf --output-dir /tmp/stage-pdf || echo "PDF_FAILED=1" >> $GITHUB_ENV
```

That form **always exits 0**. A failed render left a green build, and the
assemble step logged *"No PDF staged"* and continued — while the landing
page still advertised a download that was not there.

This matters here because `downloads: [pdf, epub]` is set in `_quarto.yml`
and was added in wave 1, so the promise is now visible to readers.

Removed the `||` from both render steps, removed the `PDF_FAILED`/
`EPUB_FAILED` handling from the assemble step (bare `cp` now), and added:

```yaml
- name: Verify downloads are present
  run: |
    ls /tmp/stage-pdf/*.pdf  || { echo "PDF MISSING";  exit 1; }
    ls /tmp/stage-epub/*.epub || { echo "EPUB MISSING"; exit 1; }
```

viz-base was already doing exactly this, with a comment recording that a
silent non-fatal render had previously shipped a green build with no PDF at
all. This aligns the two lualatex books with it.

---

## Verification

- PDF renders on the pinned Quarto 1.10.18 via lualatex → **5.3 MB**.
- Workflow parses as valid YAML.
- CI ran green and deployed to Netlify.
- PDF confirmed live:
  `https://wrangle-r.rsquaredacademy.com/Data-Wrangling-with-R.pdf`
  → HTTP 200, 6621 KB, valid `%PDF` header.
- The lualatex path was verified *before* committing the pin, not after —
  pinning to a version the book cannot build on would have been worse than
  the floating version.

---

## Commits

| SHA | Message |
|:--|:--|
| `c733eb6` | ci: pin Quarto and make PDF/epub failures fatal |

---

## Not done here

- **No `make-sitemap.sh`.** CI installs a static `sitemap.xml` instead of
  generating one, unlike the other five books. Wave 3.
- **No slug gate is missing** — this book *does* verify every
  `_quarto.yml` slug rendered, which is the pattern the others should copy.
- **Still uses lualatex** for the PDF. House standard is Typst, but callouts
  are unavailable there: `viz-base/AUTHORING.md:64-66` documents
  `:::{.callout-tip}` failing with `error: unknown variable: callout`.
  Migrating means converting **16 callout sites** into blockquote
  signposts. Wave 5.
- **`_extensions/coatless/webr` required** — the `webr` HTML filter is what
  makes the interactive cells work, and it breaks the Typst template's
  callout definitions. This is the same reason the book must stay on
  lualatex today.
- **~39 MB of tracked fixtures at the repo root** rather than in `data/`:
  `analytics_raw.csv` alone is 34.8 MB, plus `analytics_raw.rds`,
  `analytics.rds`, `airline.dta`, `airline.sas7bdat`, `employee.sav`,
  `sample.xls`, `hsb2/3/4.csv`. Referenced by chapters, so they should be
  **moved to `data/`**, not deleted — that touches chunk paths across many
  files, hence wave 9.
- **Solutions are a rendered book chapter** (`14-solutions.qmd`), not a
  `solutions/` folder — the only book structured this way. Wave 6.
- **Exercises in only 6 of 14 chapters.** The other 8 have no practice
  section; `14-solutions.qmd` honestly lists these as "Open stubs".
- Only book using `00-`…`14-` filename prefixes; house standard is bare
  topical slugs. Wave 8.
- `make-webr-samples.R` regenerates `data-webr/`, which is why those CSVs are
  committed at all — worth confirming that is still intended.