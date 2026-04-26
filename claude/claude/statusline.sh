#!/usr/bin/env bash
set -eo pipefail -ux

INPUT=$(cat)

DIR=$(echo "$INPUT" | jq -r '.workspace.current_dir')
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // empty' | sed -E 's/ ?\([^)]*\)//' | tr '[:upper:]' '[:lower:]')
USED=$(echo "$INPUT" | jq -r '.context_window.used_percentage // empty')
MAX=$(echo "$INPUT" | jq -r '.context_window.context_window_size // empty')
COST=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // empty')
EFFORT=$(echo "$INPUT" | jq -r '.effort.level // empty')
THINKING=$(echo "$INPUT" | jq -r '.thinking.enabled // empty')

short_cwd="${DIR/#$HOME/\~}"

BRANCH=$(git -C "$DIR" symbolic-ref --short HEAD 2> /dev/null)
TAG=""
if [[ -z "$BRANCH" ]]; then
  TAG=$(git -C "$DIR" describe --exact-match --tags HEAD 2> /dev/null)
  BRANCH="${TAG:-$(git -C "$DIR" rev-parse --short HEAD 2> /dev/null)}"
fi

PARTS=()

PARTS+=("$(printf '\e[36m%s\e[0m' "$short_cwd")")

if [[ -n "$BRANCH" ]]; then
  if [[ -n "$TAG" ]]; then
    git_str="$(printf '\e[35m%s\e[0m' "$BRANCH")"
  else
    git_str="$(printf '\e[34m%s\e[0m' "$BRANCH")"
  fi
  read -r BEHIND AHEAD < <(git -C "$DIR" rev-list --left-right --count '@{u}...HEAD' 2> /dev/null || echo "0 0")
  ((BEHIND > 0)) && git_str="$git_str $(printf '\e[33m↓%d\e[0m' "$BEHIND")"
  ((AHEAD > 0)) && git_str="$git_str $(printf '\e[32m↑%d\e[0m' "$AHEAD")"
  STASHES=$(git -C "$DIR" stash list 2> /dev/null | wc -l)
  ((STASHES > 0)) && git_str="$git_str $(printf '\e[35m←%d\e[0m' "$STASHES")"
  read -r CONFLICTED STAGED UNSTAGED UNTRACKED < <(git -C "$DIR" status --porcelain 2> /dev/null | awk '
    BEGIN { c=0; s=0; u=0; t=0 }
    {
      x=substr($0,1,1); y=substr($0,2,1);
      if (x=="?" && y=="?") { t++; next }
      if (x=="U" || y=="U" || (x=="A" && y=="A") || (x=="D" && y=="D")) { c++; next }
      if (x!=" " && x!="?") s++;
      if (y!=" " && y!="?") u++;
    }
    END { print c, s, u, t }')
  ((CONFLICTED > 0)) && git_str="$git_str $(printf '\e[31m?%d\e[0m' "$CONFLICTED")"
  ((STAGED > 0)) && git_str="$git_str $(printf '\e[32m+%d\e[0m' "$STAGED")"
  ((UNSTAGED > 0)) && git_str="$git_str $(printf '\e[33m~%d\e[0m' "$UNSTAGED")"
  ((UNTRACKED > 0)) && git_str="$git_str $(printf '\e[31m*%d\e[0m' "$UNTRACKED")"
  PARTS+=("$git_str")
fi

if [[ -n "$MODEL" ]]; then
  model_str="$MODEL"
  [[ -n "$EFFORT" ]] && model_str="$model_str $EFFORT"
  [[ "$THINKING" == "true" ]] && model_str="$model_str "
  PARTS+=("$(printf '\e[2m󰚩 %s\e[0m' "$model_str")")
fi

fmt_tokens() {
  LC_ALL=C awk -v n="$1" 'BEGIN {
    if (n >= 1000000) printf "%gM", n/1000000;
    else if (n >= 1000) printf "%gk", n/1000;
    else printf "%d", n;
  }'
}

if [[ -n "$USED" && -n "$MAX" ]]; then
  used_int=$(LC_ALL=C printf '%.0f' "$USED")
  used_tokens=$(LC_ALL=C awk -v p="$USED" -v m="$MAX" 'BEGIN { printf "%.0f", p * m / 100 }')
  PARTS+=("$(printf '\e[2m󰆼 %s of %s (%s%%)\e[0m' "$(fmt_tokens "$used_tokens")" "$(fmt_tokens "$MAX")" "$used_int")")
elif [[ -n "$USED" ]]; then
  used_int=$(LC_ALL=C printf '%.0f' "$USED")
  PARTS+=("$(printf '\e[2m󰆼 %s%%\e[0m' "$used_int")")
fi

OUTPUT=""
for part in "${PARTS[@]}"; do
  [[ -n "$OUTPUT" ]] && OUTPUT="$OUTPUT "
  OUTPUT="$OUTPUT$part"
done

if [[ -n "$COST" ]]; then
  OUTPUT="$OUTPUT"$'\n'"$(LC_ALL=C printf '\e[2m $%.2f\e[0m' "$COST")"
fi

printf '%s' "$OUTPUT"
