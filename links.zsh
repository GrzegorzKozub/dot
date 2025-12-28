#!/usr/bin/env zsh

set -e -o verbose

# links

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
  tidal_dl_ng \
  tmux \
  vscode \
  yamllint \
  yazi \
  yt-dlp \
  zed \
  zsh

  # iex zellij

if [[ $HOST =~ ^(drifter|worker)$ ]]; then # work

  stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
    ansible \
    maven \
    teams-for-linux

  CACHE=/run/media/$USER/data/.cache
  [[ -d $CACHE ]] || {
    sudo mkdir $CACHE
    sudo chown $USER $CACHE
    sudo chgrp users $CACHE
  }

  [[ -d $CACHE/maven ]] || mkdir $CACHE/maven
  [[ -L $XDG_CACHE_HOME/maven ]] || ln -s $CACHE/maven $XDG_CACHE_HOME/maven

fi

stow --dir=`dirname $0` --target=$HOME --stow \
  zprofile

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
  ln -sf $DIR/environment/environment.d/20-amd.conf $XDG_CONFIG_HOME/environment.d/20-amd.conf ||
  return 0

