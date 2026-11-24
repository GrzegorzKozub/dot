#!/usr/bin/env bash
set -eo pipefail -ux

# config

mkdir -p "$XDG_CONFIG_HOME"/Postman/storage

cp --update=none "$(dirname "$(realpath "$0")")"/postman/Postman/storage/settings.json \
  "$XDG_CONFIG_HOME"/Postman/storage/settings.json
