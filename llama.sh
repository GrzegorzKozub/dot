#!/usr/bin/env bash
set -eo pipefail -ux

# links

CACHE=/run/media/$USER/data/.cache

for DIR in huggingface llama.cpp; do
  [[ -d "$CACHE/$DIR" ]] || mkdir "$CACHE/$DIR"
  [[ -e "$XDG_CACHE_HOME/$DIR" ]] && rm -rf "${XDG_CACHE_HOME:?}/$DIR"
  ln -s "$CACHE/$DIR" "$XDG_CACHE_HOME/$DIR"
done
