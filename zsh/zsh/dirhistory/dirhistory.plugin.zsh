#!/usr/bin/env zsh

bindkey -r '^[^[[B' # esc up
bindkey -r '^[^[[A' # esc down

bindkey -M viins '^O' dirhistory_zle_dirhistory_back # ctrl+o
bindkey -M vicmd '^O' dirhistory_zle_dirhistory_back
bindkey -M vicmd '^I' dirhistory_zle_dirhistory_future # ctrl+i
