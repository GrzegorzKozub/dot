#!/usr/bin/env zsh

_my-compdef-cargo() { eval "$(rustup completions zsh cargo)" } # zsh-lint disable=security/eval
compdef _my-compdef-cargo cargo
