#!/usr/bin/env bash
set -euo pipefail

: "${BASE_IMAGE:?}" "${TARGETPLATFORM:?}" "${SOURCE_SHA256:?}" "${CC:?}" "${EMACS_PREFIX:?}" "${VARIANT:?}"

archive=/source/archive
printf '%s  %s\n' "$SOURCE_SHA256" "$archive" | sha256sum --check --strict
mkdir -p /build/emacs
tar -xf "$archive" --strip-components=1 -C /build/emacs
cd /build/emacs
if [[ ! -f configure ]]; then ./autogen.sh; fi

configure_options=(
    "--prefix=$EMACS_PREFIX"
    --enable-link-time-optimization
    --with-native-compilation
    --with-gnutls
    --with-tree-sitter
    --with-xml2
    --without-pop
    --without-wide-int
)
case $VARIANT in
    server)
        configure_options+=(
            --without-x
            --without-dbus
            --without-gconf
            --without-gsettings
            --with-sound=no
        )
        ;;
    x)
        configure_options+=(
            --with-dbus
            --with-jpeg
            --with-png
            --with-rsvg
            --with-tiff
            --with-xft
            --with-xpm
        )
        ;;
    *) printf 'Unknown variant: %s\n' "$VARIANT" >&2; exit 1 ;;
esac

./configure "${configure_options[@]}"
make -j"$(nproc)" bootstrap
make install
make install DESTDIR=/out
find /out -mindepth 1 ! -path /out/usr/local/share/info/dir -printf '%y\t%P\n' \
    | LC_ALL=C sort > /usr/share/emacsen/manifest
rm -rf /out

# Layer export can change subsecond ordering between generated inputs and outputs.
# Equal timestamps leave the retained tree up to date for a later make install.
timestamp=$(date +%s)
find /build/emacs -exec touch -h -d "@$timestamp" {} +

actual_version=$("$EMACS_PREFIX/bin/emacs" -Q --batch --eval '(princ emacs-version)')
if [[ -n ${EMACS_VERSION:-} && $actual_version != "$EMACS_VERSION" ]]; then
    printf 'Expected Emacs %s, installed %s\n' "$EMACS_VERSION" "$actual_version" >&2
    exit 1
fi

# shellcheck disable=SC1091 # Supplied by the image's base distribution.
. /etc/os-release
{
    printf 'emacs-version: %s\nprefix: %s\nos-release: %s %s\n' \
        "$actual_version" "$EMACS_PREFIX" "$ID" "$VERSION_ID"
    printf 'build-tree: /build/emacs\nvariant: %s\n' "$VARIANT"
    printf 'base-image: %s\nplatform: %s\narchitecture: %s\npatches: none\n' \
        "$BASE_IMAGE" "$TARGETPLATFORM" "$(dpkg --print-architecture)"
    printf '\n[configure]\n'
    ./config.status --config
    printf '\n[compiler]\n'
    "$CC" --version
    printf '\n[packages]\n'
    dpkg-query -W -f '${binary:Package}\t${Version}\t${Architecture}\n' | LC_ALL=C sort
} > /usr/share/emacsen/build-info
