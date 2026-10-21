#!/usr/bin/env zsh

(( $+commands[claude] )) || return

export CLAUDE_CONFIG_DIR=$XDG_CONFIG_HOME/claude

if [[ $HOST == 'worker' ]]; then
  alias claude-work='claude --settings $CLAUDE_CONFIG_DIR/settings-work.json'
fi

