#!/usr/bin/env bash
set -eo pipefail -ux

# packages

ln -sf "$XDG_CONFIG_HOME"/mise/conf.d/claude.env.toml \
  "$XDG_CONFIG_HOME"/mise/conf.d/claude."$HOST".local.toml

command -v dotnet > /dev/null 2>&1 &&
  ln -sf "$XDG_CONFIG_HOME"/mise/conf.d/csharp-ls.env.toml \
    "$XDG_CONFIG_HOME"/mise/conf.d/csharp-ls."$HOST".local.toml

mise install

uv tool install basedpyright
rustup component add rust-analyzer
# command -v dotnet > /dev/null 2>&1 && dotnet tool install --global csharp-ls

# env

export CLAUDE_CONFIG_DIR=$XDG_CONFIG_HOME/claude

# links (keep existing config or settings provided by installer)

CONFIG=/run/media/$USER/data/.config

if [[ ! -L "$XDG_CONFIG_HOME"/claude ]] && [[ -d "$XDG_CONFIG_HOME"/claude ]] && [[ ! -d "$CONFIG"/claude ]]; then

  mkdir -p "$CONFIG"/claude

  shopt -s dotglob
  mv "$XDG_CONFIG_HOME"/claude/* "$CONFIG"/claude
  shopt -u dotglob

fi

[[ ! -d "$CONFIG"/claude ]] && mkdir -p "$CONFIG"/claude

[[ -d "$XDG_CONFIG_HOME"/claude ]] && rm -rf "$XDG_CONFIG_HOME"/claude
[[ -L "$XDG_CONFIG_HOME"/claude ]] && rm "$XDG_CONFIG_HOME"/claude

ln -s "$CONFIG"/claude "$XDG_CONFIG_HOME"/claude

FILES=(keybindings.json statusline.sh settings.json)
[[ $HOST == 'worker' ]] && FILES+=(settings-work.json)

for FILE in "${FILES[@]}"; do
  ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/"$FILE" \
    "$XDG_CONFIG_HOME"/claude/"$FILE"
done

mkdir -p "$XDG_CONFIG_HOME"/claude/themes
ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/themes/gruvbox-material-dark.json \
  "$XDG_CONFIG_HOME"/claude/themes/gruvbox-material-dark.json

# mcp

# shellcheck disable=SC2016
# if ! claude mcp get github &> /dev/null; then
#   claude mcp add-json --scope user github '{
#     "type": "http",
#     "url": "https://api.githubcopilot.com/mcp",
#     "headers": {
#       "Authorization": "Bearer ${GITHUB_TOKEN}"
#     }
#   }'
# fi

# skills

if [[ $HOST == 'worker' ]]; then

  npx --yes skills add mattpocock/skills \
    --agent claude-code --copy --global --yes \
    --skill grill-me \
    --skill grilling \
    --skill handoff

fi

# instructions

if [[ $HOST == 'worker' ]]; then

  gh api repos/efficy-sa/apsis-shared-ai/contents/claude-code/CLAUDE.md \
    --jq '.content' | base64 -d > "$XDG_CONFIG_HOME"/claude/CLAUDE.md

fi
