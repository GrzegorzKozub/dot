#!/usr/bin/env bash
set -eo pipefail -ux

# elixir

# export HEX_HOME=$XDG_CACHE_HOME/hex
# export MIX_HOME=$XDG_DATA_HOME/mix
#
# [[ -d $HEX_HOME ]] && rm -rf "$HEX_HOME"
# [[ -d $MIX_HOME ]] && rm -rf "$MIX_HOME"
# [[ -d $XDG_CACHE_HOME/rebar3 ]] && rm -rf "$XDG_CACHE_HOME"/rebar3
#
# mix local.hex --force
# mix local.rebar --force
# mix archive.install hex phx_new --force

# go

export GOCACHE=$XDG_CACHE_HOME/go
export GOPATH=$XDG_DATA_HOME/go

for PACKAGE in \
  github.com/cweill/gotests/gotests \
  github.com/fatih/gomodifytags \
  github.com/go-delve/delve/cmd/dlv \
  github.com/haya14busa/goplay/cmd/goplay \
  github.com/josharian/impl \
  golang.org/x/tools/cmd/goimports \
  golang.org/x/tools/gopls \
  honnef.co/go/tools/cmd/staticcheck; do
  go install -v $PACKAGE@latest
done

# ruby

# [[ -d $XDG_DATA_HOME/gem ]] && rm -rf "$XDG_DATA_HOME"/gem
#
# gem install --user-install \
#   neovim
