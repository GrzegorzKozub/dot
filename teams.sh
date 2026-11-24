#!/usr/bin/env bash
set -eo pipefail -ux

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --no-folding --stow \
  teams-for-linux
