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

# links

. `dirname $0`/links.zsh

# shared

. `dirname $0`/shared.zsh

# node

set +o verbose

export NVM_DIR=$XDG_DATA_HOME/nvm
source $NVM_DIR/nvm.sh

nvm install node --reinstall-packages-from=node --latest-npm
nvm install-latest-npm
nvm cache clear

for version in $(nvm ls --no-alias --no-colors | sed 's/ //g' | sed 's/\*//'); do
  [[ $version =~ '->' ]] || nvm uninstall $version
done

set -o verbose

npm update --global

# rust

rustup update
cargo install-update --all

# neovim

nvim --headless -c 'Lazy! sync' -c 'quitall'
nvim --headless -c 'TSUpdateSync' -c 'quitall'
nvim --headless -c 'autocmd User MasonToolsUpdateCompleted quitall' -c 'MasonToolsUpdate'

# vscode

code --update-extensions

