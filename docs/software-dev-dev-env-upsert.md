<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **software-dev** · Status:  · Version: 1.0.0

Manage devbox.json + .envrc + justfile as a coupled trio per the Standard Developer UX Flow (`direnv → devbox → just (*_impl) → [build tool]`). Use when adding/removing devbox packages, generating or updating .envrc, adding lines to prime_impl in the justfile, or reconciling devbox config with detected project stack. Triggers on 'add devbox package', 'update devbox', 'set up direnv', 'configure envrc', 'dev env upsert', 'add indexed AST tool', or 'add code indexer to prime'. Do NOT trigger on general devbox usage questions, Nix flake packaging (use nixify), or justfile target creation from scratch (use project-adopter for new targets).

## Metadata

| Field | Value |
|-------|-------|
| Name | `dev-env-upsert` |
| Category | `software-dev` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Quick Start

All operations run through the single script `scripts/dev_env_upsert.py` via
`uv run --script`. The AI agent decides WHAT to add (based on project
detection), then hands the full config to the script in ONE call. The script
loops internally — no AI↔script back-and-forth per package.

```bash
# setup — primary operation: does everything in one call
# (add-packages + add-prime-steps + update-envrc)
uv run --script scripts/dev_env_upsert.py setup \
    --packages codegraph,direnv,just \
    --prime-steps "codegraph index .:codegraph" \
    --envrc-async-prime \
    --target .

# add-packages — loop over `devbox add` internally
uv run --script scripts/dev_env_upsert.py add-packages --packages a,b,c --target .

# remove-packages — loop over `devbox remove` internally
uv run --script scripts/dev_env_upsert.py remove-packages --packages a,b,c --target .

# add-prime-steps — file-type-aware; folds indexer into prime_impl
uv run --script scripts/dev_env_upsert.py add-prime-steps \
    --prime-steps "codegraph index .:codegraph" --target .

# update-envrc — regenerate direnv block + append async prime_impl trigger
uv run --script scripts/dev_env_upsert.py update-envrc --async-prime --target .

# reconcile — detect stack, suggest packages
uv run --script scripts/dev_env_upsert.py reconcile --target .

# validate — check devbox.json + .envrc + justfile prime_impl integrity
uv run --script scripts/dev_env_upsert.py validate --target .
```

## References

- `references/dev-env-coupling.md` — why the trio is managed together, the
  drift problem.
- `references/indexed-ast-tool-setup.md` — canonical recipe for adding
  CodeGraph/Graphify/GitNexus via dev-env-upsert.
- `EXAMPLES.md` — worked examples (CodeGraph on Rust, GitNexus on multi-repo,
  Graphify on docs).

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types
- **nixify** (skill, alternative-approach) — Nix flake packaging for remote install — dev-env-upsert uses devbox for local dev environments
- **project-adopter** (skill, consumer) — Delegates devbox.json + .envrc + justfile trio management to this skill
- **project-detection** (skill, dependency) — Used by reconcile to detect project stack and suggest packages
- **** (, dependency) — Materialized via includeTree — the Standard Developer UX Flow, async-prime-internal, index-staleness-check concept pages

---

- **Full skill**: [`skills/software-dev/dev-env-upsert/SKILL.md`](skills/software-dev/dev-env-upsert/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-09-02T09:14:22Z
