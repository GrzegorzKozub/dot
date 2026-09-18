#!/usr/bin/env bash
set -eo pipefail -ux

# links

ln -sf "$(dirname "$(realpath "$0")")"/environment/environment.d/30-aws.conf \
  "$XDG_CONFIG_HOME"/environment.d/30-aws.conf

# python

for TOOL in awscli-local cfn-lint; do uv tool install $TOOL; done

# vscode

set +e

for EXTENSION in \
  kddejong.vscode-cfn-lint \
  redhat.vscode-yaml; do
  code --install-extension $EXTENSION --force
done

set -e
