# Revision Notes

**Date:** 2026-10-05
**Scope:** Structural and build-consistency review (wave 1 — correctness)
**Author:** automated review pass, render-verified with Quarto 1.6.40

Part of a workspace-wide standard for all six books, documented at
[`viz-base/AUTHOR-STANDARDS.md`](https://github.com/rsquaredacademy-education/viz-base/blob/master/AUTHOR-STANDARDS.md). This file records only what changed in
**this** repository.

---

## Summary

One change: seven "Your Turn" headings reduced to one exact spelling.

Plus a `LICENSE` file. No URLs, slugs or redirects affected — no solutions
pointers, filenames or chapter structure were touched in this pass.

---

## 1. Heading spelling normalized

"Your Turn" shipped in four variants — differing by trailing ellipsis
(`...`, `..`, or none) and, in two chapters, by heading level. Text is now one
exact string:

| File | Before | After |
|:--|:--|:--|
| `12-factors-fundamentals.qmd` ×3 | `### Your Turn...` | `### Your Turn` |
| `13-forcats-manipulation.qmd` ×3 | `### Your Turn...` | `### Your Turn` |
| `13-forcats-manipulation.qmd` ×1 | `### Your Turn..` | `### Your Turn` |
| `04-dplyr-1.qmd` | `## Your Turn` | *already correct* |
| `08-tidyr.qmd` | `## Your Turn` | *already correct* |
| `10-lubridate-parsing.qmd` ×6 | `### Your Turn` | *already correct* |
| `11-lubridate-arithmetic.qmd` ×3 | `### Your Turn` | *already correct* |

The bare spelling was treated as canonical.

**Heading levels were deliberately left alone.** This is not drift:

- `## Your Turn` closes a chapter (in `04-dplyr-1.qmd`, `08-tidyr.qmd`).
- `### Your Turn` is a nested drill partway through a long split chapter
  (`10-`, `11-`, `12-`, `13-`).

Flattening them to one level would misrepresent the document structure. Only
the heading *text* was inconsistent, so only the text was changed.

---

## 2. LICENSE added

`LICENSE` — verbatim CC BY-NC-SA 4.0 International legal code (438 lines),
fetched from `creativecommons.org`. License text is never reconstructed from
memory.

The README already declared CC BY-NC-SA 4.0 in prose and the Preface carries a
licence line; there is now a root `LICENSE` to match.

---

## Verification

Rendered with Quarto **1.6.40**; no errors or warnings.

- 18 pages built.
- All 18 "Your Turn" headings present in output, across 7 pages:

| Page | occurrences |
|:--|--:|
| `04-dplyr-1.html` | 3 |
| `08-tidyr.html` | 3 |
| `10-lubridate-parsing.html` | 18 |
| `11-lubridate-arithmetic.html` | 9 |
| `12-factors-fundamentals.html` | 9 |
| `13-forcats-manipulation.html` | 12 |
| `14-solutions.html` | 4 |

Each heading appears once in the page body and once in the in-page TOC, hence
more than 18 raw matches.

- 0 unresolved `??` cross-references.
- Source check confirms no `Your Turn.` variants remain.

---

## Before committing

- Suggested message: `docs: unify heading spellings`

---

## Not done here (tracked in the workspace checklist)

- **Solutions are a rendered book chapter** (`14-solutions.qmd`), not a
  `solutions/` folder — the only book structured this way. Migrating is wave 6.
  Note the chapter is honest about its own gaps: it lists "Open stubs" for the
  7 chapters that have no drills.
- **Exercises in only 6 of 14 chapters.** The other 8 have no practice section.
- **Quarto version is unpinned** (`version: "release"`) — the largest remaining
  CI risk, scheduled for wave 2.
- **PDF uses lualatex** (16 callout sites); house standard is Typst (wave 5).
- **~39 MB of tracked fixtures at the repo root** rather than in `data/`:
  `analytics_raw.csv` alone is 34.8 MB, plus `analytics_raw.rds`,
  `analytics.rds`, `airline.dta`, `airline.sas7bdat`, `employee.sav`,
  `sample.xls`, `hsb2/3/4.csv`. These are referenced by chapters, so they
  should be **moved to `data/`**, not deleted — that touches chunk paths across
  many files, hence wave 9.
- No `make-sitemap.sh`; CI installs a static `sitemap.xml` instead.
- Only book using `00-`…`14-` filename prefixes; house standard is bare
  topical slugs (wave 8).
- CI makes PDF and ePub non-fatal (`|| echo "PDF_FAILED=1"`) while
  `downloads: [pdf, epub]` is advertised — a silent non-fatal render once
  shipped a green build with no PDF. Wave 2.