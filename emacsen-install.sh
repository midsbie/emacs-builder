#!/usr/bin/env bash
# The in-container half of `emacsen install`, which passes this file to bash -c inside the image.
# It runs as root with the install target bind-mounted at /usr/local, the image's configured
# build tree as the working directory, and EMACSEN_IMAGE_ID, EMACSEN_IMAGE_TAG and
# EMACSEN_EMACS_VERSION naming the image and its Emacs. It is not for running on the host.

set -euo pipefail

fatal() { printf 'emacsen: %s\n' "$*" >&2; exit 1; }

command -v install-info >/dev/null \
    || fatal "image has no install-info; rebuild it with: emacsen build ${EMACSEN_IMAGE_TAG#emacsen:}"

make install

# One record per version: make install leaves other versions' trees in place.
record=/usr/local/lib/emacsen/installed/$EMACSEN_EMACS_VERSION
mkdir -p -- "${record%/*}"
{
    printf 'image-id: %s\nimage-tag: %s\n\n' "$EMACSEN_IMAGE_ID" "$EMACSEN_IMAGE_TAG"
    cat /usr/share/emacsen/build-info
} > "$record.tmp"
mv -- "$record.tmp" "$record"
