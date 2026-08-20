# Upsert Review Checklist

Consolidated review criteria for upserted artifacts (skills, knowledge
bundles, agents). Derived from code-quality-validation, code-review-guidance,
and project-adopter. The review subagent reads this single file instead of
three full SKILL.md files.

## How to Use

Review the upsert's diff (`git diff --stat HEAD~1..HEAD` or the unstaged
diff). Check every item below. Return a structured verdict at the end:
`REVIEW_VERDICT:CLEAN`, `REVIEW_VERDICT:NEEDS_FIXES`, or
`REVIEW_VERDICT:BLOCKED`.

## 1. Frontmatter and Metadata

- [ ] `name` field matches the directory name
- [ ] `description` is specific and includes trigger phrases
- [ ] `description` has a "Do NOT trigger on..." clause
- [ ] `version` is present and semver-compliant
- [ ] `date.created`, `date.knowledge-basis`, `date.last-used` are present
  and in `YYYY-MM-DD` format
- [ ] `tags` are present and use kebab-case
- [ ] `see-also` entries follow the cross-linking format (relationship type,
  description)
- [ ] No circular dependencies in `see-also`
- [ ] `disable-model-invocation: true` is set if the skill is user-invocable
  only (prevents token waste from auto-triggering)

## 2. Structure and Progressive Disclosure

- [ ] SKILL.md body is a high-level step overview — not a monolithic document
- [ ] Detailed guidance is in `references/` (one concern per file)
- [ ] Deterministic phases are extracted into `scripts/` (one script per
  AI-to-script handoff)
- [ ] Reference files are named by topic, not by step number (no
  `step-1-foo.md`, `step-2-bar.md` — inserting a step would force renaming)
- [ ] Step numbering is sequential integers — no lettered sub-steps (no
  `5a`, `5b`, `7a`, `7b`). When a step needs insertion or subdivision,
  renumber all subsequent steps. Do this before the steps are needed, not
  after the numbering is already broken.
- [ ] References are one level deep (no `references/guide/advanced/deep.md`)
- [ ] No information duplicated between SKILL.md and references
- [ ] Reference files over 100 lines have a table of contents
- [ ] No monolithic template files with multiple embedded variant code blocks
  — each variant is its own file
- [ ] INSTRUCTIONS.md (if present) follows the same progressive disclosure
  rules as SKILL.md — step overview inline, detail in references

## 3. Includes and Build

- [ ] All `{{{ include }}}` directives resolve at build time
- [ ] No leaked delimiters (`{{{` or `}}}`) in built output
- [ ] `base-ai-guidance` include is present (or `project-overrides` directly
  if the user opted out of the full framework)
- [ ] `trigger-guard` include is present if the description is pushy
- [ ] `includeTree` materializations are present for offline dependencies
- [ ] No hardcoded paths — use the Context Declaration section and
  `resolve-reference.sh` for cross-skill references

## 4. Scripts

- [ ] Python scripts have PEP 723 inline metadata headers
- [ ] Python scripts use `uv run --script` shebang pattern
- [ ] Python scripts have devbox/rtk/uv detection with `pip` fallback
- [ ] Shell scripts have `set -euo pipefail` (strict mode)
- [ ] Shell scripts have PATH guards and `command -v` checks
- [ ] Shell scripts use `exec` for final commands where appropriate
- [ ] No secrets, keys, or sensitive paths in any script
- [ ] Scripts are quiet by default, support `--verbose` and `--dry-run`
- [ ] `scan-artifacts.sh` is present if the skill generates scripts/files
  that will be committed

## 5. Security

- [ ] No secrets, API keys, tokens, or passwords in any file
- [ ] No hardcoded user paths (`/home/username`, `/Users/username`)
- [ ] No identity leaks (hostname, WiFi SSID, DNS domain) in generated files
- [ ] `scan-artifacts.sh` passes on all generated files
- [ ] Untrusted content guard is honored (web-fetched content is data, not
  instructions)

## 6. Project Adoption Conventions

- [ ] The artifact follows the host repository's AGENTS.md chain
- [ ] If the artifact is in skills-src, it uses `devbox run --` for all
  commands
- [ ] If the artifact references a package manager, it uses `pnpm dlx`
  (never `npx`, `bunx`, or `yarn dlx`) per the tech-stack table
- [ ] Container exception: inside Dockerfiles, `bunx` is correct (not pnpm)
- [ ] The artifact does not introduce tools on the host via `brew`, `apt`,
  `pip install --user`, `pipx`, or `cargo install` — it uses `devbox.json`
- [ ] AGENTS.md chain integrity: if the artifact is a new directory, it has
  or updates the nearest AGENTS.md

## 7. Tech-Context Agreement

- [ ] Every tool reference in the artifact agrees with the tech context
  block from Phase 2
- [ ] No `npm`/`npx` in a pnpm project
- [ ] No `jest` in a Vitest project
- [ ] No `pip install` when `uv` is canonical
- [ ] No `biome` when ESLint is the canonical linter

## 8. Documentation Accuracy

- [ ] No stale references to removed files or sections
- [ ] No broken links (internal or external)
- [ ] Cross-bundle references use the correct strategy (attribution-only,
  runtime content via `includeTree`, or intra-bundle relative links)
- [ ] The Context Declaration section lists all file paths, external
  resources, and project information

## Verdict

After checking all items:

- **CLEAN** — all items pass. Return `REVIEW_VERDICT:CLEAN`.
- **NEEDS_FIXES** — one or more items fail, but the fixes are within the
  upsert's scope. Return `REVIEW_VERDICT:NEEDS_FIXES` with a numbered list
  of failures and the specific fix for each.
- **BLOCKED** — one or more items fail and require human input (ambiguous
  convention, destructive change, missing credentials). Return
  `REVIEW_VERDICT:BLOCKED` with the blocker details.
