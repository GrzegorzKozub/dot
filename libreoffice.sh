#!/usr/bin/env bash
set -eo pipefail -u

# repo

pushd "${BASH_SOURCE%/*}"
git update-index --assume-unchanged libreoffice/libreoffice/4/user/registrymodifications.xcu
popd

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  libreoffice
