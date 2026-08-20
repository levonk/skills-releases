# Project Overrides Enforcement

This skill (ai-upsert) and **every skill it creates or updates** MUST honor
the local project override layer documented in the `project-overrides`
include (already inlined above via `base-ai-guidance`). The override lives
in the **target repository** at
`.agents/config/skills/<owner>/<repo>/<skill-path>/` and consists of two
files:

- `config.toml` — machine-readable flags
- `SKILL.local.md` — agent-readable supplementary guidance

**Trust model**: project-local installs honor the override automatically;
non-local installs ask the user before honoring. See the `project-overrides`
include for the full discovery procedure and trust model.

**This skill's own behavior**: ai-upsert checks for its own override at
`.agents/config/skills/levonk/skills-releases/ai/ai-upsert/` (or the
appropriate owner/repo/path for the active distribution) in the target repo
and honors it per the trust model.

**Skills this skill creates/updates**: when ai-upsert creates a new skill
(Mode A) or updates an existing skill (Mode C), the generated/updated skill
MUST also honor the local project override layer. This is enforced by:

1. The `base-ai-guidance` include (already wired into every new skill by
   Mode A step 6) bundles the `project-overrides` include, so every skill
   that includes `base-ai-guidance` inherits the override behavior
   automatically.
2. The Mode C audit checklist (below) includes a check that the skill being
   updated honors the override — i.e. that it includes `base-ai-guidance`
   (or the `project-overrides` include directly) and does not silently
   ignore `SKILL.local.md` / `config.toml` files in target repos.
3. When ai-upsert generates a skill outside `skills-src` (no templater
   available), the materialized `SKILL.md` must contain a section
   documenting the override behavior, since the include is inlined at build
   time and the materialized copy already has the full text.
