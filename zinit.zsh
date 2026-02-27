#!/usr/bin/env zsh

declare -A ZINIT
export ZINIT[HOME_DIR]=$XDG_DATA_HOME/zinit
export ZINIT[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/zcompdump

source "${ZINIT[HOME_DIR]}"/bin/zinit.zsh

zinit self-update
zinit update --all
