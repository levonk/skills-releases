---
type: Practice
title: Volume Ownership Init for Non-Root Containers
description: Initialize Docker volume ownership with a three-phase pattern (chown + in-container verify, then fresh-container verify) before starting any non-root container that writes to a volume. Catches Docker Desktop WSL2 volume driver persistence failures where chown exits 0 but ownership does not persist to the volume's backing store. Also covers the entrypoint wrapper image pattern — a thin wrapper that starts as root, chowns the volume, verifies, then drops to non-root and execs the original entrypoint, making the container self-healing on every restart. Includes the implemented `localnet-volume-init` parameterized utility container and the reusable `localnet-volume-init` Ansible role that wraps the three-phase pattern with intelligent defaults (mount=/data, uid=1000, gid=1000, mode=755) and multi-volume spec support.
tags: [docker, volume, ownership, permissions, non-root, init-container, chown, verify, docker-desktop, wsl2, ansible, crash-loop, entrypoint-wrapper, su-exec, gosu, privilege-drop]
date:
  created: "2026-08-23"
  knowledge-basis: "2026-08-23"
  last-used: "2026-08-23"

sources:
  - id: adr-20260822001-volume-ownership-init-pattern
    resource: "https://github.com/levonk/infrahub/blob/main/shared/active/08-docs/adr/adr-20260822001-volume-ownership-init-pattern.md"
    title: "ADR-20260822001: Docker Volume Ownership Init Pattern for Non-Root Containers"
  - id: docker-volumes-docs
    resource: "https://docs.docker.com/storage/volumes/"
    title: "Docker Storage — Volumes (default root ownership, driver semantics)"
  - id: docker-engine-security-userns-remap
    resource: "https://docs.docker.com/engine/security/userns-remap/"
    title: "Docker Engine security — Isolate containers with a user namespace (why userns-remap does not solve volume ownership)"
---

# Volume Ownership Init for Non-Root Containers

## Failure Mode

Docker volumes created by `docker volume create` (or implicitly by `docker run
-v <volume>:/path`) are owned by **root (UID 0, GID 0)** by default — on every
Docker platform (Linux, Docker Desktop for Mac, Docker Desktop for Windows on
WSL2). A service container that runs as a non-root user (e.g. `--user
1000:1000`, the standard for any image following
[Container Runtime Hardening](container-runtime-hardening.md)) cannot write to
the volume. The first write fails with `permission denied`, the process exits,
Docker restarts it, it fails again — a **crash loop** that never recovers
because the volume ownership is never fixed by the restart.

The trap is that the obvious fix — `chown` the volume before the service
starts — can **appear to succeed and still not persist**. On Docker Desktop
for Windows (WSL2 backend), the `chown` runs inside the throwaway container's
mount namespace and exits 0, but the ownership change may not propagate to the
volume's backing store (virtiofs/9p bridge quirks). A second container that
mounts the same volume sees the old root ownership. The playbook reports
success, the service container starts, and it crash-loops anyway.

## Symptoms

- A non-root service container crash-loops on first deploy with `permission
  denied` writing to its data directory (e.g. `open /app/data/.secret_key:
  permission denied`).
- The Ansible/task that `chown`s the volume reports `rc=0` (success), but
  `docker run --rm -v <volume>:/data alpine ls -la /data` still shows `0 0`
  (root ownership).
- The same role works on Linux/OCI hosts (where `ansible.builtin.file` with
  `owner`/`group` reaches the mountpoint directly) but fails on Docker Desktop
  for Windows.
- A `chown` that worked in one throwaway container is not visible to a
  *different* throwaway container mounting the same volume — the change did
  not persist to the backing store.

## Practice

Every deployment that starts a non-root container with a writable Docker
volume MUST run a **three-phase volume initialization** before the service
container starts. The three phases produce a diagnostic matrix that pinpoints
exactly where a failure occurred, instead of collapsing every failure mode
into "chown ran, we don't know if it worked."

### Phase 1 — Fix ownership + in-container verify

Run a throwaway `alpine` container that mounts the volume, `chown`s it to the
target UID:GID, and **immediately verifies** the ownership from within the
same container's mount namespace. If the in-container verify fails, the chown
itself did not take effect even within the container's own VFS view — this is
an overlay/filesystem issue, not a persistence issue.

```bash
docker run --rm -v <volume>:/data alpine sh -c '
  chown -R 1000:1000 /data
  && chmod 755 /data
  && test "$(stat -c %u /data)" = "1000"
  && test "$(stat -c %g /data)" = "1000"
'
```

