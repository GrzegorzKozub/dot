#!/usr/bin/env zsh

set -e -o verbose

# links

stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
  maven

# DIR=$(dirname $(realpath $0))
#
# ln -sf $DIR/environment/environment.d/30-java.conf \
#   $XDG_CONFIG_HOME/environment.d/30-java.conf

CACHE=/run/media/$USER/data/.cache

[[ -d $CACHE/maven ]] || mkdir $CACHE/maven
[[ -e $XDG_CACHE_HOME/maven ]] && rm -rf $XDG_CACHE_HOME/maven
ln -s $CACHE/maven $XDG_CACHE_HOME/maven

# vscode

set e+

for EXTENSION in \
  redhat.java \
  redhat.vscode-yaml
do
  code --install-extension $EXTENSION --force
done

set e-

