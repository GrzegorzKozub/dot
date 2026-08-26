#!/usr/bin/env bash
set -eo pipefail -ux

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

FILES=(statusline.sh settings.json)
[[ $HOST == 'worker' ]] && FILES+=(settings-work.json)

for FILE in "${FILES[@]}"; do
  ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/"$FILE" \
    "$XDG_CONFIG_HOME"/claude/"$FILE"
done

mkdir -p "$XDG_CONFIG_HOME"/claude/themes
ln -sf "$(dirname "$(realpath "$0")")"/claude/claude/themes/gruvbox-material-dark.json \
  "$XDG_CONFIG_HOME"/claude/themes/gruvbox-material-dark.json

# lsp

# mise install \
#   npm:bash-language-server@latest \
#   npm:typescript-language-server@latest
uv tool install basedpyright
rustup component add rust-analyzer
[[ $HOST == 'worker' ]] && dotnet tool install --global csharp-ls

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
    --skill handoff

fi

# instructions

if [[ $HOST == 'worker' ]]; then

  curl -fsSL \
    'https://raw.githubusercontent.com/efficy-sa/apsis-shared-ai/master/claude-code/CLAUDE.md' \
    -o "$XDG_CONFIG_HOME"/claude/CLAUDE.md

fi
