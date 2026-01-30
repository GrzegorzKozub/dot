#!/usr/bin/env bash
set -eo pipefail -ux

# vscode

set e+
code --install-extension HashiCorp.terraform --force
set e-
