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
ARG EMACS_VERSION
ARG SOURCE_SHA256
ENV CC=gcc-9 EMACS_PREFIX=/opt/emacs/26.3 LANG=C.UTF-8
COPY . /usr/share/emacsen/recipe/
RUN --mount=type=bind,from=source,target=/source bash /usr/share/emacsen/recipe/build.sh

ARG BUILDER_REVISION
ARG BUILDER_DIRTY
ARG BUILDER_INPUTS
ARG SOURCE_INFO
RUN test -n "$BUILDER_REVISION" && test -n "$BUILDER_INPUTS" && test -n "$SOURCE_INFO" \
    && { printf '%s\n' "$SOURCE_INFO"; \
         cat /usr/share/emacsen/build-info; \
         printf '\nbuilder-revision: %s\nbuilder-dirty: %s\n\n[builder-input-sha256]\n%s\n' \
             "$BUILDER_REVISION" "$BUILDER_DIRTY" "$BUILDER_INPUTS"; \
       } > /usr/share/emacsen/build-info.tmp \
    && mv /usr/share/emacsen/build-info.tmp /usr/share/emacsen/build-info \
    && mkdir -p /work /home/runtime \
    && chmod 1777 /home/runtime

LABEL org.opencontainers.image.title="Emacs compatibility runtime" \
      org.opencontainers.image.version="${EMACS_VERSION}" \
      org.opencontainers.image.revision="${BUILDER_REVISION}"
ENV PATH=${EMACS_PREFIX}/bin:${PATH} HOME=/home/runtime TMPDIR=/tmp
USER 65534:65534
WORKDIR /work
ENTRYPOINT ["emacs"]
