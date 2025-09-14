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
  zellij \
  zsh

  # alacritty dust flameshot foot gdu iex

if [[ $HOST =~ ^(drifter|worker)$ ]]; then # work

  stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
    teams-for-linux

fi

# if [[ $HOST =~ ^(player|worker)$ ]]; then
#
#   stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
#     redshift
#
# fi

stow --dir=`dirname $0` --target=$HOME --stow \
  zprofile

  # gemini imwheel

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
  exit 0

