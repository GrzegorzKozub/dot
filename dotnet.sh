#!/usr/bin/env bash
set -eo pipefail -ux

# packages

ln -sf "$XDG_CONFIG_HOME"/mise/conf.d/dotnet.env.toml \
  "$XDG_CONFIG_HOME"/mise/conf.d/dotnet."$HOST".local.toml

mise install

# vscode

set e+

for EXTENSION in \
  ms-dotnettools.csdevkit \
  ms-dotnettools.csharp \
  ms-dotnettools.vscode-dotnet-runtime; do
  code --install-extension $EXTENSION --force
done

set e-
