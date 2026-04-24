#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# git branch (skip optional locks)
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
  || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

# shorten cwd: replace $HOME with ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# build output
parts=()

# cyan dir
parts+=("$(printf '\e[36m%s\e[0m' "$short_cwd")")

# yellow git branch
if [[ -n "$branch" ]]; then
  parts+=("$(printf '\e[33m%s\e[0m' "$branch")")
fi

# dim model
if [[ -n "$model" ]]; then
  parts+=("$(printf '\e[2m%s\e[0m' "$model")")
fi

# context usage
if [[ -n "$used" ]]; then
  used_int=$(printf '%.0f' "$used")
  parts+=("$(printf '\e[2mctx:%s%%\e[0m' "$used_int")")
fi

# join with spaces
output=""
for part in "${parts[@]}"; do
  [[ -n "$output" ]] && output="$output  "
  output="$output$part"
done

printf '%s' "$output"