### Phase 2 — Fresh-container verify

Run a **second** throwaway `alpine` container that mounts the same volume in a
fresh mount namespace and checks that the ownership actually persisted. This
catches Docker Desktop WSL2 volume driver quirks where the chown took effect
inside the Phase 1 container but did not propagate to the volume's backing
store.

```bash
docker run --rm -v <volume>:/data alpine sh -c '
  test "$(stat -c %u /data)" = "1000"
  && test "$(stat -c %g /data)" = "1000"
'
```

### Phase 3 — Service container starts

Only if both verifications pass does the service container start. If either
verification fails, the playbook stops with a diagnostic message indicating
which phase failed and what that means — no crash loop.

### Diagnostic matrix

The two verification layers catch **different classes of failure**. Without
the in-container verify (Phase 1), the persistence failure (Phase 1 PASS,
Phase 2 FAIL) is indistinguishable from "chown ran but we don't know if it
worked."

| Phase 1 (chown) | Phase 1 (in-container verify) | Phase 2 (fresh-container verify) | Diagnosis | Action |
|------------------|-------------------------------|-----------------------------------|-----------|--------|
| `rc=0` | PASS | PASS | Everything worked | Proceed to service container |
| `rc=0` | PASS | **FAIL** | **Volume driver persistence failure** — chown took effect inside the container's mount namespace but did not persist to the backing store (Docker Desktop WSL2 quirk) | Stop any crash-looping containers, re-run chown, or recreate the volume (see Recovery below) |
| `rc=0` | **FAIL** | (not reached) | **Chown ineffective within same namespace** — overlay filesystem issue or read-only mount that silently ignores ownership changes | Check if the volume is mounted read-only, check Docker storage driver, check for overlay2 upper-layer corruption |
| `rc!=0` | (not reached) | (not reached) | **Chown command itself failed** — permission denied on the volume, volume does not exist, or filesystem error | Check volume exists, check Docker daemon health, check disk space |

### Why alpine for the throwaway container

- **Size**: ~7 MB, already cached on every Docker host in a mixed fleet.
- **Speed**: Starts in under 1 second.
- **Universality**: Available on all architectures (x86_64, aarch64) per the
  multi-arch mandate in
  [Container Runtime Essentials](container-runtime-essentials.md).
- **Sufficiency**: Has `sh`, `chown`, `chmod`, `ls`, `stat`, `test` —
  everything needed for volume init and verification.
- **No registry dependency**: Using plain `alpine` avoids a chicken-and-egg
  dependency on a local registry that might itself have a volume ownership
  problem. A custom utility container built from a local base image is a
  future enhancement (see below), not the baseline.

### Task ordering within the deployment

The volume init pair MUST run in this order, after the volume exists and
before the service container starts:

1. Ensure volume exists (`docker volume inspect || docker volume create`)
2. Fix + in-container verify (Phase 1)
3. Fresh-container verify (Phase 2)
4. Pull service image
5. Stop existing container (`docker rm -f || true`)
6. Deploy service container (`docker run -d ...`)
7. Wait for health

If either phase fails, the playbook stops before step 4 — the service
container is never started, so there is no crash loop.

### When to apply this pattern

