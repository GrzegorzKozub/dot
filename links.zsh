#!/usr/bin/env zsh

set -e -o verbose

# ~

# stow --dir=`dirname $0` --target=$HOME --stow \
#   zprofile

# config

stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
  bat \
  btop \
  cava \
  fastfetch \
  fsh \
  git \
  ghostty \
  keepass \
  kitty \
  mpv \
  npm \
  nushell \
  nvim \
  obsidian \
  rclone \
  ripgrep \
  satty \
  silicon \
  tidal-hifi\
  tidal_dl_ng \
  tmux \
  vscode \
  yamllint \
  yazi \
  yt-dlp \
  zed \
  zsh

  # iex zellij

DIR=$(dirname $(realpath $0))

ln -sf $DIR/flags/brave-flags.conf $XDG_CONFIG_HOME/brave-flags.conf
ln -sf $DIR/flags/code-flags.conf $XDG_CONFIG_HOME/code-flags.conf

[[ -d $XDG_CONFIG_HOME/environment.d ]] || mkdir -p $XDG_CONFIG_HOME/environment.d
ln -sf $DIR/environment/environment.d/10-common.conf $XDG_CONFIG_HOME/environment.d/10-common.conf

[[ $HOST = 'drifter' ]] &&
  ln -sf $DIR/environment/environment.d/20-intel.conf $XDG_CONFIG_HOME/environment.d/20-intel.conf

[[ $HOST =~ ^(player|worker)$ ]] &&
  ln -sf $DIR/environment/environment.d/20-nvidia.conf $XDG_CONFIG_HOME/environment.d/20-nvidia.conf

[[ $HOST = 'sacrifice' ]] &&
  ln -sf $DIR/environment/environment.d/20-amd.conf $XDG_CONFIG_HOME/environment.d/20-amd.conf

# cache

CACHE=/run/media/$USER/data/.cache

if [[ $HOST =~ ^(player|worker)$ ]]; then

  [[ -d $CACHE/llama.cpp ]] || mkdir "$CACHE"/llama.cpp
  [[ -e $XDG_CACHE_HOME/llama.cpp ]] && rm -rf "$XDG_CACHE_HOME"/llama.cpp
  ln -s "$CACHE"/llama.cpp "$XDG_CACHE_HOME"/llama.cpp

fi

