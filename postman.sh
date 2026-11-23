#!/usr/bin/env bash
set -eo pipefail -ux

# repo

pushd "${BASH_SOURCE%/*}"
git update-index --assume-unchanged postman/Postman/storage/settings.json
popd

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  postman