| Condition | Apply volume init? |
|-----------|-------------------|
| Container runs as non-root (`--user <uid>:<gid>` where uid != 0) and has a writable volume | **YES** — mandatory |
| Container runs as root | No — root can write to root-owned volumes |
| Container has a read-only volume (`:ro`) | No — no writes needed |
| Container uses a bind mount (not a Docker volume) | Use `ansible.builtin.file` on the host path instead (works on Linux/OCI; on Windows, the host directory's ownership is managed by Windows ACLs, not Unix permissions — this pattern covers Docker volumes only) |
| Container has no volumes | No — nothing to init |
| Volume already has correct ownership from a previous run | The chown is idempotent, so running it again is harmless; the verify confirms it |

## Ansible task pair (standard form)

Every role that deploys a non-root container with a writable volume SHOULD
include this task pair (adapt variable names to the role's convention). The
example uses `delegate_to: localhost` with `DOCKER_HOST` set via SSH for
Windows Docker Desktop hosts where `community.docker` modules cannot run
(they import `grp`, which is Unix-only).

> **Preferred form**: When the `localnet-volume-init` Ansible role is
> available (see [Implemented: Parameterized Utility Container + Reusable
> Ansible Role](#implemented-parameterized-utility-container--reusable-ansible-role)
> below), use `include_role: name: localnet-volume-init` instead of
> hand-stitching this task pair. The role handles Phase 0 (volume create) +
> Phase 1 + Phase 2, the `DOCKER_HOST` / `delegate_to` boilerplate, and
> multi-volume specs with per-volume uid/gid/mode. The inline form below is
> the mandated baseline and remains valid for simple single-volume
> deployments or when the utility container image is not yet built.

```yaml
# Phase 1: Fix ownership AND verify within the same container's mount namespace.
- name: "Fix {{ service_name }} volume ownership (UID {{ service_uid }})"
  ansible.builtin.command: >-
    docker run --rm
    -v {{ service_data_volume }}:/data
    alpine sh -c 'chown -R {{ service_uid }}:{{ service_gid }} /data
    && chmod {{ service_mode | default("755") }} /data
    && test "$(stat -c %u /data)" = "{{ service_uid }}"
    && test "$(stat -c %g /data)" = "{{ service_gid }}"'
  environment:
    DOCKER_HOST: "{{ service_docker_host }}"
  delegate_to: localhost
  changed_when: false
  tags: ["deploy", "volume"]

# Phase 2: Fresh-container verify — mount the volume in a NEW container and
# check that the ownership persisted to the volume's backing store.
- name: "Verify {{ service_name }} volume ownership persisted (UID {{ service_uid }})"
  ansible.builtin.command: >-
    docker run --rm
    -v {{ service_data_volume }}:/data
    alpine sh -c 'test "$(stat -c %u /data)" = "{{ service_uid }}"
    && test "$(stat -c %g /data)" = "{{ service_gid }}"'
  environment:
    DOCKER_HOST: "{{ service_docker_host }}"
  delegate_to: localhost
  register: volume_ownership_check
  changed_when: false
  failed_when: volume_ownership_check.rc != 0
  tags: ["deploy", "volume"]
```

`changed_when: false` marks the chown as idempotent — running it on an
already-correct volume changes nothing and keeps playbook output clean.

## Why both verification steps are critical

**Phase 1 in-container verify** catches:
- Overlay filesystem issues where `chown` exits 0 but the VFS layer does not
  reflect the change even within the same container.
- Read-only mounts that silently ignore ownership changes.
- Filesystem corruption at the overlay upper layer.

**Phase 2 fresh-container verify** catches:
- **Docker Desktop volume driver persistence failure** — the chown took
  effect inside the Phase 1 container's mount namespace (Phase 1 verify
  passed), but did not persist to the volume's backing store. When Phase 2's
  fresh container mounts the volume, it sees the old ownership. This is the
  quirk that causes the "chown succeeded but container still crash-loops"
  class of bug.
- Race conditions where a crash-looping container's writes interfere with the
  chown between Phase 1 and Phase 2.
- Wrong volume name (if Phase 1 and Phase 2 use different variables due to a
  typo, Phase 2 sees the unfixed volume).

## Signal to upstream image authors

The in-container verify also serves as a **signal to upstream Docker image
authors**: if an image starts as root, `chown`s its data directory, then drops
to a non-root user via `gosu`/`su-exec`, the chown and the subsequent write
happen in the same mount namespace — so a chown that works in-container will
work for the service. This is the **upstream-correct pattern** used by
Postgres, MySQL, Redis, and other mature images.

Images that skip this pattern and start directly as a non-root user cannot
self-fix: they are already non-root when they try to write, so they cannot
`chown` the volume. The three-phase init pattern in this concept is the
**infrastructure-side workaround** for images that do not implement the
start-as-root-then-drop pattern.

**The diagnostic signal**: if Phase 1's in-container verify passes but Phase
2's fresh-container verify fails, and the service container then crash-loops,
this is strong evidence that the image should be fixed upstream to start as
root, `chown` the data directory in its entrypoint, and then drop to the
non-root user — rather than relying on the infrastructure to pre-fix the
volume. File an upstream issue with this recommendation.

## Alternative Pattern: Entrypoint Wrapper Image

### The gap between infrastructure-side fix and upstream fix

The three-phase init pattern (chown + verify before container start) is an
**infrastructure-side workaround**: it fixes the volume before the service
container sees it. This works, but it has a structural limitation — the fix
happens *outside* the service container's lifecycle. If the volume is ever
recreated manually (e.g., `docker volume rm && docker volume create`), the
service container will crash-loop on next start unless the init pattern is run
again.

The **upstream-correct fix** is for the image itself to start as root,
`chown` the data directory, then drop to the non-root user — the Postgres /
MySQL / Redis pattern. But we don't control upstream images.

The **entrypoint wrapper image** bridges this gap: build a thin wrapper image
that `FROM`s the upstream image, injects an entrypoint script that does the
chown-then-drop-to-non-root dance, and `exec`s the original entrypoint. This
makes the service container self-healing — it fixes its own volume on every
start, not just when Ansible runs.

### When to use the wrapper pattern vs the init pattern

| Factor | Three-phase init (alpine chown) | Entrypoint wrapper image |
|--------|---------------------------------|--------------------------|
| Who fixes the volume? | Ansible, before container starts | Container itself, on every start |
| Volume recreated manually? | Crash loop until Ansible re-runs | Self-heals on next container start |
| Container starts as root? | No — container starts as non-root | Yes — briefly, then drops to non-root |
| Upstream image modified? | No | No — wrapper is a separate image |
| Build required? | No (uses public alpine) | Yes (wrapper Dockerfile + build) |
| Complexity | Low (2 Ansible tasks) | Medium (Dockerfile + entrypoint script + build pipeline) |
| Verification | Two separate containers | Built into entrypoint, can verify before dropping |
| Best for | First-time deploy, simple services | Services that may be restarted without Ansible, services with complex volume layouts |

**Recommendation**: Use the three-phase init pattern as the **baseline** for
all non-root containers with volumes (it is mandatory). Add the entrypoint
wrapper pattern **in addition** for services that:
- May be restarted without Ansible (e.g., `docker restart` by an operator)
- Have multiple volumes that all need ownership fixes
- Are deployed to hosts where Ansible doesn't run frequently
- Have upstream images that are unlikely to add the chown-then-drop pattern

### Wrapper image design

The wrapper `FROM`s the upstream image, installs `su-exec` (Alpine's `gosu`
equivalent), and overrides only the `ENTRYPOINT` — `CMD` is inherited from
the upstream image so auto-start and `docker restart` work without special
invocation:

```dockerfile
# Wrapper image for a service that runs as UID 1000 from ENTRYPOINT and
# cannot chown its own data directory. This wrapper starts as root, chowns
# the volume, verifies the chown, then drops to UID 1000 and execs the
# original entrypoint.
FROM ghcr.io/asciimoo/hister:latest

# Install su-exec (Alpine's gosu equivalent) for privilege dropping.
RUN apk add --no-cache su-exec

# Copy the wrapper entrypoint script
COPY assets/static/hister-wrapper/entrypoint-wrapper.sh /usr/local/bin/entrypoint-wrapper.sh
RUN chmod +x /usr/local/bin/entrypoint-wrapper.sh

# Reset the entrypoint — the wrapper script will exec the original.
# CMD is inherited from the upstream image — this is critical for auto-start.
ENTRYPOINT ["/usr/local/bin/entrypoint-wrapper.sh"]
```

### Why override ENTRYPOINT in the Dockerfile, not CMD or runtime

There are three ways to inject the wrapper script, and only one preserves
auto-start:

| Approach | Auto-start? | Problem |
|----------|-------------|---------|
| **Override ENTRYPOINT in Dockerfile** (this pattern) | **Yes** — `docker run -d wrapper:latest` just works; wrapper receives original CMD as `"$@"` and execs it | Requires building a wrapper image |
| Override CMD in Dockerfile | **No** — original ENTRYPOINT (if set) runs first and may not pass args correctly; hardcodes the original command, breaking on upstream CMD changes | Fragile, breaks on upstream updates |
| Override at runtime (`docker run --entrypoint ...`) | **No** — every `docker run` invocation must know and pass the original command; breaks `docker restart`, `docker-compose up`, and any tool that starts containers with default args | Every start must be special-cased |

Docker's ENTRYPOINT+CMD split is designed for exactly this use case.
ENTRYPOINT is the fixed part (the wrapper logic), CMD is the variable part
(the service's default command). By overriding only ENTRYPOINT in the wrapper
Dockerfile and inheriting CMD from the upstream image:

1. **Auto-start works**: `docker run -d wrapper:latest` starts the container
   with no extra args. The wrapper runs, fixes the volume, drops privileges,
   and execs the original CMD.
2. **`docker restart` works**: Docker restarts the container with the same
   config (ENTRYPOINT + CMD from the image). No special invocation needed.
3. **Upstream CMD changes are picked up**: When the upstream image updates
   its CMD, rebuilding the wrapper inherits the new CMD automatically.
4. **Operators can still override CMD**: `docker run wrapper:latest
   <custom-cmd>` passes `<custom-cmd>` as `"$@"` to the wrapper, which execs
   it as the non-root user.

### Entrypoint wrapper script

The wrapper runs as root (the container is started without `--user`), chowns
the data directory, verifies the chown in-container, then drops to the
non-root user via `su-exec` and execs the original entrypoint:

```bash
#!/bin/sh
set -eu

# Configuration — must match the upstream image's non-root user.
SERVICE_UID="${SERVICE_UID:-1000}"
SERVICE_GID="${SERVICE_GID:-1000}"
DATA_DIR="${DATA_DIR:-/hister/data}"

# Phase 1: Fix ownership
chown -R "${SERVICE_UID}:${SERVICE_GID}" "$DATA_DIR" || {
    echo "ERROR: chown failed" >&2; exit 1
}
chmod 755 "$DATA_DIR" || { echo "ERROR: chmod failed" >&2; exit 1; }

# Phase 1.5: In-container verify — catches overlay/fs issues
ACTUAL_UID=$(stat -c %u "$DATA_DIR")
ACTUAL_GID=$(stat -c %g "$DATA_DIR")
if [ "$ACTUAL_UID" != "$SERVICE_UID" ] || [ "$ACTUAL_GID" != "$SERVICE_GID" ]; then
    echo "ERROR: In-container verify failed! Expected ${SERVICE_UID}:${SERVICE_GID}, got ${ACTUAL_UID}:${ACTUAL_GID}" >&2
    echo "This is an overlay/filesystem issue, not a persistence failure." >&2
    exit 1
fi

# Phase 2: Drop privileges and exec original entrypoint.
# "$@" is the original CMD from the upstream image (passed through by Docker
# because we reset ENTRYPOINT and kept CMD).
exec su-exec "${SERVICE_UID}:${SERVICE_GID}" "$@"
```

`su-exec` (Alpine) / `gosu` (Debian) is used instead of `su` or `sudo`
because it uses `execve()` to replace the current process — signals
(SIGTERM, SIGINT) propagate correctly to the service. If PID 1 were `su` or
`sudo` instead of the service, Docker's SIGTERM might be ignored and Docker
falls back to SIGKILL after the grace period, causing unclean shutdowns.

### Security analysis: transient root context

The wrapper container starts as root, which appears to violate the non-root
policy in [Container Runtime Hardening](container-runtime-hardening.md).
However, the root context is **transient and scoped**:

1. **Duration**: The container runs as root only for the duration of the
   `chown` + `verify` (~0.1 seconds on a typical volume). After `exec
   su-exec`, PID 1 is the service running as UID 1000.
2. **Scope**: Root is needed only for `chown` on the data directory. The
   wrapper script performs no other root operations — no package installs,
   no network operations, no writes outside the data directory.
3. **Capabilities**: The container should still be started with
   `--security-opt no-new-privileges:true` and `--cap-drop ALL`. The `chown`
   syscall does not require any extra capabilities beyond what root UID
   provides.
4. **Comparison to upstream-correct images**: Postgres, MySQL, and Redis all
   use this exact pattern (start as root, chown, drop to non-root). This is
   the industry-standard approach for images that need to fix volume
   ownership on startup.
5. **Verification before drop**: The in-container verify runs **before**
   `su-exec`. If the chown fails, the wrapper exits as root with an error —
   it does not drop to non-root and then crash-loop.

### Ansible deployment with the wrapper image

When using the wrapper image, the Ansible role changes: deploy the wrapper
image **without** `--user` (the wrapper handles privilege dropping). The
three-phase init is still run as a safety net — the wrapper makes the
container self-healing, but the init ensures the volume is correct even if
the wrapper's chown fails for any reason.

```yaml
- name: Deploy service container (wrapper image)
  ansible.builtin.shell: >-
    docker run -d
    --name {{ service_container_name }}
    --restart unless-stopped
    --security-opt no-new-privileges:true
    --cap-drop ALL
    -v {{ service_data_volume }}:/hister/data
    {{ local_registry | default('') }}localnet-hister-wrapper:latest
  environment:
    DOCKER_HOST: "{{ service_docker_host }}"
  delegate_to: localhost
```

Key differences from the non-wrapper deployment:
- **No `--user 1000:1000`**: The wrapper handles privilege dropping. Passing
  `--user` would prevent the wrapper from chowning because it would already
  be non-root.
- **No `--entrypoint` or command args needed**: The wrapper image bakes the
  entrypoint override into the Dockerfile and inherits CMD from upstream.
- **`--security-opt no-new-privileges:true` and `--cap-drop ALL`** are still
  set — the transient root context doesn't need extra capabilities.
- **The three-phase init is still run before the container starts** as
  defense-in-depth.

### When NOT to use the wrapper pattern

- **The upstream image already does chown-then-drop** (Postgres, MySQL,
  Redis, etc.) — the wrapper would be redundant.
- **The service doesn't use volumes** — no ownership to fix.
- **The service runs as root by design** (e.g., some monitoring agents that
  need root for system access) — no privilege drop needed.
- **The upstream image is not Alpine-based** — `su-exec` is Alpine-specific.
  For Debian-based images, use `gosu` instead (`RUN apt-get install -y
  gosu`). For images without a package manager (distroless), the wrapper
  pattern requires a multi-stage build to inject `gosu`/`su-exec`.

## Recovery procedures

### If Phase 1 failed (in-container verify failed)

The chown did not take effect even within the same container. This is NOT a
persistence issue. Check:

1. Is the volume mounted read-only? (`docker run --rm -v <vol>:/data alpine
   mount | grep /data`)
2. Is the Docker storage driver corrupted? (`docker info | grep "Storage
   Driver"`)
3. Is the volume a remote/NFS volume with different ownership semantics?

### If Phase 2 failed (fresh-container verify failed) — persistence failure

This is the Docker Desktop WSL2 volume driver quirk. The chown worked inside
the Phase 1 container but did not persist to the volume's backing store.

1. **Check what the volume actually looks like:**
   ```bash
   docker run --rm -v <volume-name>:/data alpine ls -la /data
   ```
   If the UID/GID columns show `0 0`, the chown did not take effect.

2. **Stop any container using the volume** — a crash-looping container can
   interfere with ownership changes:
   ```bash
   docker rm -f <container-name>
   ```

3. **Run the chown manually with verbose output:**
   ```bash
   docker run --rm -v <volume-name>:/data alpine \
     sh -c 'chown -Rv 1000:1000 /data && ls -la /data'
   ```
   If `chown -v` lists the files but `ls -la` still shows root ownership, the
   Docker volume driver is not propagating the change — this is a Docker
   Desktop bug.

4. **If chown still does not stick, recreate the volume** (destructive — only
   for first-time deployments or disposable data):
   ```bash
   docker volume rm <volume-name>
   docker volume create <volume-name>
   # Re-run the chown + verify pair
   ```

5. **If the volume has data that must be preserved**, use a tar-based backup
   and restore around the volume recreation:
   ```bash
   # Backup
   docker run --rm -v <volume-name>:/data -v /tmp:/backup alpine \
     tar czf /backup/volume-backup.tar.gz -C /data .
   # Recreate + fix ownership
   docker volume rm <volume-name> && docker volume create <volume-name>
   docker run --rm -v <volume-name>:/data alpine \
     sh -c 'chown -R 1000:1000 /data && chmod 755 /data'
   # Restore (preserves the 1000:1000 ownership)
   docker run --rm -v <volume-name>:/data -v /tmp:/backup alpine \
     sh -c 'tar xzf /backup/volume-backup.tar.gz -C /data && chown -R 1000:1000 /data'
   # Verify
   docker run --rm -v <volume-name>:/data alpine \
     sh -c 'test "$(stat -c %u /data)" = "1000" && echo OK || echo FAIL'
   ```

## Implemented: Parameterized Utility Container + Reusable Ansible Role

The `alpine` + inline `sh -c '...'` pattern is the mandated baseline and
remains valid. When a deployment has graduated beyond the baseline — a third
role needs volume init, the inline scripts start diverging, or per-volume
uid/gid/mode differences make the inline form unwieldy — use the
**parameterized utility container** and the **reusable Ansible role** that
wraps it. Both are implemented in the `infrahub` repo.

### Utility container: `localnet-volume-init`

A small, purpose-built image (`alpine:3.20` + `findutils` + `tar`) that does
one thing: initialize Docker volume ownership with validation, logging, and
explicit exit codes. It replaces the inline `docker run --rm alpine sh -c
'...'` scripts scattered across roles.

```bash
# Phase 1 + 1.5: chown + in-container verify (single invocation)
docker run --rm -v <volume>:/data \
  -e DATA_DIR=/data \
  localnet-volume-init:latest <uid> <gid> [mode]

# Phase 2: fresh-container verify (separate container, fresh mount namespace)
docker run --rm --entrypoint /usr/local/bin/verify-volume \
  -v <volume>:/data -e DATA_DIR=/data \
  localnet-volume-init:latest verify <uid> <gid>
```

Exit codes (`init-volume`): `0`=ok, `1`=param error, `2`=chown/chmod failed,
`3`=persistence verify failed, `4`=in-container verify failed.
Exit codes (`verify-volume`): `0`=match, `1`=param error, `2`=mismatch.

The `DATA_DIR` env var (default `/data`) lets the caller mount the volume at
any path — useful when a service has multiple volumes mounted at different
paths (e.g., `/data`, `/config`, `/logs`) with different ownership per path.

### Reusable Ansible role: `localnet-volume-init`

The utility container is the tool; the **Ansible role** is the reusable
pattern. Service roles no longer hand-stitch `docker run --rm alpine sh -c
'...'` task pairs — they declare their volumes as a list and `include_role`
the reusable role, which handles Phase 0 (volume create) + Phase 1 (chown +
in-container verify) + Phase 2 (fresh-container verify) per volume, including
the `DOCKER_HOST` / `delegate_to: localhost` boilerplate for Windows Docker
Desktop hosts.

```yaml
# Single-volume service (all defaults — just declare the volume name)
- include_role:
    name: localnet-volume-init
  vars:
    volume_init_docker_host: "{{ service_docker_host }}"
    volume_init_volumes:
      - name: "{{ service_data_volume }}"
        # mount: /data    (default)
        # uid: 1000       (default)
        # gid: 1000       (default)
        # mode: "755"     (default)

# Multi-volume service (different uid/gid/mode per volume)
- include_role:
    name: localnet-volume-init
  vars:
    volume_init_docker_host: "{{ service_docker_host }}"
    volume_init_volumes:
      - name: "{{ svc_data_volume }}"           # all defaults
      - name: "{{ svc_config_volume }}"
        mount: /config
        gid: 0
        mode: "750"
      - name: "{{ svc_logs_volume }}"
        mount: /logs
        uid: 1001
        gid: 1001
        mode: "640"
```

**Intelligent defaults**: `mount=/data`, `uid=1000`, `gid=1000`, `mode=755`.
A single-volume service with standard ownership only needs to declare the
volume name — every other field has a sensible default. Multi-volume services
override per-spec; the role loops over the list and runs all three phases per
volume.

### When to use the utility container vs the inline alpine pattern

| Factor | Inline `alpine sh -c` (baseline) | `localnet-volume-init` + role |
|--------|----------------------------------|-------------------------------|
| Number of roles needing volume init | 1–2: inline is fine | 3+: use the role (justifies the abstraction) |
| Per-volume uid/gid/mode differences | Single spec: inline is fine | Multiple specs: use the role's `volume_init_volumes` list |
| Parameter validation | None — empty UID silently changes only GID | Validates numeric UID/GID, prints usage on error |
| Error handling | `chown` failure may be masked by `&&` chaining | Explicit exit codes (1=param, 2=chown, 3=persistence, 4=in-container) |
| Logging | Silent | Prints current state, target, and result |
| Diagnostics on failure | `rc=1` with no context | Clear error messages with expected vs. actual values |
| Build dependency | None (alpine is public) | Requires building and pushing `localnet-volume-init` |

**Recommendation**: Start with the inline `alpine` pattern for the first
volume init in a new deployment. Migrate to the `localnet-volume-init` role
when a second or third role needs the same pattern, or when per-volume
ownership specs make the inline form unwieldy. The inline pattern remains
valid and is the mandated baseline — the role is a convenience abstraction
on top of it, not a replacement.

## What does NOT work

1. **`ansible.builtin.file` with `owner`/`group`** — Only works when Ansible
   has direct filesystem access to the volume's mountpoint. On Docker Desktop
   for Windows, the mountpoint is inside the WSL2 VM at
   `/var/lib/docker/volumes/<name>/_data`, which is not directly accessible
   from the Windows host or the Ansible control machine.

2. **`docker volume create --opt`** — Docker's local driver does not support
   setting ownership at creation time. The `--opt` flag is for driver-specific
   options (device, type, NFS options), not for `chown`.

3. **Running the service container as root** — Violates the non-root execution
   policy in [Container Runtime Hardening](container-runtime-hardening.md)
   (`--security-opt no-new-privileges:true`, capability dropping).

4. **Docker `userns-remap`** — Docker Desktop for Windows does not support
   `userns-remap` (it is a Linux daemon feature requiring `daemon.json`
   configuration that Docker Desktop does not expose). Even on Linux where it
   is supported, it maps container UID 1000 to host UID 100000+ — the volume
   is still not owned by the mapped UID without explicit init.

5. **Entrypoint scripts that self-fix permissions** — Only works if the
   container starts as root, `chown`s the data directory, then `exec gosu
   <user>`. Images that start directly as a non-root user (the case this
   pattern exists to handle) cannot self-fix: they are already non-root when
   they try to write, so they cannot `chown` the volume. See "Signal to
   upstream image authors" above.

## Implementation Checklist

### Three-phase init (mandatory baseline)

- [ ] Volume exists (`docker volume inspect` or `docker volume create`)
- [ ] Phase 1 task: chown + chmod + in-container `stat` verify in one `docker
      run --rm alpine` invocation
- [ ] Phase 2 task: fresh-container `stat` verify in a separate `docker run
      --rm alpine` invocation
- [ ] Both tasks run before the service container starts
- [ ] `changed_when: false` on the chown task (idempotent)
- [ ] `failed_when: <register>.rc != 0` on the Phase 2 verify task
- [ ] Service container starts only if both phases pass
- [ ] Recovery procedures documented in the role's README for the persistence
      failure case
- [ ] For Windows Docker Desktop targets: `DOCKER_HOST` set via SSH,
      `delegate_to: localhost` (the `community.docker` modules cannot run on
      Windows because they import `grp`)

### Reusable role (preferred when available)

- [ ] `include_role: name: localnet-volume-init` instead of hand-stitching
      the task pair above
- [ ] `volume_init_volumes` list declares each volume with `name` (required)
      and `mount`/`uid`/`gid`/`mode` overrides as needed (intelligent
      defaults: `/data`, `1000`, `1000`, `755`)
- [ ] `volume_init_docker_host` set to the target Docker daemon (local Unix
      socket for Linux/OCI, `ssh://...` for Windows Docker Desktop)
- [ ] `localnet-volume-init:latest` image built and pushed to the local
      registry (`scripts/build-and-push-images.sh localnet-volume-init`)

### Entrypoint wrapper image (optional, for self-healing)

- [ ] Wrapper Dockerfile `FROM`s the upstream image, installs `su-exec`
      (Alpine) or `gosu` (Debian)
- [ ] Wrapper overrides `ENTRYPOINT` only — `CMD` inherited from upstream
- [ ] Entrypoint script: chown + in-container verify + `exec su-exec
      <uid>:<gid> "$@"`
- [ ] Container deployed WITHOUT `--user` (the wrapper drops privileges)
- [ ] `--security-opt no-new-privileges:true` and `--cap-drop ALL` still set
- [ ] Three-phase init still run before container starts (defense-in-depth)
- [ ] Wrapper image built multi-arch via `docker buildx --push`

## Related

- [Container Runtime Hardening](container-runtime-hardening.md) — Non-root
  execution is WHY this pattern is needed: a hardened non-root container
  cannot write to a root-owned volume. The two practices are inseparable.
- [Container Runtime Essentials](container-runtime-essentials.md) — Sidecar
  shared volumes (pnpm store, Nx cache) need ownership init on first boot;
  the multi-arch mandate ensures `alpine` is available on every host in the
  fleet for the throwaway init container.
- [Compose Service Dependency Ordering](compose-service-dependency-ordering.md)
  — The volume init pair is an init-container pattern; in compose, pair it
  with `condition: service_completed_successfully` for a one-shot init
  container that runs before the service.
- [Nx Monorepo Docker Patterns](nx-monorepo-docker-patterns.md) — Shared
  pnpm-store and nx-cache volumes (`localnet-artifact-pnpm-store-volume`,
  `localnet-artifact-nx-cache-volume`) need ownership init when the sidecars
  run as non-root `cuser` (UID 1000).
- [Base Image Selection](base-image-selection.md) — Why `alpine` is the right
  throwaway init container for infrastructure tasks (you control the
  toolchain) even when it is the wrong choice for application Dockerfiles
  (musl breaks glibc wheels).
