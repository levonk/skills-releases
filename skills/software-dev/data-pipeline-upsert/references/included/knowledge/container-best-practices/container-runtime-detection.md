---
type: Practice
title: Container Runtime Detection and Multi-Runtime Portability
description: Auto-detect the container runtime in user-facing scripts (CONTAINER_RUNTIME env override → docker → podman → Apple container) instead of hardcoding docker. OrbStack, Docker Desktop, and colima need no special-casing — they ship a docker CLI symlink. Fully-qualify image names as docker.io/... for podman and Apple container whose short-name resolution prompts or fails, and confine per-runtime quirks (Apple container system bootstrap, --mount bind syntax, directory-only bind mounts, non-combinable short flags) to argument construction, not the whole command.
tags: [container, docker, podman, apple-container, orbstack, colima, docker-desktop, runtime-detection, portability, bind-mount, shell-script]
date:
  created: "2026-10-17"
  knowledge-basis: "2026-10-17"
  last-used: "2026-10-17"

sources:
  - id: infrahub-edit-vault-multi-runtime
    resource: "https://github.com/levonk/infrahub/commit/8c32a84bb4eee9be6f60bd7afd5905668153ab5c"
    title: "infrahub@8c32a84b — vault: support podman and Apple container in edit-vault.sh (scripts/edit-vault.sh + AGENTS.md)"
  - id: apple-container-repo
    resource: "https://github.com/apple/container"
    title: "Apple container — macOS containerization CLI (system service, --mount syntax, directory-only binds)"
  - id: containers-shortnames
    resource: "https://github.com/containers/shortnames"
    title: "containers/shortnames — Podman short-name resolution (why unqualified names prompt or fail)"
---

# Container Runtime Detection and Multi-Runtime Portability

## Failure Mode

A helper script hardcodes `docker` and dies with `docker not found` on any
machine where the runtime is podman (RHEL/Fedora standard, daemonless) or
Apple `container` (macOS). The script itself only needs the portable CLI
subset — `run`, `ps`, `exec`, `logs` — so the hard failure is self-inflicted.

The inverse trap: enumerating every Docker-compatible runtime in the
detection list (OrbStack, Docker Desktop, colima, Rancher Desktop). This is
unnecessary — all of them install a `docker` CLI symlink, so a `docker`
probe already covers them. Only runtimes with a *different* binary name
belong in the probe list.

## Detection Order

```
CONTAINER_RUNTIME set?  →  yes → validate with command -v, use it
                        no  →  probe in order: docker → podman → container
                               none found → error naming what was tried
```

```bash
CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-}"
if [ -n "$CONTAINER_RUNTIME" ]; then
    if ! command -v "$CONTAINER_RUNTIME" >/dev/null 2>&1; then
        echo "ERROR: CONTAINER_RUNTIME='$CONTAINER_RUNTIME' not found in PATH" >&2
        exit 1
    fi
else
    for rt in docker podman container; do
        if command -v "$rt" >/dev/null 2>&1; then
            CONTAINER_RUNTIME="$rt"
            break
        fi
    done
    if [ -z "$CONTAINER_RUNTIME" ]; then
        echo "ERROR: no container runtime found (tried: docker, podman, container)" >&2
        exit 1
    fi
fi
```

Why this order:

- **`CONTAINER_RUNTIME` override first** — the user knows their machine;
  validate the override instead of silently ignoring a typo.
- **`docker` next** — covers Docker Engine plus every docker-compatible
  desktop runtime (OrbStack, Docker Desktop, colima) via their `docker` CLI
  shim.
- **`podman`** — the common alternative on Linux.
- **`container` last** — Apple's macOS-only runtime; newest and most
  divergent CLI.

## Qualify Image Names for Non-Docker Runtimes

Docker assumes `docker.io` for unqualified image names; podman and Apple
`container` do not. Podman's short-name mode can **prompt interactively**
for a registry (hangs a headless script) or fail outright. Rule: when the
runtime is not docker and the image's first path component contains no `.`
and no `:` and is not `localhost`, prepend `docker.io/`:

