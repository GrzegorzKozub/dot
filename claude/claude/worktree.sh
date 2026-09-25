#!/usr/bin/env bash
set -eo pipefail -u

# PreToolUse: block edits in the main checkout of repos under ~/code/apsis

ROOT=$HOME/code/apsis

FILE=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')
[[ $FILE == "$ROOT"/* ]] || exit 0

DIR=$(dirname "$FILE")
while [[ ! -d $DIR ]]; do DIR=$(dirname "$DIR"); done

mapfile -t GIT < <(git -C "$DIR" rev-parse --path-format=absolute --show-toplevel --git-dir --git-common-dir 2> /dev/null || :)
((${#GIT[@]} == 3)) || exit 0
[[ ${GIT[1]} != "${GIT[2]}" ]] && exit 0
[[ ${GIT[0]} == *wiki ]] && exit 0

echo "${GIT[0]} is a main checkout. Create a worktree for the story first: cd ${GIT[0]} (its own call), git fetch --prune, then git worktree add .claude/worktrees/<KEY> -b <KEY>-<slug> origin/<default-branch>, and edit the file under that worktree instead." >&2
exit 2
