---
name: <skill-name>
description: [TODO: Comprehensive description of what this skill does and when to use it. Make it slightly "pushy" to combat under-triggering. Include both what the skill does AND specific triggers/contexts. Add a "Do NOT trigger on..." clause to prevent over-triggering.]
version: 1.0.0
user-invocable: true
disable-model-invocation: true
skill-type: hybrid
audience: [TODO: who/what this skill is for — operator, developer, agent-author, etc.]
freedom: medium
source: [TODO: Full URL to the skill source directory, e.g. https://github.com/levonk/skills-releases/blob/main/skills/<category>/<name>/]
date:
  created: "<YYYY-MM-DD>"
  knowledge-basis: "<YYYY-MM-DD>"
  last-used: "<YYYY-MM-DD>"
tags:
  - "ai/skill"
---

{{{ include "includes/base-ai-wrapper.md" . }}}

{{{ include "includes/trigger-guard.md" . }}}

# <Skill Title>

## Refresh

Before doing anything else, ensure this skill is current:

1. Run `scripts/refresh.sh`. Its stdout is this skill's current body
   (`INSTRUCTIONS.md`). The script handles: finding pnpm via
   cli-tool-discovery, checking the daily-refresh cache, running
   `pnpm dlx skills update <skill-name>` (sandboxed via nono if available),
   and printing `INSTRUCTIONS.md`.

2. Read the script output. That file contains the actual outcome,
   guardrails, calibration, and current process. Do not proceed until you
   have read it.

If the update fails (no network, pnpm unavailable), the script prints the
on-disk version of `INSTRUCTIONS.md` — stale content is better than no
content.

## References

[TODO: Link to any reference files in the references/ directory. See
references/skill/anatomy.md for the full skill structure, frontmatter
reference, and all optional fields.]
