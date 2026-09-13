#!/usr/bin/env zsh

eval "$(mise activate zsh)" # zsh-lint disable=security/eval

_my-compdef-mise() {
  eval "$(mise completion zsh)" # zsh-lint disable=security/eval
  _mise "$@" # make the completion menu appear on first tab press
}

compdef _my-compdef-mise mise
