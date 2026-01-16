#!/usr/bin/env bash
set -eo pipefail -ux

# post-install cleanup

rm -rf "$XDG_CONFIG_HOME"/claude ~/.claude

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  claude
