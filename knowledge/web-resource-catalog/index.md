---
okf_version: "0.1"
---

# Web Resource Catalog

A compounding knowledge base documenting curated web resource domains organized
by category. Each concept lists the domains allowed in the Devin CLI
configuration (`~/.config/devin/config.json`) for that category, encoded in
[TOON](https://toonformat.dev/) (Token-Oriented Object Notation) for compact
LLM consumption.

## Categories

* [Overview](overview.md) - Synthesis of the catalog and how it is maintained
* [VCS & Forge Communities](vcs-forge-communities.md) - Code hosting, forge platforms, and open-source collaboration
* [Project & Task Tracking Sites](project-tracking-sites.md) - Issue trackers, project management, and task platforms
* [Design & UI Component Sites](design-ui-components-sites.md) - Design systems, UI libraries, icons, and fonts
* [Color Palette Tools](color-palettes-sites.md) - Color palette generators and color reference resources
* [Stock Photo, Audio & Video Sites](stock-media-sites.md) - Stock photography, royalty-free audio, and stock video
* [IP Logger Deny List](ip-logger-deny-list.md) - Stable IP logger domains denied for security

## Format

Domain lists within each concept are encoded in TOON primitive array syntax:

```
domains[N]: domain1.com,domain2.com,domain3.com
```

This is ~40% more token-efficient than JSON for bulk domain data while remaining
human-readable. See the [TOON format overview](https://toonformat.dev/guide/format-overview).
