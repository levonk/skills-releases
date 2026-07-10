# Branch A — Wrap Pre-Built Upstream Image

> Use when upstream provides an official multi-arch image. Do not rebuild from
> source — pull, verify, retag, push.

## When to Use

- Upstream publishes an official multi-arch image covering all target
  architectures (typically `linux/amd64` + `linux/arm64`).
- Check GHCR (`ghcr.io/<org>/<image>`), Docker Hub (`docker.io/<org>/<image>`),
  and Quay (`quay.io/<org>/<image>`) before considering a build.
- Run `scripts/check-upstream-image.sh <image-name>` to automate the registry
  sweep. If `found: true` and `archs` covers the target set, use this branch.
- If the upstream image is single-arch or missing one target arch, fall through
  to Branch B (Dockerfile + buildx) or Branch C (Nix flake).

## Workflow

```bash
# 1. Pull the upstream image.
docker pull <upstream-image:tag>

# 2. Verify the manifest covers all target architectures.
docker manifest inspect <upstream-image:tag>
# or (richer output, includes digest per platform):
docker buildx imagetools inspect <upstream-image:tag>

# 3. Retag for your registry (see Retagging below for multi-arch).
docker tag <upstream-image:tag> <your-registry>/<image:tag>

# 4. Push to your registry.
docker push <your-registry>/<image:tag>

# 5. Verify the pushed image is multi-arch.
scripts/verify-multi-arch.sh <your-registry>/<image:tag>
```

## Multi-Arch Verification

Before retagging, confirm the upstream manifest list includes every target
platform:

```bash
docker manifest inspect <upstream-image:tag> \
  | jq -r '.manifests[].platform | "\(.os)/\(.architecture)"'
```

Expected output for a mixed fleet:

```
linux/amd64
linux/arm64
```

If any target arch is missing, **do not proceed with Branch A**. Fall through:

- Missing arch, service is a binary → Branch B (`references/dockerfile-buildx.md`)
- Missing arch, service needs Nix at runtime → Branch C
  (`references/nix-flake-build.md`)

## Retagging Multi-Arch Images

**`docker tag` does NOT preserve the manifest list.** It copies a single
platform image. For multi-arch retagging, use `docker manifest`:

```bash
# Create a manifest list referencing the upstream per-platform digests.
docker manifest create \
  <your-registry>/<image:tag> \
  --amend <upstream-image:tag>

# Push the manifest list.
docker manifest push <your-registry>/<image:tag>
```

Alternatively, use `crane` or `skopeo copy` which preserve the manifest list
transparently (see `references/multi-arch.md`).

## Pitfalls

- **Single-arch upstream images** — some projects publish `:latest` for amd64
  only. Always inspect the manifest, never assume.
- **Platform-specific `RUN` commands** — if you layer a custom Dockerfile on
  top of an upstream image, any `RUN` that installs arch-specific packages
  breaks multi-arch unless the Dockerfile is itself built with `--platform`.
- **Retagging breaks multi-arch** — `docker tag` + `docker push` pushes only
  the local platform's image, silently dropping the manifest list. Use
  `docker manifest create --amend` + `docker manifest push`, or `skopeo copy`.
- **Tag drift** — pin to a specific upstream digest or version tag, not
  `:latest`, so retagging is reproducible.

## Examples

- **Attic** (`ghcr.io/zhaofengli/attic`) — official multi-arch GHCR image.
  Wrap by pulling, verifying `linux/amd64` + `linux/arm64`, retagging via
  `docker manifest create --amend`, and pushing.
- **ncps** — official multi-arch GHCR image. Same wrap workflow.
