#!/usr/bin/env zsh

(( $+commands[claude] )) || exit

export CLAUDE_CONFIG_DIR=$XDG_CONFIG_HOME/claude

# alias claude-llama='ANTHROPIC_API_KEY=foo \
#   ANTHROPIC_BASE_URL=http://localhost:8080 \
#   ANTHROPIC_MODEL=llama \
#   claude'
alias claude-work='claude --settings $CLAUDE_CONFIG_DIR/settings-work.json'

