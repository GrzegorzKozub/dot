#!/usr/bin/env bash
set -eo pipefail -ux

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  niri \
  noctalia

ln -sf "$XDG_CONFIG_HOME"/niri/"$HOST".kdl "$XDG_CONFIG_HOME"/niri/host.kdl
