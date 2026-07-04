#!/usr/bin/env bash
set -eo pipefail -ux

DIR=$(dirname "$(realpath "$0")")
GH='git@github.com:GrzegorzKozub'

declare -A REPOS=(
  ["mpv/mpv"]="$GH/mpv.git"
  ["nvim/nvim"]="$GH/nvim.git"
  ["vscode/user-data"]="$GH/vscode.git"
  ["yazi/yazi"]="$GH/yazi.git"
)

for CLONE in "${!REPOS[@]}"; do
  URL=${REPOS[$CLONE]}
  if [[ -d "$DIR/$CLONE/.git" ]]; then
    git -C "$DIR/$CLONE" fetch origin master
    git -C "$DIR/$CLONE" merge --ff-only origin/master
  else
    git clone "$URL" "$DIR/$CLONE"
  fi
done
