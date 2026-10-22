#!/usr/bin/env zsh

(( $+commands[auth0] )) || return

_my-compdef-auth0() { eval "$(auth0 completion zsh)" } # zsh-lint disable=security/eval
compdef _my-compdef-auth0 auth0
