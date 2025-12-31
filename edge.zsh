#!/usr/bin/env zsh

set -e -o verbose

# links

DIR=$(dirname $(realpath $0))

ln -sf $DIR/flags/microsoft-edge-stable-flags.conf \
  $XDG_CONFIG_HOME/microsoft-edge-stable-flags.conf
