#!/usr/bin/env bash
set -o pipefail -u

CURRENT="(\$1==\"$(tmux display-message -p '#{session_name}')\") { print \"\033[33m󰞷\033[0m \" \$0; next } { print \"$(echo -e '\u00A0') \" \$0 }"

QUERY="
  tmux list-sessions \
    -F '#{session_name}  #{t/p:session_created}  #{session_windows}  #{session_attached}  #{?session_grouped,#{session_group_size},1}  #{session_path}' | \
  sed -e 's|$HOME|~|' | \
  awk '$CURRENT' | \
  column --output-separator ' ' --table --table-right 2,4,6,8,10 | \
  sort --field-separator ' ' --key 4 --reverse
"

LIST=$(eval "$QUERY") # && LIST=${LIST//$HOME/\~}

KEYS="$(echo -e "\e[35m<Enter>\e[0m \e[37mSwitch\e[0m · \e[35m<C-g>\e[0m \e[37mGroup\e[0m · \e[35m<C-k>\e[0m \e[37mKill\e[0m · \e[35m<C-n>\e[0m \e[37mNew\e[0m")"

OUTPUT=$(
  echo -e "$LIST" |
    fzf --tmux center,33%,33% --layout default \
      --list-border rounded --input-border rounded \
      --list-label 'Sessions' \
      --ansi \
      --header "$KEYS" --header-first \
      --bind "ctrl-k:execute-silent(tmux kill-session -t {2})+reload($QUERY)" \
      --bind "ctrl-n:execute-silent(tmux new-session -c $(tmux display-message -p '#{pane_current_path}') -d)+reload($QUERY)" \
      --expect ctrl-g \
      --accept-nth 2
) || exit 0

KEY=${OUTPUT%%$'\n'*}
SELECTED=${OUTPUT#*$'\n'}

if [ "$KEY" == ctrl-g ]; then
  GROUPED=$(tmux new-session -d -t "=$SELECTED" -P -F '#{session_name}') &&
    tmux switch-client -t "=$GROUPED" &&
    tmux set-option -t "=$GROUPED:" destroy-unattached on
else
  tmux switch-client -t "$SELECTED"
fi
