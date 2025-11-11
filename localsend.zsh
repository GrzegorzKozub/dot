#!/usr/bin/env zsh

set -e -o verbose

# repo

pushd `dirname $0`

git update-index --assume-unchanged \
  localsend/org.localsend.localsend_app/shared_preferences.json

popd

# links

stow --dir=`dirname $0` --target=$XDG_DATA_HOME --stow \
  localsend

