#!/usr/bin/env zsh

set -e -o verbose

# packages

npm install -g @google/gemini-cli

# links

stow --dir=`dirname $0` --target=$HOME --stow \
  gemini

