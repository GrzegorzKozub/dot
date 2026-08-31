#!/usr/bin/env zsh

_my-compdef-cargo() { eval "$(rustup completions zsh cargo)" }
compdef _my-compdef-cargo cargo
