#!/usr/bin/env bash
set -eo pipefail -ux

# links

ln -sf "$(dirname "$(realpath "$0")")"/flags/microsoft-edge-stable-flags.conf \
  "$XDG_CONFIG_HOME"/microsoft-edge-stable-flags.conf
