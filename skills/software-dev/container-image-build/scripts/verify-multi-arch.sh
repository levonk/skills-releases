#!/usr/bin/env bash
# verify-multi-arch.sh — inspect a local or remote image manifest and verify
# it covers the target architectures. Outputs JSON.
#
# Usage: verify-multi-arch.sh [--verbose] [--dry-run] <image:tag> [target-arch ...]
#
# Defaults target archs to: linux/amd64 linux/arm64
#
# Output (JSON):
#   {"archs": [...], "covers_targets": bool}

set -e -u -o pipefail

VERBOSE=0
DRY_RUN=0
IMAGE=""
TARGET_ARCHS=("linux/amd64" "linux/arm64")

usage() {
  echo "Usage: $0 [--verbose] [--dry-run] <image:tag> [target-arch ...]" >&2
  echo "  default targets: linux/amd64 linux/arm64" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose) VERBOSE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage ;;
    -*) echo "Unknown flag: $1" >&2; usage ;;
    *)
      if [[ -z "$IMAGE" ]]; then
        IMAGE="$1"
      else
        TARGET_ARCHS+=("$1")
      fi
      shift
      ;;
  esac
done

[[ -n "$IMAGE" ]] || { echo "Error: image:tag required" >&2; usage; }

log() { [[ "$VERBOSE" -eq 1 ]] && echo "[verify] $*" >&2 || true; }

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "(dry-run) would inspect ${IMAGE} for targets: ${TARGET_ARCHS[*]}"
  echo "{\"archs\": [], \"covers_targets\": false}"
  exit 0
fi

log "inspecting ${IMAGE} ..."

if ! command -v docker &>/dev/null; then
  echo "Error: docker not found" >&2
  exit 1
fi

manifest=$(docker manifest inspect "$IMAGE" 2>/dev/null || true)

if [[ -z "$manifest" ]]; then
  log "no manifest found for ${IMAGE}"
  echo "{\"archs\": [], \"covers_targets\": false}"
  exit 0
fi

# Extract platforms from the manifest.
mapfile -t found_archs < <(
  echo "$manifest" | jq -r '
    if .manifests then
      .manifests[].platform | "\(.os)/\(.architecture)"
    else
      .os + "/" + .architecture
    end
  ' 2>/dev/null | sort -u
)

log "found archs: ${found_archs[*]:-none}"

# Check coverage.
covers=true
for target in "${TARGET_ARCHS[@]}"; do
  if ! printf '%s\n' "${found_archs[@]}" | grep -qx "$target"; then
    covers=false
    log "missing target: ${target}"
  fi
done

# Build JSON arrays.
archs_json=$(printf '"%s",' "${found_archs[@]}" | sed 's/,$//')

echo "{\"archs\": [${archs_json}], \"covers_targets\": ${covers}}"
