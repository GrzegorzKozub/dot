#!/usr/bin/env zsh

typeset -A ZI
: ${ZI[HOME_DIR]:="${XDG_DATA_HOME}/zi"}
: ${ZI[BIN_DIR]:="${ZI[HOME_DIR]}/bin"}

source "${ZI[BIN_DIR]}"/zi.zsh

zi self-update
zi update --all

