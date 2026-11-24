#!/usr/bin/env bash
set -eo pipefail -ux

# config

mkdir -p "$XDG_DATA_HOME"/org.localsend.localsend_app

[[ -e $XDG_DATA_HOME/org.localsend.localsend_app/shared_preferences.json ]] ||
  sed -e "s/<alias>/$HOST/" \
    "$(dirname "$(realpath "$0")")"/localsend/org.localsend.localsend_app/shared_preferences.json \
    > "$XDG_DATA_HOME"/org.localsend.localsend_app/shared_preferences.json
