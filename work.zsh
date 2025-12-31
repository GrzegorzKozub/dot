#!/usr/bin/env zsh

set -e -o verbose

# vscode

set e+

for EXTENSION in \
  bierner.markdown-mermaid \
  cucumberopen.cucumber-official
do
  code --install-extension $EXTENSION --force
done

set e-

