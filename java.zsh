#!/usr/bin/env zsh

set -e -o verbose

# repo

pushd `dirname $0`

git update-index --assume-unchanged maven/maven/settings.xml

popd

# links

stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
  maven

# vscode

for EXTENSION in \
  Oracle.oracle-java
do
  code --install-extension $EXTENSION --force
done

