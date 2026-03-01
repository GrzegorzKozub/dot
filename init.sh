#!/usr/bin/env bash
set -eo pipefail -ux

# repo

[[ ${0:a:h} == $(pwd) ]] || SWITCHED=1 && pushd "${0:a:h}"

git submodule update --init
git submodule foreach --recursive git checkout master

git update-index --assume-unchanged btop/btop/btop.conf
git update-index --assume-unchanged tidal-hifi/tidal-hifi/config.json

[[ $SWITCHED == 1 ]] && popd

# env

export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_STATE_HOME=${XDG_DATA_HOME:-$HOME/.local/state}

# dirs

[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"

# links

"${BASH_SOURCE%/*}"/links.sh
