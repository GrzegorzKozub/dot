#!/usr/bin/env zsh

set -e -o verbose

# env

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}

# dirs

[[ -d $XDG_CONFIG_HOME ]] || mkdir -p $XDG_CONFIG_HOME

# links

stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
  dunst \
  gammastep \
  hyprland \
  swayimg \
  swaylock \
  waybar \
  wofi
