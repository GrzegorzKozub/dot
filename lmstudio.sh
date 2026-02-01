#!/usr/bin/env bash
set -eo pipefail -ux

# links

stow --dir="${BASH_SOURCE%/*}" --target="$HOME" --stow \
  lmstudio
