#!/usr/bin/env zsh

set -e -o verbose

# repo

[[ ${0:a:h} = $(pwd) ]] || SWITCHED=1 && pushd ${0:a:h}

git submodule update --init
git submodule foreach --recursive git checkout master

git update-index --assume-unchanged btop/btop/btop.conf

[[ $SWITCHED = 1 ]] && popd

# env

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

# dirs

[[ -d $XDG_CONFIG_HOME ]] || mkdir -p $XDG_CONFIG_HOME

# links

`dirname $0`/links.zsh

