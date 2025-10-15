# syntax=docker/dockerfile:1.6

ARG ARCHLINUXARM_MIRROR=http://os.archlinuxarm.org/os
ARG ARCHLINUXARM_ARCHIVE=ArchLinuxARM-aarch64-latest.tar.gz

FROM --platform=$TARGETPLATFORM debian:bookworm-slim AS bootstrap

SHELL ["/bin/bash","-o","pipefail","-c"]

ARG ARCHLINUXARM_MIRROR
ARG ARCHLINUXARM_ARCHIVE

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
   && apt-get install -y --no-install-recommends \
   ca-certificates \
   curl \
   gnupg \
   tar \
   xz-utils \
   && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /rootfs

RUN curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors "${ARCHLINUXARM_MIRROR}/${ARCHLINUXARM_ARCHIVE}" -o /tmp/rootfs.tar.gz \
   && tar --numeric-owner --xattrs --acls -xzf /tmp/rootfs.tar.gz -C /rootfs \
   && rm /tmp/rootfs.tar.gz

RUN rm -f /rootfs/etc/resolv.conf \
   && cp /etc/resolv.conf /rootfs/etc/resolv.conf

RUN mkdir -p /rootfs/etc \
   && rm -f /rootfs/etc/mtab \
   && printf 'rootfs / rootfs rw 0 0\n' > /rootfs/etc/mtab

RUN <<'EOF'
set -euo pipefail
export PATH=/usr/bin:/usr/sbin:/bin:/sbin
chroot /rootfs /usr/bin/pacman-key --init
chroot /rootfs /usr/bin/pacman-key --populate archlinuxarm
chroot /rootfs /usr/bin/pacman -Syu --noconfirm --needed base-devel git git-lfs sudo pacman-contrib rsync gnupg jq zstd
chroot /rootfs /usr/bin/pacman -Scc --noconfirm
EOF

RUN rm -rf /rootfs/var/cache/pacman/pkg/*

FROM scratch

COPY --from=bootstrap /rootfs/ /

ENV LANG=C.UTF-8
ENV PATH="/usr/local/bin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"

CMD ["/bin/bash"]
