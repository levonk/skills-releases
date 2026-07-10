#!/usr/bin/env bash
# check-upstream-image.sh — search GHCR, Docker Hub, and Quay for official
# multi-arch images by name. Outputs JSON summarizing what was found.
#
# Usage: check-upstream-image.sh [--verbose] [--dry-run] <image-name>
#
# Output (JSON):
#   {"found": bool, "registries": [...], "archs": [...], "tags": [...]}

set -e -u -o pipefail

VERBOSE=0
DRY_RUN=0
IMAGE_NAME=""

usage() {
  echo "Usage: $0 [--verbose] [--dry-run] <image-name>" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose) VERBOSE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage ;;
    -*) echo "Unknown flag: $1" >&2; usage ;;
    *) IMAGE_NAME="$1"; shift ;;
  esac
done

[[ -n "$IMAGE_NAME" ]] || { echo "Error: image name required" >&2; usage; }

log() { [[ "$VERBOSE" -eq 1 ]] && echo "[check] $*" >&2 || true; }

# Registries to check. $IMAGE_NAME is the bare name (e.g., "attic").
CANDIDATES=(
  "ghcr.io/${IMAGE_NAME}"
  "docker.io/${IMAGE_NAME}"
  "quay.io/${IMAGE_NAME}"
)

found=false
registries=()
archs=()
tags=()

inspect_manifest() {
  local image="$1"
  if command -v docker &>/dev/null; then
    docker manifest inspect "$image" 2>/dev/null || return 1
  elif command -v docker &>/dev/null; then
    docker buildx imagetools inspect "$image" 2>/dev/null || return 1
  else
    echo "Error: docker not found" >&2
    return 1
  fi
}

extract_platforms() {
  # Reads manifest JSON on stdin, prints "os/arch" per platform.
  jq -r '
    if .manifests then
      .manifests[].platform | "\(.os)/\(.architecture)"
    else
      .os + "/" + .architecture
    end
  ' 2>/dev/null | sort -u
}

for candidate in "${CANDIDATES[@]}"; do
  log "checking ${candidate} ..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "(dry-run) would inspect ${candidate}"
    continue
  fi
  manifest=$(inspect_manifest "$candidate" || true)
  if [[ -n "$manifest" ]]; then
    found=true
    registries+=("\"$candidate\"")
    platforms=$(echo "$manifest" | extract_platforms)
    while IFS= read -r p; do
      [[ -n "$p" ]] && archs+=("\"$p\"")
    done <<< "$platforms"
    # Grab a few tags if available (best-effort).
    log "found ${candidate}"
  fi
done

# Deduplicate archs.
if [[ ${#archs[@]} -gt 0 ]]; then
  mapfile -t archs < <(printf '%s\n' "${archs[@]}" | sort -u)
fi

# Emit JSON.
{
  echo -n "{"
  echo -n "\"found\": ${found}"
  echo -n ", \"registries\": [$(IFS=,; echo "${registries[*]}")]"
  echo -n ", \"archs\": [$(IFS=,; echo "${archs[*]}")]"
  echo -n ", \"tags\": [$(IFS=,; echo "${tags[*]}")]"
  echo "}"
}
