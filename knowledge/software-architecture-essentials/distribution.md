---
type: Practice
title: Distribution & Packaging
description: Single-binary distributions for CLIs, prebuilt binaries via NPM, and tracking of install/update/offline behavior.
tags: [architecture, distribution, packaging, cli, npm]
timestamp: 2026-07-18T00:00:00Z
---

# Distribution & Packaging

- Prefer single-binary or minimal-runtime distributions for CLIs.
- For NPM delivery of native apps, ship prebuilt binaries plus thin wrappers.
- Track compressed and unpacked sizes; optimize with platform splits and stripping.
- Document install paths, update strategy, and offline behavior.

## Sources

- Migrated from src/current/rules/software-dev/general/architecture/distribution.md
