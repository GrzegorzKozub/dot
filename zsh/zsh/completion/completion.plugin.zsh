#!/usr/bin/env zsh

bindkey -M menuselect '^[[Z' reverse-menu-complete # shift+tab

for key in '^[[5~' '^U' # page up, ctrl+u
  do bindkey -M menuselect $key backward-word; done

for key in '^[[6~' '^D' # page down, ctrl+d
  do bindkey -M menuselect $key forward-word; done

bindkey -M menuselect '^F' history-incremental-search-forward # ctrl+f
bindkey -M menuselect '^B' history-incremental-search-backward # ctrl+b
