#!/usr/bin/env bash
set -eo pipefail -ux

# links (keep existing config or settings provided by installer)

CONFIG=/run/media/$USER/data/.config

if [[ ! -L "$XDG_CONFIG_HOME"/claude ]] && [[ -d "$XDG_CONFIG_HOME"/claude ]] && [[ ! -d "$CONFIG"/claude ]]; then

  mkdir "$CONFIG"/claude

  shopt -s dotglob
  mv "$XDG_CONFIG_HOME"/claude/* "$CONFIG"/claude
  shopt -u dotglob

fi

# mkdir -p "$CONFIG"/claude

[[ -d "$XDG_CONFIG_HOME"/claude ]] && rm -rf "$XDG_CONFIG_HOME"/claude
[[ -L "$XDG_CONFIG_HOME"/claude ]] && rm "$XDG_CONFIG_HOME"/claude

ln -s "$CONFIG"/claude "$XDG_CONFIG_HOME"/claude

# if [[ -f "${BASH_SOURCE%/*}"/claude/claude/settings.$HOST.json ]]; then
#   ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/settings."$HOST".json \
#     "$XDG_CONFIG_HOME"/claude/settings.json
# else
#   ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/settings.json \
#     "$XDG_CONFIG_HOME"/claude/settings.json
# fi

ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/settings.json \
  "$XDG_CONFIG_HOME"/claude/settings.json

[[ $HOST == 'worker' ]] &&
  ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/settings-work.json \
    "$XDG_CONFIG_HOME"/claude/settings-work.json

# mcp

# shellcheck disable=SC2016
if ! claude mcp get github &> /dev/null; then
  claude mcp add-json --scope user github '{
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp",
    "headers": {
      "Authorization": "Bearer ${GITHUB_TOKEN}"
    }
  }'
fi

# if [[ $HOST == 'worker' ]]; then
#
#   if ! claude mcp get atlassian &> /dev/null; then
#     claude mcp add-json --scope user atlassian '{
#       "type": "http",
#       "url": "https://mcp.atlassian.com/v1/mcp"
#     }'
#   fi
#
#   if ! claude mcp get bedrock &> /dev/null; then
#     claude mcp add-json --scope user bedrock '{
#       "type": "stdio",
#       "command": "uvx",
#       "args": ["awslabs.bedrock-kb-retrieval-mcp-server@latest"],
#       "env": {
#         "AWS_PROFILE": "sms_sandbox",
#         "AWS_REGION": "eu-west-1",
#         "BEDROCK_KB_RERANKING_ENABLED": "false"
#       }
#     }'
#   fi
#
#   # shellcheck disable=SC2016
#   if ! claude mcp get sonarqube &> /dev/null; then
#     claude mcp add-json --scope user sonarqube '{
#       "type": "stdio",
#       "command": "docker",
#       "args": [
#         "run",
#         "-i",
#         "--rm",
#         "--init",
#         "--pull=always",
#         "-e",
#         "SONARQUBE_TOKEN",
#         "-e",
#         "SONARQUBE_URL",
#         "mcp/sonarqube"
#       ],
#       "env": {
#         "MCP_TIMEOUT": "15000",
#         "SONARQUBE_TOKEN": "${SONARQUBE_TOKEN}",
#         "SONARQUBE_URL": "https://sonarqube.efficy.cloud/"
#       }
#     }'
#   fi
#
# fi
