#!/usr/bin/env zsh

_my-compdef-dotnet() { _values = "${(ps:\n:)$(dotnet complete "$words")}" }
compdef _my-compdef-dotnet dotnet
