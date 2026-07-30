# OKF Version Self-Check

When the `ai-upsert` skill enters the knowledge bundle path (create or update),
it must first confirm it still targets the latest OKF spec. OKF is a living
format; the canonical spec at
<https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md>
can be updated between skill releases. Creating or updating bundles against an
out-of-date spec would produce stale or non-conformant output.

The `okf-supported-version` key in `SKILL.md.tmpl` frontmatter records the OKF
version this skill was built against. Agents running the skill read that key,
fetch the current spec, and compare before proceeding.

## When to run the check

- **Run** when the skill is about to create or update an OKF knowledge bundle.
- **Do not run** when the skill is creating or updating a skill, workflow,
  agent file, prompt, template, rule, or README. OKF version is irrelevant to
  those artifact types.
- **Does not affect the skill-vs-bundle decision.** Whether the user needs a
  skill or a knowledge bundle depends on the nature of the artifact (executable
  procedure vs compounding reference knowledge), not on which OKF version is
  current.

## Procedure

1. **Read the current supported version from this skill's frontmatter.**
   Extract `okf-supported-version` from `SKILL.md` (built) or `SKILL.md.tmpl`
   (source). Example: `"0.2"`.

2. **Fetch the canonical spec.** Use the raw GitHub URL:
   ```text
   https://raw.githubusercontent.com/GoogleCloudPlatform/knowledge-catalog/main/okf/SPEC.md
   ```
   Or read the rendered page:
   ```text
   https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md
   ```

3. **Parse the version.** The spec version appears near the top, typically as:
   ```markdown
   # Open Knowledge Format (OKF)

   **Version 0.2**
   ```
   Extract the `MAJOR.MINOR` string (e.g., `0.2`).

4. **Compare.**
   - If `fetched_version > okf-supported-version` (e.g., spec is `0.3` and skill
     supports `0.2`), **stop** and update the skill before creating/updating any
     bundle.
   - If `fetched_version == okf-supported-version`, proceed.
   - If `fetched_version < okf-supported-version` (spec reverted or forked),
     proceed but note the discrepancy to the user.

5. **Self-update when a newer version exists.**
   1. Alert the user: "OKF `X.Y` is newer than the `ai-upsert` skill's supported
      `okf-supported-version`. Updating the skill first."
   2. Follow `.agents/workflows/skill-src-upsert.md`:
      - Read `AGENTS.md` for the repository.
      - Update `references/knowledge/okf-spec.md` and other knowledge-bundle
        reference files with the new spec contents.
      - Bump `okf-supported-version` in `src/current/skills/ai/ai-upsert/SKILL.md.tmpl`
        to the fetched version.
      - Update any workflow steps, examples, or conformance checks affected by
        the new version.
      - Run `just validate` and `just build current`.
   3. Re-read the updated `build/current/skills/ai/ai-upsert/SKILL.md` and
      restart the knowledge bundle create/update workflow.

## Edge cases

- **Network failure or unavailable spec**: Proceed with `okf-supported-version`
  as the best known version and warn the user that the version check could not
  be completed.
- **Malformed version in spec**: If the version cannot be parsed, treat as
  unverified and proceed with `okf-supported-version`, warning the user.
- **Prerelease or draft versions**: Use strict semver-ish comparison on
  `<major>.<minor>`. Ignore prerelease tags for the go/no-go decision unless the
  user explicitly requests bleeding-edge support.

## Reference

- Canonical OKF spec: <https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md>
- OKF v0.2 details: `references/knowledge/okf-spec.md`
- v0.1 → v0.2 migration: `references/knowledge/okf-spec.md` § "Versioning and migration from v0.1"
