#!/usr/bin/env bash
set -eo pipefail -ux

# links

ln -sf "$(dirname "$(realpath "$0")")"/environment/environment.d/30-aws.conf \
  "$XDG_CONFIG_HOME"/environment.d/30-aws.conf

# python

for TOOL in awscli-local cfn-lint; do uv tool install $TOOL; done

# vscode

set e+
code --install-extension kddejong.vscode-cfn-lint --force
set e-
