#!/usr/bin/env bash
set -euo pipefail

: "${BASE_IMAGE:?}" "${BUILD_PLATFORM:?}" "${EMACS_VERSION:?}"
: "${SOURCE_URL:?}" "${SOURCE_SHA256:?}" "${CC:?}" "${EMACS_PREFIX:?}"

workspace=$(mktemp -d)
trap 'rm -rf -- "$workspace"' EXIT
archive="$workspace/emacs.tar.xz"
download_url=$(curl --fail --location --show-error --retry 3 --connect-timeout 30 \
    --output "$archive" --write-out '%{url_effective}' "$SOURCE_URL")
printf '%s  %s\n' "$SOURCE_SHA256" "$archive" | sha256sum --check --strict
mkdir "$workspace/source"
tar -xJf "$archive" --strip-components=1 -C "$workspace/source"
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

{
    printf 'emacs-version: %s\nsource-url: %s\ndownload-url: %s\nsource-sha256: %s\n' \
        "$EMACS_VERSION" "$SOURCE_URL" "$download_url" "$SOURCE_SHA256"
    printf 'base-image: %s\nplatform: %s\narchitecture: %s\npatches: none\n' \
        "$BASE_IMAGE" "$BUILD_PLATFORM" "$(dpkg --print-architecture)"
    printf '\n[configure]\n'
    ./config.status --config
    printf '\n[compiler]\n'
    "$CC" --version
    printf '\n[packages]\n'
    dpkg-query -W -f '${binary:Package}\t${Version}\t${Architecture}\n' | LC_ALL=C sort
} > /usr/local/share/emacs-runtime/build-info

cd /
actual_version=$("$EMACS_PREFIX/bin/emacs" -Q --batch --eval '(princ emacs-version)')
if [[ $actual_version != "$EMACS_VERSION" ]]; then
    printf 'Expected Emacs %s, installed %s\n' "$EMACS_VERSION" "$actual_version" >&2
    exit 1
fi
