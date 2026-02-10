#!/usr/bin/env bash
set -eo pipefail -ux

# config

CACHE=/run/media/$USER/data/.cache

[[ -d $CACHE/llama.cpp ]] || mkdir "$CACHE"/llama.cpp

[[ -e $XDG_CACHE_HOME/llama.cpp ]] && rm -rf "$XDG_CACHE_HOME"/llama.cpp
ln -s "$CACHE"/llama.cpp "$XDG_CACHE_HOME"/llama.cpp
