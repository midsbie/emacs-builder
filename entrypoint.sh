#!/usr/bin/env bash

# This script sets up and runs a Docker container to build Emacs, and optionally installs it.  The
# user can export the TARGET_ENV variable with values "x" or "term" to force the build to target a
# specific environment. If TARGET_ENV is not set, the script attempts to determine the correct
# environment based on the presence of a GUI.
#
# Usage:
#   To force the build to target a specific environment:
#     export TARGET_ENV=x   # For GUI environment
#     export TARGET_ENV=term # For terminal environment
#
#   Then run the script:
#     ./build_emacs.sh

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
  --with-json \
  --with-gnutls \
  --with-dbus \
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
  term)
    echo "I: configuring WITHOUT X support"
    CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS \
      --without-x \
      --with-sound=no"
    ;;
  x)
    echo "I: configuring with X support"
    CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS $CONFIGURE_OPTIONS_X"
    ;;
  *)
    echo "I: unknown TARGET_ENV ($TARGET_ENV): defaulting to X support"
    CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS $CONFIGURE_OPTIONS_X"
    ;;
esac

./configure $CONFIGURE_OPTIONS

# This form was found to error out when building new major versions:
#   make -j$(nproc --all)
make -j$(nproc --all) bootstrap
