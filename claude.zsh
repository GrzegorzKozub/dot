#!/usr/bin/env zsh

set -e -o verbose

# packages

npm install --global @anthropic-ai/claude-code

# links

stow --dir=`dirname $0` --target=$HOME --stow \
  claude

