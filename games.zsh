#!/usr/bin/env zsh

set -e -o verbose

# validation

[[ $HOST =~ ^(player|worker)$ ]] || exit 1

# links

stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
  gamemode \
  mangohud

