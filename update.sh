#!/usr/bin/env bash
set -eo pipefail -ux

# update self

git pull
git submodule update --init
git submodule foreach --recursive git checkout master
git submodule foreach --recursive git pull

# zsh & zinit

"${BASH_SOURCE%/*}"/zinit.zsh

# tmux

for PLUGIN in "$XDG_DATA_HOME"/tmux/plugins/*; do
  "$XDG_DATA_HOME"/tmux/plugins/tpm/scripts/update_plugin.sh \
    --shell-echo "$(echo "$PLUGIN" | sed 's/^.*\///')"
done

# yazi

ya pkg upgrade

# links

"${BASH_SOURCE%/*}"/links.sh

# shared

"${BASH_SOURCE%/*}"/shared.sh

# node

CURRENT=$(fnm current)
LATEST=$(fnm ls-remote | tail -1)
if [[ $CURRENT != "$LATEST" ]]; then
  fnm install --latest
  fnm alias "$LATEST" default
  fnm use default
  fnm exec --using "$CURRENT" npm ls --global --json |
    jq --raw-output '.dependencies | to_entries[] | .key' |
    xargs npm install --global
  fnm uninstall "$CURRENT"
fi

# python

uv tool upgrade --all

# rust

rustup update
cargo install-update --all

# neovim

nvim --headless -c 'Lazy! sync' -c 'quitall'
nvim --headless -c 'TSUpdate' -c 'quitall'
nvim --headless \
  -c 'autocmd User MasonToolsUpdateCompleted quitall' \
  -c 'MasonToolsUpdate'

# vscode

code --update-extensions

set +e

for EXTENSION in \
  ms-python.vscode-pylance \
  ms-python.vscode-python-envs; do
  code --uninstall-extension $EXTENSION --force
done

set -e
