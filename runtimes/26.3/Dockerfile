ARG BASE_IMAGE=ubuntu:20.04@sha256:c664f8f86ed5a386b0a340d981b8f81714e21a8b9c73f658c4bea56aa179d54a
ARG BUILD_PLATFORM=linux/amd64
FROM --platform=${BUILD_PLATFORM} ${BASE_IMAGE}

RUN test "$(dpkg --print-architecture)" = amd64 \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        gcc-9 \
        ca-certificates \
        curl \
        xz-utils \
        pkg-config \
        texinfo \
        libncurses-dev \
        libgnutls28-dev \
        libxml2-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ARG BASE_IMAGE
ARG BUILD_PLATFORM
ARG EMACS_VERSION=26.3
# Verified against GNU's release signature, key D405AA2C862C54F17EEE6BE0E8BCD7866AFCF978.
ARG SOURCE_URL=https://ftpmirror.gnu.org/emacs/emacs-${EMACS_VERSION}.tar.xz
ARG SOURCE_SHA256=4d90e6751ad8967822c6e092db07466b9d383ef1653feb2f95c93e7de66d3485
ENV CC=gcc-9 EMACS_PREFIX=/opt/emacs/${EMACS_VERSION} LANG=C.UTF-8
COPY . /usr/local/share/emacs-runtime/recipe/
RUN bash /usr/local/share/emacs-runtime/recipe/build.sh

ARG BUILDER_REVISION
ARG BUILDER_DIRTY
ARG BUILDER_INPUTS
RUN test -n "$BUILDER_REVISION" && test -n "$BUILDER_INPUTS" \
    && printf '\nbuilder-revision: %s\nbuilder-dirty: %s\n\n[builder-input-sha256]\n%s\n' \
        "$BUILDER_REVISION" "$BUILDER_DIRTY" "$BUILDER_INPUTS" \
        >> /usr/local/share/emacs-runtime/build-info \
    && mkdir -p /work /home/runtime \
    && chmod 1777 /home/runtime

LABEL org.opencontainers.image.title="Emacs compatibility runtime" \
      org.opencontainers.image.version="${EMACS_VERSION}" \
      org.opencontainers.image.revision="${BUILDER_REVISION}"
ENV PATH=${EMACS_PREFIX}/bin:${PATH} HOME=/home/runtime TMPDIR=/tmp
USER 65534:65534
WORKDIR /work
ENTRYPOINT ["emacs"]
