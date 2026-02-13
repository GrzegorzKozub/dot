#!/usr/bin/env bash
set -eo pipefail -ux

# links

stow --dir="${BASH_SOURCE%/*}" --target="$HOME" --stow \
  lmstudio

DATA=/run/media/$USER/data/.data

[[ -d $DATA/lmstudio ]] || mkdir "$DATA"/lmstudio
[[ -e $XDG_DATA_HOME/lmstudio ]] && rm -rf "$XDG_DATA_HOME"/lmstudio
ln -s "$DATA"/lmstudio "$XDG_DATA_HOME"/lmstudio
