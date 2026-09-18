#!/usr/bin/env bash
set -eo pipefail -u

# vscode

set e+
code --install-extension cucumberopen.cucumber-official --force
set e-
