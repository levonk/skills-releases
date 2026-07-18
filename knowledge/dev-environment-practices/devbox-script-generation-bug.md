---
type: Practice
title: Devbox Script Generation Bug
description: Known devbox v0.14.x regression where script generation fails with "command not found". Workarounds include using just directly, devbox shell + *-internal targets, or version rollback to 0.13.7.
tags: [devbox, bug, workaround, script-generation, regression, troubleshooting]
timestamp: 2026-07-17T00:00:00Z
---

# Devbox Script Generation Bug

## Failure Mode

`devbox run <command>` fails with "command not found" error despite proper
`devbox.json` configuration. The generated script in
`.devbox/gen/scripts/.cmd.sh` fails to execute just commands.

### Symptoms

```bash
devbox run view-web
# Error: /path/to/.devbox/gen/scripts/.cmd.sh: line 7: view-web: command not found
```

### Root Cause

Known devbox regression bug introduced in v0.14.x series affecting script
generation. This is a confirmed upstream bug, not a configuration issue.

### Affected Versions

devbox 0.14.0, 0.14.2, 0.16.0 (and likely other 0.14.x+ versions)

### GitHub Issues

- #2517: `error: tool 'git' not found` after upgrading to 0.14.0
- #2108: Running script inside devbox shell throws `file not found` error
- #2607: Cannot run devbox script if another script is sourced in the init hook

## Practice

### Workaround 1: Use just Directly (Recommended)

Bypass broken devbox scripts entirely:

```bash
just view-web    # Instead of: devbox run view-web
just run         # Instead of: devbox run run
just export      # Instead of: devbox run export
```

### Workaround 2: devbox shell + *-internal (Most Reliable)

Enter devbox shell first, then use internal targets directly:

```bash
devbox shell
just view-web-internal
just run-internal
just bootstrap-internal
```

### Workaround 3: Version Rollback

```bash
export DEVBOX_USE_VERSION=0.13.7
devbox run view-web  # Now works
```

## Prevention

1. **Test devbox scripts after setup**: Verify `devbox run <script>` works for
   all scripts
2. **Prefer just commands**: Document `just <command>` as primary interface
3. **Add bug comments**: Include known bug reference in devbox.json files
4. **Monitor devbox issues**: Track upstream fixes for script generation regression

## Detection

```bash
devbox run --help       # Should show available scripts
devbox run <script>     # Test each script
just --list             # Shows available just targets
```

## Related Concepts

- [Internal vs Normal Targets](internal-vs-normal-targets.md) — Targets that
  work even when devbox scripts don't
- [Standard Developer UX Flow](standard-developer-ux-flow.md) — Flows that
  account for this bug

## Citations

[1] `internal-docs/adr/adr-20260131001-standard-developer-ux-flow.md` — levonk-base-boilerplate (Troubleshooting section)
