# Multi-Arch Manifest Management

> Shared reference for multi-arch decision-making, manifest tools, tagging
> conventions, and verification. Used by all three branches.

## Decision Framework

| Situation | Approach |
|-----------|----------|
| Upstream has a multi-arch manifest list | **Verify** it (Branch A), retag with `docker manifest create --amend` |
| Building from source, no Nix runtime need | **buildx `--platform`** with cross-compilation (Branch B) |
| Building from source, needs Nix at runtime | **Nix `pkgsCross`** or per-system Flake Parts (Branch C) |
| Upstream is single-arch, need multi-arch | Fall through to Branch B or C — do not wrap a single-arch image |

## Manifest Management Tools

| Tool | Strength | Use When |
|------|----------|----------|
| `docker manifest` | Simple, manual manifest list creation | Retagging upstream multi-arch images (Branch A) |
| `docker buildx imagetools` | Rich inspection of remote manifests | Verifying upstream or pushed images |
| `crane` | Programmatic, scriptable, CI-friendly | CI pipelines, copying manifests between registries |
| `skopeo` | Copying images between registries, preserves manifest list | Mirroring upstream images to a local registry |

### Examples

```bash
# docker manifest — create a multi-arch tag from upstream digests
docker manifest create <registry>/<image:tag> --amend <upstream:tag>
docker manifest push <registry>/<image:tag>

# docker buildx imagetools — inspect a remote manifest (no pull needed)
docker buildx imagetools inspect <image:tag>

# crane — copy an image preserving its manifest list
crane copy <upstream:tag> <registry>/<image:tag>

# skopeo — copy between registries, preserves multi-arch
skopeo copy docker://<upstream:tag> docker://<registry>/<image:tag>
```

## Tagging Conventions

### Single tag with manifest list (recommended for production)

One tag (e.g., `:v1.2.3` or `:latest`) points to a manifest list covering all
architectures. The runtime pulls and automatically gets the right platform.

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  --tag <registry>/<image:v1.2.3> --push .
```

### Arch-specific tags (for debugging)

Publish per-arch tags (`:v1.2.3-amd64`, `:v1.2.3-arm64`) alongside the manifest
list tag. Lets you pull a specific platform for debugging:

```bash
docker pull <registry>/<image:v1.2.3-arm64>
```

## Verification Commands

### Inspect a manifest (local or remote)

```bash
docker manifest inspect <image:tag> \
  | jq -r '.manifests[].platform | "\(.os)/\(.architecture)"'
```

### Inspect via buildx (richer, includes digests)

```bash
docker buildx imagetools inspect <image:tag>
```

### Pull a specific platform to verify it runs

```bash
docker pull --platform linux/arm64 <image:tag>
docker run --rm --platform linux/arm64 <image:tag> <command>
```

### Automated verification

```bash
scripts/verify-multi-arch.sh <image:tag> linux/amd64 linux/arm64
```

Outputs JSON: `{archs: [...], covers_targets: bool}`.

## How to Verify an Image Is Truly Multi-Arch

1. **Inspect the manifest** — `docker manifest inspect` must show a
   `manifests` array with multiple `platform` entries. A single-arch image
   returns a config blob, not a manifest list.
2. **Check every target arch is present** — cross-reference `.manifests[].platform`
   against your target set (`linux/amd64`, `linux/arm64`).
3. **Pull each platform** — pull with `--platform` and run a smoke command to
   confirm the binary executes (not just that the manifest claims it exists).
4. **Do not trust `:latest` without inspection** — upstream `:latest` may be
   single-arch even when other tags are multi-arch.

## Build Platform Strategy

| Strategy | Speed | Complexity | When to Use |
|----------|-------|------------|-------------|
| **Cross-compilation** | Fastest | High (toolchain setup) | Rust, C++, Go production builds |
| **QEMU emulation** | Slowest (10-24x) | Low (just `--platform`) | Simple builds, prototyping, dep install |
| **Native build hosts** | Fastest | High (requires per-arch infra) | When you have amd64 + arm64 CI runners |
| **Hybrid (recommended)** | Fast | Medium | Cross-compile binaries, native for arch-specific steps |

### Hybrid Approach (Recommended)

- Build stages use `--platform=$BUILDPLATFORM` (native, no QEMU).
- Cross-compile the binary for each `TARGETPLATFORM`.
- Runtime stage is a normal multi-arch base image.
- This gives native-speed compilation and multi-arch output without QEMU or
  per-arch runners.

See `references/dockerfile-buildx.md` for the full hybrid Dockerfile pattern.
