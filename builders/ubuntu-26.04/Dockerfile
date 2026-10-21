ARG BASE_IMAGE=ubuntu:26.04
FROM ${BASE_IMAGE}
LABEL maintainer="Miguel Guedes <miguel.a.guedes@gmail.com>"

WORKDIR /build
ENV DEBIAN_FRONTEND=noninteractive CC=gcc-14 EMACS_PREFIX=/usr/local LANG=C.UTF-8

RUN apt-get update \
    && apt-get install -y apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        gcc-14 \
        git \
        gnupg-agent \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/*

ARG VARIANT
RUN case "$VARIANT" in \
        x) package=emacs ;; \
        server) package=emacs-nox ;; \
        *) echo "Unknown variant: $VARIANT" >&2; exit 1 ;; \
    esac \
    && sed -i 's/Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update \
    && apt-get build-dep -y "$package" \
    && rm -rf /var/lib/apt/lists/*

# Match the compiler to libgccjit, as required by native compilation.
RUN apt-get update \
    && apt-get install -y libgccjit0 \
        libgccjit-14-dev \
        libtree-sitter0.25 \
        libtree-sitter-dev \
    && rm -rf /var/lib/apt/lists/*

ARG BASE_IMAGE
ARG TARGETPLATFORM
ARG EMACS_VERSION
ARG SOURCE_SHA256
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

LABEL org.opencontainers.image.title="Emacs" \
      org.opencontainers.image.version="${EMACS_VERSION}" \
      org.opencontainers.image.revision="${BUILDER_REVISION}"
ENV PATH=${EMACS_PREFIX}/bin:${PATH} HOME=/home/runtime TMPDIR=/tmp
USER 65534:65534
WORKDIR /work
ENTRYPOINT ["emacs"]
