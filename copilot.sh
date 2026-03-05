#!/usr/bin/env bash
set -eo pipefail -ux

# repo

pushd "${BASH_SOURCE%/*}"

git update-index --assume-unchanged \
  copilot/.copilot/config.json

popd

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  copilot
