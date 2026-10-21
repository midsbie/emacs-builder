#!/usr/bin/env bash
set -euo pipefail

: "${BASE_IMAGE:?}" "${BUILD_PLATFORM:?}" "${SOURCE_SHA256:?}" "${CC:?}" "${EMACS_PREFIX:?}"

workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
archive=/source/archive
printf '%s  %s\n' "$SOURCE_SHA256" "$archive" | sha256sum --check --strict
mkdir "$workspace/source"
tar -xf "$archive" --strip-components=1 -C "$workspace/source"
cd "$workspace/source"

configure_options=(
    "--prefix=$EMACS_PREFIX"
    # Docker's default seccomp blocks the ASLR change needed by unexec.
    CANNOT_DUMP=yes
    --without-x
    --without-ns
    --without-dbus
    --without-gconf
    --without-gsettings
    --with-sound=no
    --without-pop
    --with-gnutls
    --with-xml2
    --with-zlib
)
./configure "${configure_options[@]}"
make -j2
make install

cd /
actual_version=$("$EMACS_PREFIX/bin/emacs" -Q --batch --eval '(princ emacs-version)')
if [[ -n ${EMACS_VERSION:-} && $actual_version != "$EMACS_VERSION" ]]; then
    printf 'Expected Emacs %s, installed %s\n' "$EMACS_VERSION" "$actual_version" >&2
    exit 1
fi
cd "$workspace/source"

# shellcheck disable=SC1091 # Supplied by the image's base distribution.
. /etc/os-release
{
    printf 'emacs-version: %s\nprefix: %s\nos-release: %s %s\n' \
        "$actual_version" "$EMACS_PREFIX" "$ID" "$VERSION_ID"
    printf 'base-image: %s\nplatform: %s\narchitecture: %s\npatches: none\n' \
        "$BASE_IMAGE" "$BUILD_PLATFORM" "$(dpkg --print-architecture)"
    printf '\n[configure]\n'
    ./config.status --config
    printf '\n[compiler]\n'
    "$CC" --version
    printf '\n[packages]\n'
    dpkg-query -W -f '${binary:Package}\t${Version}\t${Architecture}\n' | LC_ALL=C sort
} > /usr/share/emacsen/build-info
