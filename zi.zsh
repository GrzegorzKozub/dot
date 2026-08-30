#!/usr/bin/env zsh

declare -A ZI
export ZI[HOME_DIR]=$XDG_DATA_HOME/zi
export ZI[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/zcompdump

source "${ZI[HOME_DIR]}"/bin/zi.zsh

zi self-update
zi update --all
