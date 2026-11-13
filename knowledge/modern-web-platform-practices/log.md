# Directory Update Log

## 2026-11-13

* **Ingest**: Created the modern-web-platform-practices knowledge bundle
  with 232 concept pages ingested 1:1 from
  [GoogleChrome/modern-web-guidance](https://github.com/GoogleChrome/modern-web-guidance)
  at commit `4dd9683` (2026-11-10, Apache-2.0).
  - 209 platform guides across 17 categories — accessibility (4),
    built-in-ai (5), css (18), forms (19), html (8), js (5),
    performance (26), privacy (1), pwa (2), security (17), ui-atoms (13),
    ui-behaviors (40), ui-components (22), user-experience (3),
    visual-design (22), wasm (1), webmcp (3)
  - 23 Chrome references — chrome-extensions (19, `type: Practice`),
    chrome-webstore (4, `type: Reference`)
  - Upstream `retrieve "<id>"` cross-references rewritten to relative
    markdown links (66 files touched); guide ids preserved as filenames
  - Per-page provenance recorded in `sources:` frontmatter (pinned blob
    URL + per-file `last_modified` from upstream git history)
* **Create**: Created [index.md](index.md) (root catalog grouped by
  category), per-category `index.md` files (19), and
  [overview.md](overview.md) (synthesis + reading map + upstream
  freshness pointer).

<!-- vim: set ft=markdown -->
