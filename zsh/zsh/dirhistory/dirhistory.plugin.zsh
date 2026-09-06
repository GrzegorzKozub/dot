#!/usr/bin/env zsh

# active shortcuts after this file's overrides:
#   ctrl+o          - dirhistory back (viins & vicmd)
#   ctrl+i          - dirhistory forward (vicmd only)
#   esc-left/right  - dirhistory back/forward (from upstream plugin, untouched)

bindkey -M viins '^O' dirhistory_zle_dirhistory_back # ctrl+o
bindkey -M vicmd '^O' dirhistory_zle_dirhistory_back
bindkey -M vicmd '^I' dirhistory_zle_dirhistory_future # ctrl+i

# free up alt+arrows for tmux; keep esc-left/esc-right (^[^[[D / ^[^[[C) for dirhistory back/forward
for keymap in vicmd viins; do
  bindkey -r -M $keymap '^[^[[B'  # esc up
  bindkey -r -M $keymap '^[^[[A'  # esc down
  bindkey -r -M $keymap '\e[3D'   # alt+left
  bindkey -r -M $keymap '\e[1;3D' # alt+left
  bindkey -r -M $keymap '\eO3D'   # alt+left
  bindkey -r -M $keymap '\e[3C'   # alt+right
  bindkey -r -M $keymap '\e[1;3C' # alt+right
  bindkey -r -M $keymap '\eO3C'   # alt+right
  bindkey -r -M $keymap '\e[3A'   # alt+up
  bindkey -r -M $keymap '\e[1;3A' # alt+up
  bindkey -r -M $keymap '\eO3A'   # alt+up
  bindkey -r -M $keymap '\e[3B'   # alt+down
  bindkey -r -M $keymap '\e[1;3B' # alt+down
  bindkey -r -M $keymap '\eO3B'   # alt+down
done
unset keymap
