# Arch Linux container images

This repository builds and publishes minimal Arch Linux container images that are
tuned for use as build environments. Multi-architecture builds are supported for
both `linux/amd64` and `linux/arm64` targets.

[![Build images](https://github.com/existemi/archlinux/actions/workflows/build.yml/badge.svg)](https://github.com/existemi/archlinux/actions/workflows/build.yml)

## Image overview

- `archlinux:base` – x86_64 image derived from the upstream `archlinux:base`
  image and extended with tooling such as `base-devel`, `git`, `git-lfs`,
  `sudo`, `pacman-contrib`, `rsync`, `gnupg`, `jq`, and `zstd`.
- `archlinuxarm:base` – aarch64 image bootstrapped from the official
  Arch Linux ARM root filesystem and provisioned with the same toolchain as the
  x86_64 variant.

When the GitHub Actions workflow runs in this repository, both images are pushed
to GitHub Container Registry under `ghcr.io/existemi/archlinux:base` and
`ghcr.io/existemi/archlinuxarm:base`.

## Quick start

```bash
# Pull the amd64 image
docker pull ghcr.io/existemi/archlinux:base

# Pull the arm64 image (requires an arm64 host or emulation)
docker pull ghcr.io/existemi/archlinuxarm:base

# Run a shell using the amd64 image
docker run --rm -it ghcr.io/existemi/archlinux:base bash
```

Both images include the Arch package signing keys and update their package
metadata during the build, so `pacman` is ready for immediate use.

## Building locally

The repo ships with `scripts/build.sh`, a wrapper around `docker buildx` that
produces multi-architecture images:

```bash
./scripts/build.sh            # build both x86_64 and aarch64 variants
./scripts/build.sh x86_64     # build only the amd64 image
./scripts/build.sh aarch64    # build only the arm64 image
```

The script expects Docker Buildx to be available. It loads the resulting image
into the local Docker engine by default. To control the produced tags, set the
following environment variables before invoking the script:

- `ARCH_BUILD_IMAGE_X86_64`
- `ARCH_BUILD_IMAGE_AARCH64`
- `ARCH_BUILD_GHCR_NAMESPACE`

When `ARCH_BUILD_GHCR_NAMESPACE` is set (for example to `ghcr.io/existemi`), the
script automatically tags and pushes the images to that registry.

## Continuous integration

The workflow defined in `.github/workflows/build.yml`:

- builds both architectures on pushes to `main`, scheduled runs, and manual
  dispatches;
- sets up QEMU and Buildx to produce multi-architecture images; and
- pushes the images to GitHub Container Registry using the repository owner as
  the namespace.

## Licensing

See `LICENSE` and `NOTICE` for details on the licensing of this repository and
the artifacts it produces.
