#!/usr/bin/env bash
set -eo pipefail -u

# PreToolUse: under ~/code/apsis, block edits in main checkouts and uppercase worktree names

ROOT=$HOME/code/apsis
ADD='git[[:space:]]+worktree[[:space:]]+add'
NEW='(^|[[:space:];&|])wt[[:space:]].*switch[[:space:]].*(-c|--create)([[:space:]]|$)'
VALUE='^(-b|--base|-x|--execute|-C|--config|--config-set)$'

INPUT=$(cat)

CMD=$(jq -r '.tool_input.command // ""' <<< "$INPUT")
if [[ -n $CMD ]]; then
  [[ $(jq -r '.cwd // ""' <<< "$INPUT") == "$ROOT"* ]] || exit 0
  [[ $CMD =~ $ADD || $CMD =~ $NEW ]] || exit 0
  read -ra W <<< "$CMD"
  SWITCH='' CHANGED=''
  for I in "${!W[@]}"; do
    T=${W[I]} P=''
    ((I > 0)) && P=${W[I - 1]}
    if [[ $T == .worktrees/* || ($P == -[bB] && $CMD =~ $ADD) ]] ||
      [[ $SWITCH && $T != -* && ! $P =~ $VALUE ]]; then
      W[I]=${T,,}
    fi
    [[ ${W[I]} != "$T" ]] && CHANGED=1
    [[ $T == switch && $CMD =~ $NEW ]] && SWITCH=1
  done
  [[ $CHANGED ]] || exit 0
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

if command -v wt > /dev/null; then
  NEWTREE='wt switch --create <key> --base origin/<default-branch> --no-cd --yes'
else
  NEWTREE='git worktree add .worktrees/<key> -b <key> origin/<default-branch>'
fi

echo "${GIT[0]} is a main checkout. Create a worktree for the story first: cd ${GIT[0]} (its own call), git fetch --prune, then $NEWTREE, and edit the file under ${GIT[0]}/.worktrees/<key> instead. <key> is the lowercase Jira key, e.g. ao-1234." >&2
exit 2
