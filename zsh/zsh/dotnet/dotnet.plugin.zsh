#!/usr/bin/env zsh

(( $+commands[dotnet] )) || return

export DOTNET_CLI_HOME=$XDG_CACHE_HOME/dotnet # https://github.com/dotnet/runtime/issues/98276
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_GENERATE_ASPNET_CERTIFICATE=0
export DOTNET_NOLOGO=1
export DOTNET_SKIP_WORKLOAD_INTEGRITY_CHECK=1

export OMNISHARPHOME=$XDG_DATA_HOME/omnisharp

_my-compdef-dotnet() { _values = "${(ps:\n:)$(dotnet complete "$words")}" }
compdef _my-compdef-dotnet dotnet
