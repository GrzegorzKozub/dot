#!/usr/bin/env zsh

_my-compdef-npm() { eval "$(npm completion)" }
compdef _my-compdef-npm npm
