#!/usr/bin/env bash
set -eo pipefail -u

# config

mkdir -p "$XDG_CONFIG_HOME"/libreoffice/4/user

cp --update=none \
  "$(dirname "$(realpath "$0")")"/libreoffice/libreoffice/4/user/registrymodifications.xcu \
  "$XDG_CONFIG_HOME"/libreoffice/4/user/
