FROM archlinux:base

RUN set -euo pipefail \
  && pacman-key --init \
  && pacman-key --populate archlinux \
  && pacman -Sy --noconfirm \
  && pacman -Syu --noconfirm --needed base-devel git git-lfs sudo pacman-contrib rsync gnupg jq zstd \
  && pacman -Scc --noconfirm \
  && rm -rf /var/cache/pacman/pkg/*

ENV PATH="/usr/local/bin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
