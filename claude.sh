#!/usr/bin/env bash
set -eo pipefail -ux

# links (keep settings provided by installer)

CONFIG=/run/media/$USER/data/.config

mkdir -p "$CONFIG"/claude

if [[ ! -L "$XDG_CONFIG_HOME"/claude ]] && [[ -d "$XDG_CONFIG_HOME"/claude ]]; then

  # rm -rf "$CONFIG"/claude/*

  shopt -s dotglob
  mv "$XDG_CONFIG_HOME"/claude/* "$CONFIG"/claude
  shopt -u dotglob

  rm -r "$XDG_CONFIG_HOME"/claude/

fi

[[ -L "$XDG_CONFIG_HOME"/claude ]] || ln -s "$CONFIG"/claude "$XDG_CONFIG_HOME"/claude

ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/settings.json \
  "$XDG_CONFIG_HOME"/claude/settings.json
