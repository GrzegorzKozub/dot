#!/usr/bin/env zsh

# prevent dirs & files in rustup completion menu
zstyle ':completion:*:*:rustup:argument-1:*' ignored-patterns '*'

_my-compdef-rustup() {
  eval "$(rustup completions zsh)"
  _rustup "$@" # make the completion menu appear on first tab press
}

compdef _my-compdef-rustup rustup
