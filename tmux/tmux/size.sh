#!/usr/bin/env bash
set -eo pipefail -u

PANE=$1
AXIS=$2
PANE_SIZE=$3
WINDOW_SIZE=$4

PERCENT=$((PANE_SIZE * 100 / WINDOW_SIZE))

if [ "$PERCENT" -lt 41 ]; then
  tmux resize-pane -t "$PANE" "$AXIS" 50%
elif [ "$PERCENT" -lt 58 ]; then
  tmux resize-pane -t "$PANE" "$AXIS" 66%
else
  tmux resize-pane -t "$PANE" "$AXIS" 33%
fi
