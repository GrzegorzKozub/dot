#!/usr/bin/env zsh

set -e -o verbose

# links

stow --dir=`dirname $0` --target=$HOME --stow \
  gemini

