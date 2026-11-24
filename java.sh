#!/usr/bin/env bash
set -eo pipefail -ux

# packages

ln -sf "$XDG_CONFIG_HOME"/mise/conf.d/java.env.toml \
  "$XDG_CONFIG_HOME"/mise/conf.d/java."$HOST".local.toml

mise install

# links

mkdir -p "$XDG_CONFIG_HOME"/maven

[[ -e $XDG_CONFIG_HOME/maven/settings.xml || -L $XDG_CONFIG_HOME/maven/settings.xml ]] ||
  ln -s "$(dirname "$(realpath "$0")")"/maven/maven/settings.xml \
    "$XDG_CONFIG_HOME"/maven/settings.xml

# ln -sf "$(dirname "$(realpath "$0")")"/environment/environment.d/30-java.conf \
#   "$XDG_CONFIG_HOME"/environment.d/30-java.conf

CACHE=/run/media/$USER/data/.cache

mkdir -p "$CACHE"/maven
rm -rf "$XDG_CACHE_HOME"/maven
ln -s "$CACHE"/maven "$XDG_CACHE_HOME"/maven

# vscode

set e+
code --install-extension redhat.java --force
set e-
