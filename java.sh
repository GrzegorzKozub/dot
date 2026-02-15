#!/usr/bin/env bash
set -eo pipefail -ux

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  maven

# ln -sf "${BASH_SOURCE%/*}"/environment/environment.d/30-java.conf \
#   "$XDG_CONFIG_HOME"/environment.d/30-java.conf

CACHE=/run/media/$USER/data/.cache

mkdir -p "$CACHE"/maven
rm -rf "$XDG_CACHE_HOME"/maven
ln -s "$CACHE"/maven "$XDG_CACHE_HOME"/maven

# vscode

set +e

for EXTENSION in \
  redhat.java \
  redhat.vscode-yaml; do
  code --install-extension $EXTENSION --force
done

set -e
