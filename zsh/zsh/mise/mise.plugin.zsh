#!/usr/bin/env zsh

eval "$(mise activate zsh)"

_my-compdef-mise() {
  eval "$(mise completion zsh)"
  _mise "$@" # make the completion menu appear on first tab press
}

compdef _my-compdef-mise mise
