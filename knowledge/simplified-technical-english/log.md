# Directory Update Log

## 2026-07-26

* **Initialization**: Created the `simplified-technical-english` knowledge
  bundle to give the STE100-inspired guidelines a canonical, publicly-reachable
  home on `skills-releases`. Previously the detailed guide lived only at
  `includes/ste100-detailed-guide.md.tmpl`, which was not part of the knowledge
  bundle system that consumer projects discover.
* **Creation**: Authored 2 concept pages:
  - [simplified-technical-english.md](simplified-technical-english.md) — the core guidelines (active voice, short sentences, one-word-one-meaning, imperative mood, approved modifiers, acronym definitions, quick self-check)
  - [detailed-guide.md](detailed-guide.md) — full 10 writing rules, approved-words guidance, 3 before/after examples, 10-step self-check protocol
* **Creation**: Established [overview.md](overview.md) synthesis and this
  [index.md](index.md) directory listing.
* **Migration**: Moved the detailed-guide content from
  `src/current/includes/ste100-detailed-guide.md.tmpl` into
  [detailed-guide.md](detailed-guide.md) (with OKF v0.2 frontmatter). Removed
  the include file — the bundle is now the single source of truth for the full
  guide. The build-time include
  `ste100-simplified-technical-english.md.tmpl` remains in `includes/` as the
  gist that gets inlined into skills and other bundles; it links to this
  bundle's published URL for the full detail.
