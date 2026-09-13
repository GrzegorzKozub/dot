#!/usr/bin/env zsh

source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

zle -N fzf-history-widget-no-numbers
my-bindkey '^r' fzf-history-widget-no-numbers
