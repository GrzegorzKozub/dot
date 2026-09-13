#!/usr/bin/env zsh

save() {
  (( ZSH_SUBSHELL == 0 )) || return 0
  print -r -- "$PWD" >| "$ZSH_CACHE_DIR"/lwd
}

autoload -U add-zsh-hook && add-zsh-hook chpwd save

change() {
  local file="$ZSH_CACHE_DIR"/lwd
  [[ -r "$file" ]] && cd "$(<"$file")"
}

typeset -g -i ZSH_LWD_CHANGED=0
(( ! ZSH_LWD_CHANGED )) && [[ "$PWD" == "$HOME" ]] || return 0
if change 2>/dev/null; then ZSH_LWD_CHANGED=1; fi
