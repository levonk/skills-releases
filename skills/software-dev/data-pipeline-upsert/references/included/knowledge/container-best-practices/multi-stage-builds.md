---
type: Practice
title: Multi-Stage Builds — builder is the bloat zone
description: Use multi-stage Dockerfiles with a builder stage for toolchains and a scratch/distroless final stage for the runtime. Ship only the binary, not the compiler.
tags: [docker, dockerfile, multi-stage, scratch, distroless, go, rust, static-binary]
date:
  created: "2026-07-17"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: give-me-15-minutes-and-i-ll-fix-your-dockerfiles-forever
    resource: "https://www.youtube.com/watch?v=aZ_y2M2OuEA"
    title: "Give me 15 minutes and I'll Fix Your Dockerfiles Forever"
  - id: distroless-images
    resource: "https://github.com/GoogleContainerTools/distroless"
    title: "Distroless images"
  - id: docker-multi-stage-build-documentation
    resource: "https://docs.docker.com/build/building/multi-stage/"
    title: "Docker multi-stage build documentation"
---

# Multi-Stage Builds — builder is the bloat zone

## Failure Mode

Running a compiled-language binary inside a full OS image (e.g. `golang:alpine`
running the compiled `go build` output). The Go runtime and toolchain are
present in the final image even though the binary is static and needs none of
it.

## Symptoms

- A "hello world" Go binary in `golang:alpine` is **272 MB**.
- A "hello world" Python app in `python:3-alpine` is ~130 MB.
- Image pull times and registry storage costs scale with the bloat.

## Practice

Use multi-stage builds. Name the first stage `builder` — the "bloat zone"
where the toolchain lives. The final stage copies **only the artifact** (binary,
wheel, static assets) and runs it on a minimal base.

### Go multi-stage pattern

```dockerfile
# Builder stage — toolchain lives here
FROM golang:1.22 AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o app main.go

# Final stage — only the binary
FROM scratch
COPY --from=builder /src/app /app
CMD ["/app"]
```

Result: 272 MB → **2.3 MB** (with `scratch`) or **11 MB** (with a minimal base).

### `FROM scratch` vs Distroless

| Base | Size | Shell | Pkg manager | CA certs | Use when |
|------|------|-------|-------------|----------|----------|
| `scratch` | smallest | no | no | no | Pure static binary, no TLS, no user |
| `distroless` | tiny | no | no | yes | Static binary needing CA certs / user |
| `slim` | small | yes | no | yes | Dynamic deps, debugging shell needed |
| `alpine` | small | yes | yes (apk) | yes | Infra services (see [base-image-selection](/base-image-selection.md)) |

> "Distroless is to `scratch` what Slim is to Alpine." — practical middle
> ground: still tiny, no shell, no package manager, but ships useful runtime
> basics (CA certs, user setup) that you occasionally need.

### Non-root user in the final stage

The final stage should run as a non-root user. A container escape gives
the attacker a root-equivalent process on the host syscall surface; with a
bind-mounted host directory, root-in-container is root on that path. Create
the user in the final stage (not the builder — the builder is discarded)
and set `USER` before the entrypoint:

```dockerfile
# Final stage — only the binary, running as non-root
FROM distroless
COPY --from=builder /src/app /app
USER nonroot:nonroot
CMD ["/app"]
```

For images that need a shell (slim/alpine bases), create the user
explicitly. Use a fixed UID/GID (e.g. 1001) for reproducibility and to
avoid conflicts with host UIDs:

```dockerfile
FROM node:22-slim
RUN groupadd -r app && useradd -r -g app -u 1001 app
COPY --from=builder --chown=app:app /src/app /app
USER 1001
CMD ["/app"]
```

Use `COPY --chown` to set ownership at copy time rather than a separate
`RUN chown -R` layer — the latter duplicates every inode into a new image
layer, doubling the image size. If the user needs writable directories
(cache, state), create and chown them in the same `RUN` that creates the
user, before `USER`.

See [container-runtime-hardening](/container-runtime-hardening.md) for the
full runtime hardening stack (read-only rootfs, cap-drop, no-new-privileges)
that complements a non-root `USER`.

### OCI labels for registry metadata

Attach OCI image labels to the final stage so container registries (GHCR,
Docker Hub, Quay) display source, description, and license metadata without
requiring a separate README or manual annotation:

```dockerfile
FROM node:22-slim AS production
LABEL org.opencontainers.image.source="https://github.com/<org>/<repo>"
LABEL org.opencontainers.image.description="One-line description of the image"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.version="${VERSION}"
```

Labels belong on the **final** stage, not the builder — the builder is
discarded and its labels never reach the registry. If the version is
dynamic, inject it via a build arg (`ARG VERSION`) and reference it in the
label. For deterministic versioning derived from Git state, see
[image-versioning](/image-versioning.md).

The full OCI label set is defined in the
[OpenContainers Image Spec](https://github.com/opencontainers/image-spec/blob/main/annotations.md).
The high-value labels are:

| Label | Purpose |
|-------|---------|
| `org.opencontainers.image.source` | URL to the source repo — registries link back |
| `org.opencontainers.image.description` | One-line description shown in registry UI |
| `org.opencontainers.image.licenses` | SPDX license identifier |
| `org.opencontainers.image.version` | Image version (SemVer or Git-derived) |
| `org.opencontainers.image.revision` | Full Git SHA for traceability |

## When NOT to use multi-stage

- Interpreted languages (Python, Node, Ruby) where the runtime **is** the
  app — there's no "binary" to extract. Use [base-image-selection](/base-image-selection.md)
  (slim) instead.
- Debug images where you need the toolchain inside the running container.

## Related

- [base-image-selection](/base-image-selection.md) — slim vs alpine for the
  builder stage (doesn't matter) and the final stage (distroless > scratch for
  practical use).
- [layer-cache-order](/layer-cache-order.md) — `go mod download` before
  `COPY . .` in the builder stage.
