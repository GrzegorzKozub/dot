#!/usr/bin/env bash
set -eo pipefail -ux

# ~

# stow --dir="${BASH_SOURCE%/*}" --target="$HOME" --stow \
#   zprofile

# config

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  bat \
  btop \
  cava \
  f-sy-h \
  fastfetch \
  git \
  ghostty \
  imv \
  keepass \
  kitty \
  linecast \
  mise \
  mpv \
  npm \
  nvim \
  obsidian \
  rclone \
  ripgrep \
  silicon \
  tensaku \
  tidal-hifi tiddl \
  tmux \
  wget \
  yamllint \
  yay \
  yazi \
  yt-dlp \
  zed \
  zsh

  # bun iex satty zellij

mkdir -p "$XDG_CONFIG_HOME"/vscode
stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME"/vscode --stow vscode

DIR=$(dirname "$(realpath "$0")")

ln -sf "$DIR"/flags/brave-origin-flags.conf "$XDG_CONFIG_HOME"/brave-origin-flags.conf # or brave-flags.conf

# ln -sf "$DIR"/flags/code-flags.conf "$XDG_CONFIG_HOME"/code-flags.conf

mkdir -p "$XDG_CONFIG_HOME"/environment.d
ln -sf "$DIR"/environment/environment.d/10-common.conf "$XDG_CONFIG_HOME"/environment.d/10-common.conf

if [[ $HOST == 'drifter' ]]; then
  ln -sf "$DIR"/environment/environment.d/20-intel.conf "$XDG_CONFIG_HOME"/environment.d/20-intel.conf
fi

if [[ $HOST =~ ^(player|worker)$ ]]; then
  ln -sf "$DIR"/environment/environment.d/20-nvidia.conf "$XDG_CONFIG_HOME"/environment.d/20-nvidia.conf
fi

if [[ $HOST == 'sacrifice' ]]; then
  ln -sf "$DIR"/environment/environment.d/20-amd.conf "$XDG_CONFIG_HOME"/environment.d/20-amd.conf
fi
