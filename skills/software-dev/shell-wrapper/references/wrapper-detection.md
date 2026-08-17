# Wrapper Detection

The wrapper script uses `cli-tool-discovery.sh` (materialized in `scripts/`)
to detect the environment wrapper for the current directory. This replaces a
devbox-only walk with support for five environment wrappers.

## Supported Wrappers

| Wrapper | Config file | Wrapper command | Shell env var (skip if set) |
|---------|-------------|-----------------|---------------------------|
| devbox | `devbox.json` | `devbox run --` | `DEVBOX_SHELL`, `IN_DEVBOX_SHELL` |
| mise | `.mise.toml`, `.mise/config.toml` | `mise exec --` | `MISE_SHELL` |
| flox | `flox.nix` | `flox activate --` | `FLOX_ACTIVE` |
| direnv | `.envrc` | `direnv export &&` | `DIRENV_DIR` |
| nix (flake) | `flake.nix` | `nix develop --command` | `IN_NIX_SHELL` |
| nix (shell) | `shell.nix` | `nix-shell --run` | `IN_NIX_SHELL` |

## The Probe Algorithm

The wrapper script calls `cli-tool-discovery.sh` with `--detect-wrapper` mode
to detect the environment wrapper for the current directory:

```bash
bash "$CLI_TOOL_DISCOVERY" --detect-wrapper
```

This mode checks config file existence + wrapper functionality **without**
requiring a specific tool to exist inside the wrapper. This is needed for
devbox: the normal resolve mode checks tool existence inside devbox
(`devbox run -- command -v <tool>`), which fails for probe/nonexistent tool
names. `--detect-wrapper` probes devbox with `devbox run -- true` (a
hang-safe, always-available shell builtin) instead.

The detection order:
1. **Already inside a wrapper shell** — if `DEVBOX_SHELL`, `MISE_SHELL`,
   `FLOX_ACTIVE`, `DIRENV_DIR`, or `IN_NIX_SHELL` is set, returns `NONE`
   (tools are already on PATH, no prefix needed)
2. **devbox** — if `devbox.json` exists up the tree and `devbox run -- true`
   succeeds (hang-safe probe), returns `WRAPPER: devbox run --`
3. **mise** — if `.mise.toml` / `mise.toml` exists up the tree, returns
   `WRAPPER: mise exec --`
4. **flox** — if `flox.nix` exists up the tree, returns `WRAPPER: flox activate --`
5. **nix** — if `flake.nix` / `shell.nix` exists up the tree, returns
   `WRAPPER: nix develop --command` or `WRAPPER: nix-shell --run`
6. **direnv** — if `.envrc` exists up the tree, returns `WRAPPER: direnv export &&`
7. **NONE** — if no wrapper is detected

The wrapper script extracts the wrapper command from the `WRAPPER:` response.
For example:
- `WRAPPER: devbox run --` → prefix `devbox run --`
- `WRAPPER: mise exec --` → prefix `mise exec --`

## Already-Inside-Shell Detection

If the agent is already inside a wrapper's interactive shell, the environment
is already loaded and the wrapper prefix would be redundant (and slower). The
wrapper script detects this via each wrapper's environment variables:

| Variable | Set by | Meaning |
|----------|--------|---------|
| `DEVBOX_SHELL` | `devbox shell` | Inside devbox interactive shell |
| `IN_DEVBOX_SHELL` | devbox (older) | Same, older variable name |
| `MISE_SHELL` | `mise shell` | Inside mise-managed shell |
| `FLOX_ACTIVE` | `flox activate` | Inside flox environment |
| `DIRENV_DIR` | `direnv` | direnv has loaded this directory |
| `IN_NIX_SHELL` | `nix-shell` | Inside a nix-shell |

If any of these is set for the detected wrapper, the wrapper prefix is
skipped. The rtk prefix is still applied if the command is supported.

## The Walk-Up Algorithm

`cli-tool-discovery.sh` walks up from the current directory looking for each
wrapper's config file:

```
cwd = current working directory
for each directory from cwd up to root:
    for each wrapper config file:
        if config file exists in this directory:
            return this wrapper
    if .git exists:           # reached repo root
        check this directory for config files
        stop — don't look above the repo
```

### Why stop at the repo root

A config file above the repo (e.g. in `~/`) is out of scope — it would define
an environment for a different project. The walk stops at the first `.git`
directory it finds, which is the repo root.

### Subdir roots

Config files may live in a subdirectory that is itself a project root (e.g.
a monorepo where each package has its own devbox.json). The walk handles this
correctly — it checks every directory from cwd upward, so a config file in
cwd is found before one in an ancestor.

## Fallback Behavior

If `cli-tool-discovery.sh` is missing (shouldn't happen in normal operation —
it's materialized at build time), the wrapper script:
- Falls back to `command -v rtk` for rtk detection
- Skips wrapper detection entirely (no wrapper prefix applied)

This ensures the script degrades gracefully rather than failing.

## Edge Cases

| Case | Behavior |
|------|----------|
| Config file in cwd | Used immediately |
| Config file in parent (no `.git` between) | Used (walk continues up) |
| Config file in repo root, cwd is a subdir | Used (walk reaches root) |
| Config file above repo root | NOT used (walk stops at `.git`) |
| Already inside wrapper shell | Prefix skipped (env vars detected) |
| Wrapper not on PATH | Prefix skipped silently |
| No config file anywhere in walk | Prefix skipped |
| `cli-tool-discovery.sh` missing | Fallback to `command -v rtk`, no wrapper |

## Sources

- Devbox: https://github.com/jetify-com/devbox
- mise: https://github.com/jdx/mise
- flox: https://github.com/flox/flox
- direnv: https://github.com/direnv/direnv
- Nix: https://nixos.org/
- cli-tool-discovery.sh: materialized in `scripts/` from
  `includes/cli-tool-discovery.sh.tmpl`
