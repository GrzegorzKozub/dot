#!/usr/bin/env bash
set -eo pipefail -ux

# packages

ln -sf "$XDG_CONFIG_HOME"/mise/conf.d/auth0.env.toml \
  "$XDG_CONFIG_HOME"/mise/conf.d/auth0."$HOST".local.toml

mise install
