#!/usr/bin/env bash
set -eo pipefail -ux

if [[ ${1:-} == 'node' ]]; then
  rm -rf "$XDG_CACHE_HOME"/npm
  npm install --global \
    eslint \
    neovim \
    typescript
fi

if [[ ${1:-} == 'nvim' ]]; then
  rm -rf "$XDG_CACHE_HOME"/nvim
  rm -rf "$XDG_DATA_HOME"/nvim
  rm -rf ~/.local/state/nvim
  nvim \
    -c 'lua vim.opt.messagesopt = "wait:100,history:500"' \
    -c 'autocmd User MasonToolsUpdateCompleted quitall' \
    -c 'autocmd User VeryLazy MasonToolsUpdate'
fi

if [[ ${1:-} == 'rust' ]]; then
  rm -rf "$XDG_DATA_HOME"/cargo
  rm -rf "$XDG_DATA_HOME"/rustup
  curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
  cargo install cargo-update
fi
