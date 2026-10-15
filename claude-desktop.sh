#!/usr/bin/env bash
set -eo pipefail -ux

# config

mkdir -p "$XDG_CONFIG_HOME"/Claude/

cp -r "$(dirname "$(realpath "$0")")"/claude-desktop/Claude/* \
  "$XDG_CONFIG_HOME"/Claude/
