#!/usr/bin/env bash
set -eo pipefail -ux

# repo

pushd "${BASH_SOURCE%/*}"

git update-index --assume-unchanged \
  localsend/org.localsend.localsend_app/shared_preferences.json

popd

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_DATA_HOME" --stow \
  localsend
