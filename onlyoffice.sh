#!/usr/bin/env bash
set -eo pipefail -u

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  onlyoffice
