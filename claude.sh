#!/usr/bin/env bash
set -eo pipefail -ux

# keep settings provided by installer

if [[ ! -L "$XDG_CONFIG_HOME"/claude ]] && [[ -d "$XDG_CONFIG_HOME"/claude ]]; then

  shopt -s dotglob
  mv "$XDG_CONFIG_HOME"/claude/* ~/code/dot/claude/claude
  shopt -u dotglob

  rm -r "$XDG_CONFIG_HOME"/claude/

fi

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  claude
