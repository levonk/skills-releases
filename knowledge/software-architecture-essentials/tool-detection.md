---
type: Practice
title: Tool Detection Architecture
description: Detect tools via PATH first, verify with --version, cache results, and treat detection as I/O with clear error messages and retries.
tags: [architecture, tool-detection, cli, path, caching]
timestamp: 2026-07-18T00:00:00Z
---

# Tool Detection Architecture

## Practice

- PATH detection first (e.g., `which` / `where`).
- Version verification using `--version`; fallback to `--help`.
- Cache detection results to speed subsequent runs.
- Design for variability across install methods and operating systems.
- Treat detection as I/O with clear error messages and retries where reasonable.

## Why

Tool installation locations vary wildly across package managers, OSes, and
environments (devbox, nix, mise, asdf, brew). A detection layer that handles
this variability once — with caching and clear errors — keeps the rest of the
codebase simple and fast.

## See Also

- [Adding New Tools](adding-tools.md) — how to wire a newly detected tool into the CLI surface.

## Sources

- Migrated from src/current/rules/software-dev/general/architecture/tool-detection.md
