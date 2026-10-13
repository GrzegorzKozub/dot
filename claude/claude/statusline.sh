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
      .effort.level // "",
      .vim.mode // "",
      .session_id // "default",
      .agent.name // "",
      .workspace.git_worktree // "",
      (.rate_limits.five_hour.used_percentage // ""),
      (.rate_limits.seven_day.used_percentage // ""),
      (.rate_limits.five_hour.resets_at // ""),
      (.rate_limits.seven_day.resets_at // "")
    )')
DIR=${FIELDS[0]}
MODEL=${FIELDS[1]}
USED=${FIELDS[2]}
MAX=${FIELDS[3]}
CUR_IN=${FIELDS[4]}
EFFORT=${FIELDS[5]}
VIM_MODE=${FIELDS[6]}
SESSION_ID=${FIELDS[7]}
AGENT=${FIELDS[8]}
WORKTREE=${FIELDS[9]}
# shellcheck disable=SC2034 # read via indirect expansion in the limits loop
LIMIT_5H=${FIELDS[10]}
# shellcheck disable=SC2034
LIMIT_7D=${FIELDS[11]}
# shellcheck disable=SC2034
RESET_5H=${FIELDS[12]}
# shellcheck disable=SC2034
RESET_7D=${FIELDS[13]}

CACHE_FILE="${TMPDIR:-/tmp}/statusline-git-cache-$SESSION_ID"
CACHE_MAX_AGE=5
COMPACT_HINT_TOKENS=${STATUSLINE_COMPACT_HINT_TOKENS:-250000}
[[ $COMPACT_HINT_TOKENS =~ ^[0-9]+$ ]] || COMPACT_HINT_TOKENS=250000

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

fmt_remaining() {
  # shellcheck disable=SC2034
  local -n OUT=$1
  local at=$2 secs d h m
  [[ $at =~ ^[0-9]+$ ]] || at=$(date -d "$at" +%s 2> /dev/null) || { OUT=""; return; }
  secs=$((at - EPOCHSECONDS))
  ((secs < 0)) && secs=0
  d=$((secs / 86400))
  h=$((secs % 86400 / 3600))
  m=$((secs % 3600 / 60))
  if ((d > 0)); then
    printf -v OUT '%dd %dh' "$d" "$h"
  elif ((h > 0)); then
    printf -v OUT '%dh %dm' "$h" "$m"
  else
    printf -v OUT '%dm' "$m"
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
  TAG=$(git -C "$DIR" describe --exact-match --tags HEAD 2> /dev/null || :)
  if [[ -z $BRANCH ]]; then
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

((${#WORKTREE} > 16)) && WORKTREE="${WORKTREE:0:15}…"
((${#BRANCH} > 16)) && BRANCH="${BRANCH:0:15}…"
((${#TAG} > 16)) && TAG="${TAG:0:15}…"

PARTS=()

if [[ -n $VIM_MODE ]]; then
  MODE_LETTER=${VIM_MODE:0:1}
  MODE_LETTER=${MODE_LETTER,,}
  case $VIM_MODE in
    INSERT)  FG=34; BG=44 ;;
    VISUAL*) FG=32; BG=42 ;;
    *)       FG=37; BG=47 ;;
  esac
  printf -v P '\e[%sm\xee\x82\xb6\e[%s;30m%s\e[0;%sm\xee\x82\xb4\e[0m' "$FG" "$BG" "$MODE_LETTER" "$FG"
  PARTS+=("$P")
fi

CWD="${DIR/#$HOME/\~}"
((${#CWD} > 32)) && CWD="${CWD##*/}"
printf -v P '\e[36m%s\e[0m' "$CWD"
PARTS+=("$P")

if [[ -n $WORKTREE ]]; then
  printf -v P '\e[94m%s\e[0m' "$WORKTREE"
  PARTS+=("$P")
fi

if [[ -n $BRANCH ]]; then
  GIT_STR=""
  # the worktree segment already shows the branch when the names match
  if [[ -n $WORKTREE && $BRANCH == "$WORKTREE" ]]; then
    [[ -n $TAG && $BRANCH != "$TAG" ]] && printf -v GIT_STR '\e[35m%s\e[0m' "$TAG"
  elif [[ -n $TAG && $BRANCH == "$TAG" ]]; then
    printf -v GIT_STR '\e[35m%s\e[0m' "$BRANCH"
  elif [[ -n $TAG ]]; then
    printf -v GIT_STR '\e[34m%s\e[0m \e[35m%s\e[0m' "$BRANCH" "$TAG"
  else
    printf -v GIT_STR '\e[34m%s\e[0m' "$BRANCH"
  fi
  if ((BEHIND > 0)); then printf -v P '\e[33m↓%d\e[0m' "$BEHIND"; GIT_STR+="${GIT_STR:+ }$P"; fi
  if ((AHEAD > 0)); then printf -v P '\e[32m↑%d\e[0m' "$AHEAD"; GIT_STR+="${GIT_STR:+ }$P"; fi
  if ((CONFLICTED > 0)); then printf -v P '\e[31m?%d\e[0m' "$CONFLICTED"; GIT_STR+="${GIT_STR:+ }$P"; fi
  if ((STAGED > 0)); then printf -v P '\e[32m+%d\e[0m' "$STAGED"; GIT_STR+="${GIT_STR:+ }$P"; fi
  if ((UNSTAGED > 0)); then printf -v P '\e[33m~%d\e[0m' "$UNSTAGED"; GIT_STR+="${GIT_STR:+ }$P"; fi
  if ((UNTRACKED > 0)); then printf -v P '\e[31m*%d\e[0m' "$UNTRACKED"; GIT_STR+="${GIT_STR:+ }$P"; fi
  [[ -n $GIT_STR ]] && PARTS+=("$GIT_STR")
fi

if [[ -n $MODEL ]]; then
  # background by cost tier: haiku < sonnet < opus < fable
  case $MODEL in
    *haiku*)  MODEL_FG=32; MODEL_BG=42 ;;
    *opus*)   MODEL_FG=33; MODEL_BG=43 ;;
    *fable*)  MODEL_FG=31; MODEL_BG=41 ;;
    *)        MODEL_FG=37; MODEL_BG=47 ;;
  esac
  printf -v P '\e[%sm\xee\x82\xb6\e[%s;30m󰚩 %s\e[0;%sm\xee\x82\xb4\e[0m' \
    "$MODEL_FG" "$MODEL_BG" "$MODEL" "$MODEL_FG"
  PARTS+=("$P")
fi

if [[ -n $EFFORT ]]; then
  # background by token-use tier: low < medium < high < xhigh < max
  case $EFFORT in
    low)    EFFORT_STR=lo;  EFFORT_FG=32; EFFORT_BG=42 ;;
    medium) EFFORT_STR=med; EFFORT_FG=37; EFFORT_BG=47 ;;
    high)   EFFORT_STR=hi;  EFFORT_FG=33; EFFORT_BG=43 ;;
    xhigh)  EFFORT_STR=xhi; EFFORT_FG=31; EFFORT_BG=41 ;;
    max)    EFFORT_STR=max; EFFORT_FG=91; EFFORT_BG=101 ;;
    *)      EFFORT_STR=$EFFORT; EFFORT_FG=37; EFFORT_BG=47 ;;
  esac
  printf -v P '\e[%sm\xee\x82\xb6\e[%s;30m󰈸 %s\e[0;%sm\xee\x82\xb4\e[0m' \
    "$EFFORT_FG" "$EFFORT_BG" "$EFFORT_STR" "$EFFORT_FG"
  PARTS+=("$P")
fi

if [[ -n $USED ]]; then
  printf -v USED_INT '%.0f' "$USED"
  ctx_icon CTX_GLYPH "$USED"
  if ((USED_INT >= 90)); then
    CTX_FG=31; CTX_BG=41
  elif ((USED_INT >= 80)); then
    CTX_FG=33; CTX_BG=43
  else
    CTX_FG=90; CTX_BG=100
  fi
  if [[ -n $CUR_IN && -n $MAX ]]; then
    fmt_tokens CUR_IN_STR "$CUR_IN"
    fmt_tokens MAX_STR "$MAX"
    printf -v P '\e[%sm\xee\x82\xb6\e[%s;30m%s %s%% %s %s\e[0;%sm\xee\x82\xb4\e[0m' \
      "$CTX_FG" "$CTX_BG" "$CTX_GLYPH" "$USED_INT" "$CUR_IN_STR" "$MAX_STR" "$CTX_FG"
  else
    printf -v P '\e[%sm\xee\x82\xb6\e[%s;30m%s %s%%\e[0;%sm\xee\x82\xb4\e[0m' \
      "$CTX_FG" "$CTX_BG" "$CTX_GLYPH" "$USED_INT" "$CTX_FG"
  fi
  PARTS+=("$P")
  if [[ -n $CUR_IN ]] && ((CUR_IN > COMPACT_HINT_TOKENS)); then
    printf -v P '\e[35m\xee\x82\xb6\e[45;30m󰡍\e[0;35m\xee\x82\xb4\e[0m'
    PARTS+=("$P")
  fi
fi

if [[ -n $AGENT ]]; then
  printf -v P '\e[35m󰊠 %s\e[0m' "$AGENT"
  PARTS+=("$P")
fi

# Usage limits (/usage): 5-hour and 7-day windows
LIMITS=()
for W in '\U000F051B:LIMIT_5H:RESET_5H' '\U000F0679:LIMIT_7D:RESET_7D'; do
  IFS=: read -r ICON VAR RESET_VAR <<< "$W"
  PCT=${!VAR}
  [[ -z $PCT ]] && continue
  printf -v PCT '%.0f' "$PCT"
  if ((PCT >= 90)); then C=31; elif ((PCT >= 80)); then C=33; else C=90; fi
  printf -v P "\\e[%sm${ICON} %s%%" "$C" "$PCT"
  if ((PCT >= 80)) && [[ -n ${!RESET_VAR} ]]; then
    fmt_remaining LEFT "${!RESET_VAR}"
    [[ -n $LEFT ]] && P+=" $LEFT"
  fi
  P+=$'\e[0m'
  LIMITS+=("$P")
done
if ((${#LIMITS[@]})); then
  printf -v P '%s ' "${LIMITS[@]}"
  PARTS+=("${P% }")
fi

OUTPUT=${PARTS[0]}
for PART in "${PARTS[@]:1}"; do
  OUTPUT+=" $PART"
done

printf '%s' "$OUTPUT"
