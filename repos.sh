#!/usr/bin/env bash
set -eo pipefail -ux

# repos previously tracked as git submodules

REPOS=(
  "nvim/nvim|git@github.com:GrzegorzKozub/nvim.git"
  "vscode/user-data|git@github.com:GrzegorzKozub/vscode.git"
  "mpv/mpv|git@github.com:GrzegorzKozub/mpv.git"
  "yazi/yazi|git@github.com:GrzegorzKozub/yazi.git"
)

DIR=$(dirname "$(realpath "$0")")

init() {
  for REPO in "${REPOS[@]}"; do
    PATH_=${REPO%%|*}
    URL=${REPO##*|}
    [[ -d "$DIR/$PATH_/.git" ]] || git clone "$URL" "$DIR/$PATH_"
  done
}

update() {
  for REPO in "${REPOS[@]}"; do
    PATH_=${REPO%%|*}
    URL=${REPO##*|}
    if [[ -d "$DIR/$PATH_/.git" ]]; then
      git -C "$DIR/$PATH_" fetch origin master
      git -C "$DIR/$PATH_" merge --ff-only origin/master
    else
      git clone --branch master "$URL" "$DIR/$PATH_"
    fi
  done
}

case "${1:-}" in
init) init ;;
update) update ;;
*)
  echo "usage: $0 {init|update}" >&2
  exit 1
  ;;
esac
