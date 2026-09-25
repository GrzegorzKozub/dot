#!/usr/bin/env bash
set -eo pipefail -u

# PreToolUse: under ~/code/apsis, block edits in main checkouts and uppercase worktree names

ROOT=$HOME/code/apsis
ADD='git[[:space:]]+worktree[[:space:]]+add'
UPPER='(\.worktrees/|-[bB][[:space:]]+)[^[:space:]]*[A-Z]'

INPUT=$(cat)

CMD=$(jq -r '.tool_input.command // ""' <<< "$INPUT")
if [[ -n $CMD ]]; then
  [[ $(jq -r '.cwd // ""' <<< "$INPUT") == "$ROOT"* ]] || exit 0
  [[ $CMD =~ $ADD && $CMD =~ $UPPER ]] || exit 0
  read -ra W <<< "$CMD"
  for I in "${!W[@]}"; do
    if [[ ${W[I]} == .worktrees/* ]] || { ((I > 0)) && [[ ${W[I - 1]} == -[bB] ]]; }; then
      W[I]=${W[I],,}
    fi
  done
  echo "Use the lowercase Jira key in the worktree path and branch: ${W[*]}" >&2
  exit 2
fi

FILE=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' <<< "$INPUT")
[[ $FILE == "$ROOT"/* ]] || exit 0

DIR=$(dirname "$FILE")
while [[ ! -d $DIR ]]; do DIR=$(dirname "$DIR"); done

mapfile -t GIT < <(git -C "$DIR" rev-parse --path-format=absolute --show-toplevel --git-dir --git-common-dir 2> /dev/null || :)
((${#GIT[@]} == 3)) || exit 0
[[ ${GIT[1]} != "${GIT[2]}" ]] && exit 0
[[ ${GIT[0]} == *wiki ]] && exit 0

echo "${GIT[0]} is a main checkout. Create a worktree for the story first: cd ${GIT[0]} (its own call), git fetch --prune, then git worktree add .worktrees/<key> -b <key>-<slug> origin/<default-branch>, and edit the file under that worktree instead. <key> is the lowercase Jira key, e.g. ao-1234." >&2
exit 2
