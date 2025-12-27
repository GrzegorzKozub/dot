#!/usr/bin/env zsh

set -e -o verbose

# repo

pushd `dirname $0`
git update-index --assume-unchanged libreoffice/libreoffice/4/user/registrymodifications.xcu
popd

# links

stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
  libreoffice

