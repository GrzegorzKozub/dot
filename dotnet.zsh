#!/usr/bin/env zsh

set -e -o verbose

# vscode

set e+

for EXTENSION in \
  ms-dotnettools.csdevkit \
  ms-dotnettools.csharp \
  ms-dotnettools.vscode-dotnet-runtime
do
  code --install-extension $EXTENSION --force
done

set e-