```bash
case "$CONTAINER_RUNTIME" in
    podman|container)
        case "${IMAGE%%/*}" in
            *.*|*:*|localhost) ;;          # already qualified
            *) IMAGE="docker.io/$IMAGE" ;;
        esac
        ;;
esac
```

The `*.*`/`*:*` test is the standard heuristic: a registry component always
has a dot (`ghcr.io`) or a port (`localhost:5000`); a bare name like
`alpine/ansible` has neither.

## Per-Runtime Adapters: Keep Quirks in Argument Construction

Resolve the runtime once, then build a per-runtime **argument array** and
`exec` a single generic command. Do not fork the entire invocation per
runtime — that duplicates the command text and guarantees drift.

```bash
case "$CONTAINER_RUNTIME" in
    container)
        # Apple container needs its helper service up.
        if ! container system status >/dev/null 2>&1; then
            container system start --enable-kernel-install
        fi
        # Directory-only binds: mount the file's parent dir.
        MOUNT_ARGS=(--mount "type=bind,source=$HOST_DIR,target=/dir,readonly")
        CONTAINER_PATH="/dir/$BASENAME"
        ;;
    *)
        MOUNT_ARGS=(-v "$HOST_FILE:/file:ro")
        CONTAINER_PATH="/file"
        ;;
esac

exec "$CONTAINER_RUNTIME" run --rm $TTY_FLAGS "${MOUNT_ARGS[@]}" "$IMAGE" ...
```

### Apple `container` quirks (all discovered in real use)

- **Bootstrap**: the `container` CLI fronts a system service. Check
  `container system status`; if down, `container system start
  --enable-kernel-install` starts it and installs the needed kernel.
- **Mount syntax**: use `--mount type=bind,source=…,target=…[,readonly]`.
  Its `-v` read-only suffix is not documented.
- **Directory-only bind mounts**: on the tested version it cannot
  bind-mount a single file (newer releases may lift this — verify before
  relying on file binds). Mount the file's **parent directory** and compute
  the in-container path as `<mount-target>/<basename>`. If two needed files
  live in different directories, emit two `--mount` args.
- **No combined short flags**: its argument parser does not combine shorts —
  emit `-i -t`, not `-it`.

### TTY flags

Emit `-i -t` only when stdin is a terminal (`[ -t 0 ]`). Interactive
subcommands (edit, rekey, shell) need a TTY; non-interactive ones (view,
run-once) don't — and a forced `-t` breaks non-TTY callers like CI.

## When to Apply

- **User-facing handoff commands** — any "paste this command" an agent
  hands a user (vault editors, one-shot tools) must run on whatever runtime
  the user's machine has.
- **Repo scripts shared across heterogeneous dev machines** — macOS laptops
  on OrbStack/Docker Desktop/Apple `container`, Linux on docker/podman.
- **AGENTS.md / runbooks** — point the handoff at the wrapper script, not a
  raw `docker run` incantation, so the runtime story lives in one place.

Do **not** apply when the runtime is fixed by construction: inside a
container, in CI with a provisioned runtime, or when the script needs
runtime-specific features (buildx, compose v2) — there, hardcode and
require the real dependency.

## Related

- [Container Runtime Essentials](container-runtime-essentials.md) — the
  build-strategy decision tree; this page is the runtime-*selection* analog
  for scripts that run (not build) containers.
- [Volume Ownership Init for Non-Root Containers](volume-ownership-init.md)
  — the "mount the directory, not the file" rule (atomic-replace writes)
  converges with Apple container's directory-only bind constraint; both
  land on the same parent-dir mount pattern.
- [Container Runtime Hardening](container-runtime-hardening.md) — the
  hardening flags (non-root, cap-drop, read-only, no-new-privileges) are
  part of the portable CLI subset and apply unchanged across runtimes.
- [Deterministic Image Versioning](image-versioning.md) — the `.version`
  file approach is portable across Docker/Podman/Buildx/Nix for the same
  reason this page exists: don't assume docker.
