#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if ! docker buildx version >/dev/null 2>&1; then
  echo "docker buildx is required to build multi-architecture images" >&2
  exit 1
fi

declare -a requested_arches
if [[ $# -gt 0 ]]; then
  requested_arches=("$@")
else
  requested_arches=(x86_64 aarch64)
fi

declare -A contexts=(
  [x86_64]="${repo_root}/docker/archlinux"
  [aarch64]="${repo_root}/docker/archlinuxarm"
)

declare -A platforms=(
  [x86_64]="linux/amd64"
  [aarch64]="linux/arm64"
)

declare -A image_names=(
  [x86_64]=archlinux
  [aarch64]=archlinuxarm
)

default_tag=base

to_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

ghcr_namespace=${ARCH_BUILD_GHCR_NAMESPACE:-}
if [[ -z "$ghcr_namespace" && -n "${GITHUB_REPOSITORY_OWNER:-}" ]]; then
  ghcr_namespace="ghcr.io/$(to_lower "$GITHUB_REPOSITORY_OWNER")"
fi
if [[ -n "$ghcr_namespace" ]]; then
  ghcr_namespace=${ghcr_namespace%/}
fi

push_enabled=0
if [[ -n "$ghcr_namespace" ]]; then
  push_enabled=1
fi

for target in "${requested_arches[@]}"; do
  case "$target" in
    x86_64|amd64)
      arch_key=x86_64
      ;;
    aarch64|arm64)
      arch_key=aarch64
      ;;
    *)
      echo "unsupported arch '$target'" >&2
      exit 2
      ;;
  esac

  context=${contexts[$arch_key]}
  platform=${platforms[$arch_key]}
  image_name=${image_names[$arch_key]}
  tag_var="ARCH_BUILD_IMAGE_${arch_key^^}"
  default_image_tag="${image_name}:${default_tag}"
  image_tag=${!tag_var:-$default_image_tag}

  if [[ ! -d "$context" ]]; then
    echo "missing docker context for $arch_key: $context" >&2
    exit 3
  fi

  echo "[build-docker-images] building $image_tag ($platform)" >&2
  docker buildx build \
    --platform "$platform" \
    --tag "$image_tag" \
    --load \
    "$context"

  if (( push_enabled )); then
    push_tag="${ghcr_namespace}/${image_name}:${default_tag}"
    if [[ "$push_tag" != "$image_tag" ]]; then
      docker tag "$image_tag" "$push_tag"
    fi
    echo "[build-docker-images] pushing $push_tag" >&2
    docker push "$push_tag"
  fi

done
