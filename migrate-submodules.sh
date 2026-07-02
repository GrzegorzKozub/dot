#!/usr/bin/env bash
set -eo pipefail -ux

# one-time (idempotent) conversion of git submodules into standalone repos,
# preserving each submodule's existing working tree (including untracked,
# machine-local content) instead of deleting and re-cloning

REPO_PATHS=(
  nvim/nvim
  vscode/user-data
  mpv/mpv
  yazi/yazi
  nushell/nushell
)

DIR=$(dirname "$(realpath "$0")")

for PATH_ in "${REPO_PATHS[@]}"; do
  FULL="$DIR/$PATH_"
  GITLINK="$FULL/.git"

  if [[ -d "$GITLINK" ]]; then
    echo "$PATH_ already a standalone repo, skipping"
  elif [[ -f "$GITLINK" ]]; then
    GITDIR=$(sed -n 's/^gitdir: //p' "$GITLINK")
    [[ "$GITDIR" = /* ]] || GITDIR="$FULL/$GITDIR"
    GITDIR=$(realpath "$GITDIR")

    rm "$GITLINK"
    mv "$GITDIR" "$FULL/.git"

    git -C "$FULL" config --unset core.worktree || true
    git -C "$FULL" config --unset core.bare || true
  else
    echo "$PATH_ has no .git, skipping" >&2
  fi

  git -C "$DIR" rm --cached --quiet "$PATH_" 2>/dev/null || true
  git -C "$DIR" config --remove-section "submodule.$PATH_" 2>/dev/null || true
done

[[ -f "$DIR/.gitmodules" ]] && rm "$DIR/.gitmodules"
