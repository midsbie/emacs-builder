#!/usr/bin/env bash

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
git config --global --add safe.directory $(pwd)

# Configure and run
./autogen.sh

# Was using previously:
# ./configure --with-native-compilation --with-mailutils

# From `configure --help`:
#
#   --with-wide-int         prefer wide Emacs integers (typically 62-bit); on
#                           32-bit hosts, this allows buffer and string size up
#                           to 2GB, at the cost of 10% to 30% slowdown of Lisp
#
# Disabled options:
#    --with-imagemagick     one or more libraries are missing in 23.04
./configure \
  --enable-link-time-optimization \
  --with-native-compilation --with-json --with-gnutls --with-jpeg --with-png \
  --with-rsvg --with-tiff --with-xft --with-xml2 --with-xpm \
  --with-dbus --with-tree-sitter \
  --without-pop \
  --without-wide-int

# This form was found to error out when building new major versions:
#   make -j$(nproc --all) && make install
make -j$(nproc --all) bootstrap
sudo make install
