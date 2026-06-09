#!/usr/bin/env bash
set -o pipefail -u

LIST=$("$(dirname "$0")"/links.py)
[ -z "$LIST" ] && tmux display-message 'No links' && exit 0

KEYS="$(echo -e "\e[35m<Enter>\e[0m \e[37mOpen\e[0m · \e[35m<C-c>\e[0m \e[37mCopy\e[0m")"

SELECTED=$(
  echo -e "$LIST" |
    fzf --tmux center,33%,33% --layout default \
      --list-border rounded --input-border rounded \
      --list-label 'Links' \
      --ansi \
      --header "$KEYS" --header-first \
      --bind "ctrl-c:execute-silent(echo {} | wl-copy --trim-newline)" \
      --accept-nth 1
)

EXIT=$? && [ $EXIT == 0 ] && xdg-open "$SELECTED" > /dev/null || exit 0
