# AGENTS.md — src/current/skills/

> Binding contract for skill source files. Read before creating or editing skills.

## Identity

Source files for all skills in the `current` (public) profile. Each skill is a
directory containing a `SKILL.md` (with YAML frontmatter + body) and optional
`scripts/`, `references/`, `assets/`, `evals/` subdirectories. Files ending in
`.tmpl` are rendered by the templater; others are copied verbatim.

## Setup & Run

```bash
# Build the current profile (renders all skills here → build/current/skills/)
just build current

# Validate (checks frontmatter + leaked delimiters)
just validate
```

## Patterns & Conventions

✅ **DO**: Include `base-ai-guidance` via `{{{ include "includes/base-ai-guidance.md" . }}}`
✅ **DO**: Use progressive disclosure (metadata → body → references)
✅ **DO**: Extract deterministic phases into `scripts/` (one script per AI→script handoff)
✅ **DO**: Put detailed guidance in `references/` with topic-named files
✅ **DO**: Add PEP 723 headers to Python scripts
✅ **DO**: Add "Do NOT trigger on..." clause to descriptions
✅ **DO**: Wire in `trigger-guard` for pushy descriptions
✅ **DO**: Use `git mv` when moving skill directories

❌ **DON'T**: Inline script code in SKILL.md — call scripts by name
❌ **DON'T**: Hardcode paths — use indirect references + Context Declaration
❌ **DON'T**: Exceed ~500 lines in SKILL.md body
❌ **DON'T**: Use `{{`/`}}` — always `{{{`/`}}}`
❌ **DON'T**: Put runtime dependencies in includes — includes are build-time only

## Key Directories

| Path | Category |
|------|----------|
| `ai/` | AI guidance upsert skills (ai-skill-upsert, ai-workflow-upsert, agent-file-upsert, readme-upsert, ai-guidance-improver, prompt-upsert, template-upsert, agent-upsert, knowledge-bundle-upsert, rule-upsert, handoff) |
| `software-dev/` | Software development skills |
| `business/` | Business skills |
| `commerce/` | Commerce skills |
| `content/` | Content creation skills |
| `execution/` | Execution skills |
| `general/` | General-purpose skills |
| `tech-maturity/` | Tech maturity assessment |

## Touch Points

- **Frontmatter**: `name`, `description`, `version`, `date`, `tags`, `see-also`
  in each `SKILL.md` — the `description` is the primary trigger mechanism
- **Includes**: `{{{ include "includes/..." . }}}` — resolved at build time,
  inlined into the output
- **Scripts**: `scripts/*.py` — must have PEP 723 headers, run via `uv run --script`
- **References**: `references/*.md` — detailed guidance loaded on demand

## JIT Index Hints

```bash
# Find all skills
find src/current/skills -name "SKILL.md" | sort

# Find skills that include a specific include
rg 'base-ai-guidance' src/current/skills/

# Find skills with scripts
find src/current/skills -path "*/scripts/*.py" | head

# Find skills by tag
rg -l 'ai/skill' src/current/skills/ --glob "SKILL.md"
```

## Gotchas

- Skills are self-contained after build — includes are inlined, so built skills
  in `skills-releases` have no `{{{ include }}}` directives
- `see-also` with `template:` is build-time (inlined); `skill:`/`workflow:` is
  runtime (consumer must install separately)
- The `init_skill.py` scaffolder creates example files in `scripts/`,
  `references/`, `assets/` — customize or delete them
