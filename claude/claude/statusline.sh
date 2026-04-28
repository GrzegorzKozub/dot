#!/usr/bin/env bash
set -eo pipefail -u
export LC_NUMERIC=C

mapfile -t FIELDS < <(jq -r '
  (.context_window.current_usage // {}) as $u
  | (
      .workspace.current_dir // "",
      ((.model.display_name // "") | gsub(" ?\\([^)]*\\)"; "") | ascii_downcase),
      (.context_window.used_percentage // ""),
      (.context_window.context_window_size // ""),
      ((($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0)) | if . > 0 then . else "" end),
      (.cost.total_cost_usd // ""),
      .effort.level // "",
      .vim.mode // "",
      .session_id // "default"
    )')
DIR=${FIELDS[0]}
MODEL=${FIELDS[1]}
USED=${FIELDS[2]}
MAX=${FIELDS[3]}
CUR_IN=${FIELDS[4]}
COST=${FIELDS[5]}
EFFORT=${FIELDS[6]}
VIM_MODE=${FIELDS[7]}
SESSION_ID=${FIELDS[8]}

CACHE_FILE="${TMPDIR:-/tmp}/statusline-git-cache-$SESSION_ID"
CACHE_MAX_AGE=5

CTX_ICONS=('󰪞' '󰪟' '󰪠' '󰪡' '󰪢' '󰪣' '󰪤' '󰪥')

cache_is_stale() {
  [[ ! -f $CACHE_FILE ]] && return 0
  local mtime
  mtime=$(stat -c %Y "$CACHE_FILE" 2> /dev/null || stat -f %m "$CACHE_FILE" 2> /dev/null || echo 0)
  ((EPOCHSECONDS - mtime > CACHE_MAX_AGE))
}

fmt_tokens() {
  # shellcheck disable=SC2034
  local -n OUT=$1
  local n=$2
  if ((n >= 1000000)); then
    printf -v OUT '%dM' $(((n + 500000) / 1000000))
  elif ((n >= 1000)); then
    printf -v OUT '%dk' $(((n + 500) / 1000))
  else
    printf -v OUT '%d' "$n"
  fi
}

ctx_icon() {
  local -n OUT=$1
  local pct=${2%.*}
  local idx=$((pct * 8 / 100))
  ((idx > 7)) && idx=7
  ((idx < 0)) && idx=0
  # shellcheck disable=SC2034
  OUT="${CTX_ICONS[idx]}"
}

if cache_is_stale; then
  BRANCH=$(git -C "$DIR" symbolic-ref --short HEAD 2> /dev/null || :)
  TAG=""
  if [[ -z $BRANCH ]]; then
    TAG=$(git -C "$DIR" describe --exact-match --tags HEAD 2> /dev/null || :)
    BRANCH="${TAG:-$(git -C "$DIR" rev-parse --short HEAD 2> /dev/null || :)}"
  fi
  BEHIND=0 AHEAD=0 CONFLICTED=0 STAGED=0 UNSTAGED=0 UNTRACKED=0
  if [[ -n $BRANCH ]]; then
    read -r BEHIND AHEAD < <(git -C "$DIR" rev-list --left-right --count '@{u}...HEAD' 2> /dev/null || echo "0 0")
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
  fi
  printf '%s|%s|%s|%s|%s|%s|%s|%s\n' \
    "$BRANCH" "$TAG" "$BEHIND" "$AHEAD" \
    "$CONFLICTED" "$STAGED" "$UNSTAGED" "$UNTRACKED" > "$CACHE_FILE"
fi

IFS='|' read -r BRANCH TAG BEHIND AHEAD CONFLICTED STAGED UNSTAGED UNTRACKED < "$CACHE_FILE"

PARTS=()

if [[ -n $VIM_MODE ]]; then
  MODE_LETTER=${VIM_MODE:0:1}
  MODE_LETTER=${MODE_LETTER,,}
  case $VIM_MODE in
    INSERT)  FG=34; BG=44 ;;
    VISUAL*) FG=32; BG=42 ;;
    *)       FG=37; BG=47 ;;
  esac
  printf -v P '\e[%sm\xee\x82\xb6\e[%s;30;1m%s\e[0;%sm\xee\x82\xb4\e[0m' "$FG" "$BG" "$MODE_LETTER" "$FG"
  PARTS+=("$P")
fi

printf -v P '\e[36m%s\e[0m' "${DIR/#$HOME/\~}"
PARTS+=("$P")

if [[ -n $BRANCH ]]; then
  if [[ -n $TAG ]]; then
    printf -v GIT_STR '\e[35m%s\e[0m' "$BRANCH"
  else
    printf -v GIT_STR '\e[34m%s\e[0m' "$BRANCH"
  fi
  if ((BEHIND > 0)); then printf -v P '\e[33m↓%d\e[0m' "$BEHIND"; GIT_STR+=" $P"; fi
  if ((AHEAD > 0)); then printf -v P '\e[32m↑%d\e[0m' "$AHEAD"; GIT_STR+=" $P"; fi
  if ((CONFLICTED > 0)); then printf -v P '\e[31m?%d\e[0m' "$CONFLICTED"; GIT_STR+=" $P"; fi
  if ((STAGED > 0)); then printf -v P '\e[32m+%d\e[0m' "$STAGED"; GIT_STR+=" $P"; fi
  if ((UNSTAGED > 0)); then printf -v P '\e[33m~%d\e[0m' "$UNSTAGED"; GIT_STR+=" $P"; fi
  if ((UNTRACKED > 0)); then printf -v P '\e[31m*%d\e[0m' "$UNTRACKED"; GIT_STR+=" $P"; fi
  PARTS+=("$GIT_STR")
fi

if [[ -n $USED ]]; then
  printf -v USED_INT '%.0f' "$USED"
  ctx_icon CTX_GLYPH "$USED"
  if [[ -n $CUR_IN && -n $MAX ]]; then
    fmt_tokens CUR_IN_STR "$CUR_IN"
    fmt_tokens MAX_STR "$MAX"
    printf -v P '\e[37m\xee\x82\xb6\e[47;30;1m%s %s%% %s %s\e[0;37m\xee\x82\xb4\e[0m' \
      "$CTX_GLYPH" "$USED_INT" "$CUR_IN_STR" "$MAX_STR"
  else
    printf -v P '\e[37m\xee\x82\xb6\e[47;30;1m%s %s%%\e[0;37m\xee\x82\xb4\e[0m' \
      "$CTX_GLYPH" "$USED_INT"
  fi
  PARTS+=("$P")
fi

if [[ -n $MODEL ]]; then
  MODEL_STR=$MODEL
  if [[ -n $EFFORT ]]; then
    case $EFFORT in
      low)    EFFORT_SHORT=lo ;;
      medium) EFFORT_SHORT=med ;;
      high)   EFFORT_SHORT=hi ;;
      xhigh)  EFFORT_SHORT=xhi ;;
      *)      EFFORT_SHORT=$EFFORT ;;
    esac
    MODEL_STR+=" $EFFORT_SHORT"
  fi
  printf -v P '\e[90m\xee\x82\xb6\e[100;30;1m󰚩 %s\e[0;90m\xee\x82\xb4\e[0m' "$MODEL_STR"
  PARTS+=("$P")
fi

if [[ -n $COST ]]; then
  printf -v P '\e[90m󰇁 %.2f\e[0m' "$COST"
  PARTS+=("$P")
fi

OUTPUT=${PARTS[0]}
for PART in "${PARTS[@]:1}"; do
  OUTPUT+=" $PART"
done

printf '%s' "$OUTPUT"
