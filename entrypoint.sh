#!/usr/bin/env bash

# This script runs inside the Docker container to configure and build Emacs.
#
# The TARGET_ENV variable controls the build configuration:
#   - "x"      : GUI build with X11, DBus, and image library support
#   - "server" : Headless build without X11, DBus, or desktop integration

#set -o xtrace
set -e

cd emacs

# Prevent the following error when running ./autogen.sh:
#
#   Running 'autoreconf -fi -I m4' ...
#   Configuring local git repository...
#   '.git/config' -> '.git/config.~2~'
#   git config transfer.fsckObjects 'true'
#   fatal: not in a git directory
git config --add safe.directory $(pwd)

git clean -fdx
./autogen.sh

# From `configure --help`:
#
#   --with-wide-int         prefer wide Emacs integers (typically 62-bit); on
#                           32-bit hosts, this allows buffer and string size up
#                           to 2GB, at the cost of 10% to 30% slowdown of Lisp
#
# Disabled options:
#    --with-imagemagick     one or more libraries are missing in 23.04
CONFIGURE_OPTIONS="\
  --enable-link-time-optimization \
  --with-native-compilation \
  --with-gnutls \
  --with-tree-sitter \
  --with-xml2 \
  --without-pop \
  --without-wide-int"

readonly CONFIGURE_OPTIONS_X="\
      --with-jpeg \
      --with-png \
      --with-rsvg \
      --with-tiff \
      --with-xft \
      --with-xpm"

case "$TARGET_ENV" in
  server)
    echo "I: configuring for server/headless (no X, no DBus)"
    CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS \
      --without-x \
      --without-dbus \
      --without-gconf \
      --without-gsettings \
      --with-sound=no"
    ;;
  x)
    echo "I: configuring with X support"
    CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS \
      --with-dbus \
      $CONFIGURE_OPTIONS_X"
    ;;
  *)
    echo "E: unknown TARGET_ENV: $TARGET_ENV (expected 'x' or 'server')" >&2
    exit 1
    ;;
esac

./configure $CONFIGURE_OPTIONS

# This form was found to error out when building new major versions:
#   make -j$(nproc --all)
make -j$(nproc --all) bootstrap
