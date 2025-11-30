#!/usr/bin/env zsh

set -e -o verbose

# links

stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
  gamemode

[[ -d $XDG_CONFIG_HOME/MangoHud ]] || mkdir $XDG_CONFIG_HOME/MangoHud
ln -sf \
  $(dirname $(realpath $0))/mangohud/MangoHud/$HOST.conf \
  $XDG_CONFIG_HOME/MangoHud/MangoHud.conf

