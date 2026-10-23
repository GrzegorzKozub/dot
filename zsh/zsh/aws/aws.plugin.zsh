#!/usr/bin/env zsh

(( $+commands[aws] )) || return

# export AWS_CONFIG_FILE=$XDG_CONFIG_HOME/aws/config
# export AWS_SHARED_CREDENTIALS_FILE=$XDG_CONFIG_HOME/aws/credentials

export AWS_SDK_LOAD_CONFIG=1

export SAM_CLI_TELEMETRY=0

complete -C "${commands[aws_completer]}" aws
