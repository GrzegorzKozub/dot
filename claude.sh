#!/usr/bin/env bash
set -eo pipefail -ux

# links (keep settings provided by installer)

CONFIG=/run/media/$USER/data/.config

mkdir -p "$CONFIG"/claude

if [[ ! -L "$XDG_CONFIG_HOME"/claude ]] && [[ -d "$XDG_CONFIG_HOME"/claude ]]; then

  # rm -rf "$CONFIG"/claude/*

  shopt -s dotglob
  mv "$XDG_CONFIG_HOME"/claude/* "$CONFIG"/claude
  shopt -u dotglob

  rm -r "$XDG_CONFIG_HOME"/claude/

fi

[[ -L "$XDG_CONFIG_HOME"/claude ]] || ln -s "$CONFIG"/claude "$XDG_CONFIG_HOME"/claude

ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/settings.json \
  "$XDG_CONFIG_HOME"/claude/settings.json

# mcp

# shellcheck disable=SC2016
if ! claude mcp get GitHub &> /dev/null; then
  claude mcp add-json --scope user GitHub '{
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp",
    "headers": {
      "Authorization": "Bearer ${GITHUB_TOKEN}"
    }
  }'
fi

if [[ $HOST =~ ^(drifter|worker)$ ]]; then

  if ! claude mcp get Atlassian &> /dev/null; then
    claude mcp add-json --scope user Atlassian '{
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp"
    }'
  fi

  if ! claude mcp get Bedrock &> /dev/null; then
    claude mcp add-json --scope user Bedrock '{
      "type": "stdio",
      "command": "uvx",
      "args": ["awslabs.bedrock-kb-retrieval-mcp-server@latest"],
      "env": {
        "AWS_PROFILE": "sms_sandbox",
        "AWS_REGION": "eu-west-1",
        "BEDROCK_KB_RERANKING_ENABLED": "false"
      }
    }'
  fi

fi
