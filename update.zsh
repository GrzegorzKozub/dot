#!/usr/bin/env zsh

set -o verbose

# update self

git pull
git submodule update --init
git submodule foreach --recursive git checkout master
git submodule foreach --recursive git pull

# zsh

set +o verbose

declare -A ZINIT
export ZINIT[HOME_DIR]=$XDG_DATA_HOME/zinit
export ZINIT[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/zcompdump

source $ZINIT[HOME_DIR]/bin/zinit.zsh

zinit self-update
zinit update --all

set -o verbose

# tmux

for plugin in $XDG_DATA_HOME/tmux/plugins/*; do
  $XDG_DATA_HOME/tmux/plugins/tpm/scripts/update_plugin.sh \
    --shell-echo \
    $(echo $plugin | sed 's/^.*\///')
done

# yazi

ya pkg upgrade

# links

. `dirname $0`/links.zsh

# shared

. `dirname $0`/shared.zsh

# node

# set +o verbose
#
# export NVM_DIR=$XDG_DATA_HOME/nvm
# source $NVM_DIR/nvm.sh
#
# nvm install node --reinstall-packages-from=node --latest-npm
# nvm install-latest-npm
# nvm cache clear
#
# for version in $(nvm ls --no-alias --no-colors | sed 's/ //g' | sed 's/\*//'); do
#   [[ $version =~ '->' ]] || nvm uninstall $version
# done
#
# set -o verbose
#
# npm update --global

CURRENT=$(fnm current)
LATEST=$(fnm ls-remote | tail -1)
if [[ $CURRENT != $LATEST ]]; then
  fnm install --latest
  fnm alias $LATEST default
  fnm use default
  fnm exec --using $CURRENT npm ls --global --json |
    jq --raw-output '.dependencies | to_entries[] | .key' |
    xargs npm install --global
  fnm uninstall $CURRENT
fi

# python

uv tool upgrade --all

# rust

rustup update
cargo install-update --all

# neovim

nvim --headless -c 'Lazy! sync' -c 'quitall'
nvim --headless -c 'TSUpdateSync' -c 'quitall'
nvim --headless -c 'autocmd User MasonToolsUpdateCompleted quitall' -c 'MasonToolsUpdate'

# vscode

code --update-extensions

set +e

for EXTENSION in \
  ms-python.vscode-pylance \
  ms-python.vscode-python-envs
do
  code --uninstall-extension $EXTENSION --force
done

set -e

