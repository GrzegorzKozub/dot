#!/usr/bin/env zsh

_my-compdef-npm() { eval "$(npm completion)" } # zsh-lint disable=security/eval
compdef _my-compdef-npm npm
