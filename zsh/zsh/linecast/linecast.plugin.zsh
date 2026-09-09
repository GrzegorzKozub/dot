#!/usr/bin/env zsh

_my-compdef-linecast() {
  eval "$(linecast completion zsh)"
  _linecast "$@" # make the completion menu appear on first tab press
}

compdef _my-compdef-linecast linecast
