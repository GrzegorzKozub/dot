#!/usr/bin/env bash
set -eo pipefail -ux

# bash

rm -f ~/.{bash_history,bash_logout,bash_profile,bashrc}

# claude

rm -rf "$XDG_CACHE_HOME"/claude-cli-nodejs/
# rm -rf "$XDG_CONFIG_HOME"/anthropic/

# github

rm -rf "$XDG_CACHE_HOME"/gh/

# go

rm -rf "$XDG_CACHE_HOME"/{goimports,gopls}/

# gopass

rm -rf "$XDG_CACHE_HOME"/gopass/

# linecast

rm -rf "$XDG_CACHE_HOME"/linecast/

# node

rm -rf ~/.{npm,yarn}/
rm -f ~/.yarnrc
rm -rf "$XDG_CACHE_HOME"/{js-v8flags,node,node-gyp,yarn}/

# nvim

rm -rf "$XDG_CACHE_HOME"/{luarocks,nvim,tree-sitter}/

# tensaku

rm -rf "$XDG_CACHE_HOME"/tensaku/
rm -rf "$XDG_STATE_HOME"/tensaku/

# vscode

rm -rf "$XDG_CACHE_HOME"/copilot/
rm -rf "$XDG_CONFIG_HOME"/copilot/

# wget

rm -f ~/.wget-hsts

# zed

rm -rf "$XDG_CACHE_HOME"/zed/

# zsh

rm -f ~/.zshrc
# rm -rf "$XDG_CACHE_HOME"/gitstatus/

# root

sudo find /root -mindepth 1 -delete
