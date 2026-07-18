---
type: Synthesis
title: Web Resource Catalog Overview
description: Synthesis of the curated web resource domain catalog and its maintenance workflow.
tags: [web-resource-catalog, overview, synthesis, toon]
timestamp: 2026-07-11T16:30:00Z
---

# Web Resource Catalog Overview

This knowledge bundle documents the curated set of web resource domains allowed
in the Devin CLI configuration. Domains are organized into categories that
reflect how the user discovers and references these resources during
AI-assisted development work.

## Categories

| Category | Domains | Purpose |
|----------|---------|---------|
| VCS & Forge | 22 | Code hosting and open-source collaboration |
| Project Tracking | 28 | Issue trackers and project management |
| Design & UI | 73 | Design systems, components, icons, fonts |
| Color Palettes | 27 | Color tools and palette generators |
| Stock Media | 57 | Stock photos, audio, and video |
| Deny List | 22 | IP logger domains blocked for security |

**Total allowed domains**: 627 (plus 5 wildcard patterns)
**Total denied domains**: 22

## TOON Format

Domain lists in each concept are encoded in [TOON](https://toonformat.dev/)
(Token-Oriented Object Notation) rather than JSON. TOON is the project's
preferred format for bulk data transfer to LLMs (see
`src/current/workflows/ai/includes/data-format-requirements.md.tmpl`):

- ~40% fewer tokens than JSON for the same data
- Human-readable in any editor
- Schema-aware: array length `[N]` helps LLMs validate structure
- Round-trips losslessly via the `@toon-format/toon` library

Example TOON primitive array (used for domain lists):

```
domains[3]: github.com,gitlab.com,bitbucket.org
```

## Maintenance

The bundle is synchronized with `~/.config/devin/config.json` (the deployed
config) and the chezmoi source at
`~/p/gh/levonk/dotfiles/home/current/dot_config/devin/config.json`.

When new domains are added to the config:

1. Update the relevant category concept file
2. Update the domain count in this overview
3. Append an entry to `log.md`
4. Re-sort the domain list alphabetically within the concept

## Source of Truth

The config file is the source of truth. This bundle is a derived, organized
view of the config's `permissions.allow` and `permissions.deny` arrays,
designed for progressive disclosure and LLM-friendly consumption.

# Citations

[1] [TOON Format](https://toonformat.dev/)
[2] [TOON Format Overview](https://toonformat.dev/guide/format-overview)
[3] [Devin CLI config](https://github.com/levonk/dotfiles/blob/main/home/current/dot_config/devin/config.json)
