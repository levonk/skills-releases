<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **execution** · Status:  · Version: 1.0.0

>-

## Metadata

| Field | Value |
|-------|-------|
| Name | `briefingmemo` |
| Category | `execution` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Overview

This skill implements a deterministic multi-agent decision-making system that transforms strategic questions into well-researched decisions through a structured committee process.

## Related Skills
- **think-assist** (skill, dependency) — Thinking-method library consumed by this skill's committee
- **peer-review** (skill, optional) — Blind peer-review round that can be added before the CSO memo
- **ai-guidance-improver** (skill, complement) — For improving guidance file quality
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/execution/briefingmemo/SKILL.md`](skills/execution/briefingmemo/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-16T08:35:31Z
