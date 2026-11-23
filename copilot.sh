#!/usr/bin/env bash
set -eo pipefail -ux

# packages

ln -sf "$XDG_CONFIG_HOME"/mise/conf.d/copilot.env.toml \
  "$XDG_CONFIG_HOME"/mise/conf.d/copilot."$HOST".local.toml

mise install
