#!/usr/bin/env bash
set -eo pipefail -u

# vscode

set e+

for EXTENSION in \
  bierner.markdown-mermaid \
  cucumberopen.cucumber-official; do
  code --install-extension $EXTENSION --force
done

set e-
