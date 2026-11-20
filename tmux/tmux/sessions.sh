#!/usr/bin/env bash
set -o pipefail -u

list() {
  local tab=$'\t'
  tmux list-sessions -F "$(printf '%s\t' \
    '#{session_activity}' \
    '#{session_name}' \
    '#{t/p:session_activity}' \
    '#{session_windows}' \
    '#{W:#{P:.}}' \
    '#{session_attached}' \
    '#{session_path}' \
    '#{pane_current_command}' \
    '#{window_zoomed_flag}' \
    '#{pane_synchronized}')#{session_alerts}" |
    sort --field-separator "$tab" --key 1,1nr |
    awk -F "$tab" -v OFS="$tab" \
      -v current="$(tmux display-message -p '#{session_name}')" \
      -v home="$HOME" '
      {
        marker = ($2 == current) ? "\033[33m󰞷\033[0m" : "\302\240"
        path = (index($7, home) == 1) ? "~" substr($7, length(home) + 1) : $7
        row[NR] = marker OFS $2 OFS "" OFS $3 OFS "" OFS $6 OFS "" OFS $4 OFS "" OFS length($5) OFS "" OFS path OFS "" OFS $8
        zoom[NR] = $9 ? "" : ""
        sync[NR] = $10 ? "󰓦" : ""
        alert[NR] = $11 ~ /!/ ? "" : $11 ~ /#/ ? "" : ""
        zooms += $9 != 0; syncs += $10 != 0; alerts += alert[NR] != ""
      }
      # one column per indicator so each lines up vertically; columns no session uses are left out
      END {
        for (i = 1; i <= NR; i++)
          print row[i] (zooms ? OFS zoom[i] : "") (syncs ? OFS sync[i] : "") (alerts ? OFS alert[i] : "")
      }' |
    column --separator "$tab" --output-separator ' ' --table --table-right 2,4,6,8,10
}

if [ "${1:-}" == --list ]; then
  list
  exit
fi

KEYS="$(echo -e "\e[35m<Enter>\e[0m \e[37mSwitch\e[0m · \e[35m<C-k>\e[0m \e[37mKill\e[0m · \e[35m<C-n>\e[0m \e[37mNew\e[0m")"

SELECTED=$(
  list |
    fzf --tmux center,33%,33% --layout default \
      --list-border rounded --input-border rounded \
      --list-label 'Sessions' \
      --ansi \
      --header "$KEYS" --header-first \
      --bind "ctrl-k:execute-silent(tmux kill-session -t {2})+reload('$0' --list)" \
      --bind "ctrl-n:execute-silent(tmux new-session -c $(tmux display-message -p '#{pane_current_path}') -d)+reload('$0' --list)" \
      --accept-nth 2
) || exit 0

tmux switch-client -t "$SELECTED"
