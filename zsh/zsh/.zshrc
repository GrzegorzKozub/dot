#!/usr/bin/env zsh

# perf check: hyperfine "TMUX=1 zsh -i -c exit" --warmup 10
# key scan: cat -v or showkey -a

# tmux

if [[ ! $TERM_PROGRAM =~ 'vscode|zed' ]] && [[ ! $TERMINAL_EMULATOR =~ 'JetBrains-JediTerm' ]] && [[ -z $TMUX ]] && [[ -z $ZI_BOOTSTRAP ]] && [[ -t 1 ]]; then
  if tmux has-session -t 0 2> /dev/null; then
    if [[ $(tmux list-clients -f '#{==:#{client_session},0}' 2> /dev/null) ]]; then
      exec tmux new-session
    else
      exec tmux attach-session -t 0
    fi
  else
    exec tmux new-session -s 0
  fi
fi

# zellij

# if [[ ! $TERM_PROGRAM =~ 'vscode|zed' ]] && [[ ! $TERMINAL_EMULATOR =~ 'JetBrains-JediTerm' ]] && [[ -z $TMUX ]] && [[ -z $ZI_BOOTSTRAP ]] && [[ -t 1 ]]; then
#   zellij attach --create
# fi

# debug

export PS4='\e[90m→ \e[0m'
# export PS4='\e[90m→ \e[37m${BASH_SOURCE##*/}:${LINENO} \e[0m'

# powerlevel10k (https://wiki.zshell.dev/community/gallery/collection/themes#thp-romkatv-powerlevel10k)

# if [[ -r "$XDG_CACHE_HOME"/p10k-instant-prompt-${(%):-%n}.zsh ]]; then
#   source "$XDG_CACHE_HOME"/p10k-instant-prompt-${(%):-%n}.zsh
# fi

# zi

typeset -A ZI
: ${ZI[HOME_DIR]:="${XDG_DATA_HOME}/zi"}
: ${ZI[BIN_DIR]:="${ZI[HOME_DIR]}/bin"}

ZI[COMPINIT_OPTS]=-C
ZI[OPTIMIZE_OUT_DISK_ACCESSES]=1
ZI[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/zcompdump

source "${ZI[BIN_DIR]}"/zi.zsh

autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

# functions

my-bindkey() {
  for keymap in vicmd viins; do bindkey -M $keymap $1 $2; done
}

my-redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do $precmd; done
  zle reset-prompt
  zle zle-keymap-select
}
zle -N my-redraw-prompt

palette() {
  for color in {0..15}; do
    print -Pn "%K{$color}  %k%F{$color}${(l:2::0:)color}%f "
  done
  echo # remove trailing %
}

fonts() {
  printf '%b' 'normal \e[1mbold\e[0m \e[2mdim\e[0m \e[3mitalic\e[0m \e[3;1mbold-italic\e[0m
\e[4:1mstraight\e[0m \e[4:2mdouble\e[0m \e[4:3mcurly\e[0m \e[4:4mdotted\e[0m \e[4:5mdashed\e[0m
\e[5mblink\e[0m \e[7mreverse\e[0m \e[9mstrikethrough\e[0m
\e]8;;http://archlinux.org\e\\link\e]8;;\e\\
== != === !== >= <= => ->
              
🙁 😐 🙂 👍 👎
'
}

procs() {
  local sort=%cpu
  for arg in $@; do
    [[ $arg == '--cpu' ]] && local sort=%cpu && continue
    [[ $arg == '--mem' ]] && local sort=rss && continue
    local filter=$arg
  done
  local cores=$(nproc)
  local ps=$(ps -eo pid=pid,user:4=usr,%cpu=cpu,rss=mem,cmd=cmd --sort=-$sort --no-headers)
  [[ $filter ]] && local ps=$(echo $ps | grep $filter)
  echo $ps |
    numfmt --field=4 --from-unit=1000 --to=iec --padding=4 |
    awk -v cores=$cores --use-lc-numeric 'BEGIN { OFS = "" } {
      $3 = $3 / cores;
      printf "%6i %4s %5.2f %4s", $1, $2, $3, $4;
      $1 = $2 = $3 = $4 = "";
      printf " %s\n", $0;
    }' |
    less --chop-long-lines
}

timestamp() { date --date @$(($1/1000)) --iso-8601=seconds }

# vi mode

bindkey -v # enable vi mode

my-bindkey '^[[1;5D' backward-word # ctrl+left
my-bindkey '^[[1;5C' forward-word # ctrl+right

my-bindkey '^[[1~' beginning-of-line # home
my-bindkey '^[[4~' end-of-line # end

# my-bindkey '^P' up-history # ctrl+p
# my-bindkey '^N' down-history # ctrl+n

my-bindkey '^[[A' up-line-or-history # up
my-bindkey '^[[B' down-line-or-history # down

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

my-bindkey '^[[1;5A' up-line-or-beginning-search # ctrl+up
my-bindkey '^[[1;5B' down-line-or-beginning-search # ctrl+down

my-bindkey '^[[3~' delete-char # delete
bindkey -M viins '^?' backward-delete-char # backspace

autoload -U select-bracketed select-quoted surround
zle -N select-bracketed
zle -N select-quoted
zle -N add-surround surround
zle -N delete-surround surround
zle -N change-surround surround

for keymap in viopp visual; do
  for sequence in {a,i}${(s..)^:-'()[]{}<>bB'}; do bindkey -M $keymap $sequence select-bracketed; done
  for sequence in {a,i}{\',\",\`}; do bindkey -M $keymap $sequence select-quoted; done
done

bindkey -M visual 'S' add-surround
bindkey -M vicmd 'cs' change-surround
bindkey -M vicmd 'ds' delete-surround

autoload -Uz edit-command-line
zle -N edit-command-line
my-bindkey '^E' edit-command-line # ctrl+e

# vi mode cursor

function my-cursor() {
  case ${1:-'main'} in vicmd|viopp|visual) local shape=2;; main|viins|*) local shape=6;; esac
  printf $'\e[%d q' $shape
}

function zle-keymap-select() { my-cursor $KEYMAP }
zle -N zle-keymap-select

function zle-line-init() { my-cursor main }
zle -N zle-line-init

function my-visual-mode { my-cursor visual && zle .visual-mode }
zle -N visual-mode my-visual-mode

# changing directories

setopt AUTO_PUSHD # pushd on every cd
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS # cd - goes to the previous dir

# expansion and globbing

setopt EXTENDED_GLOB

# input/output

setopt CORRECT # correct command spelling
setopt CORRECT_ALL # correct all arguments spelling
setopt INTERACTIVE_COMMENTS
setopt PATH_DIRS # search for paths on commands with slashes
setopt SHORT_LOOPS

# zsh line editor (zle)

WORDCHARS='' # non-alphanumeric chars not considered part of a word

zle_bracketed_paste=() # don't select pasted text
zle_highlight=(paste:none) # don't highlight pasted text

setopt NO_BEEP

# disable flow control

# [[ -o login ]] && stty -ixon
setopt NO_FLOW_CONTROL

# prompt

setopt PROMPT_SUBST

autoload -Uz promptinit && promptinit

# paths

typeset -U path

path=(${path:#$XDG_DATA_HOME/mise/shims})

path=(
  ${commands[lmstudio]:+$XDG_DATA_HOME/lmstudio/bin}
  ${commands[dotnet]:+$XDG_CACHE_HOME/dotnet/.dotnet/tools}
  $XDG_DATA_HOME/cargo/bin
  ~/.local/bin
  ~/code/arch
  $path[@]
)

  # $XDG_DATA_HOME/bun/bin
  # $XDG_DATA_HOME/gem/ruby/3.0.0/bin
  # $XDG_DATA_HOME/go/bin
  # $XDG_DATA_HOME/npm/bin

# completion

typeset -U fpath

fpath=(
  ~/code/arch
  $fpath[@]
)

setopt ALWAYS_TO_END # put cursor at the end of the completed word
setopt COMPLETE_ALIASES # don't substitute aliases
setopt COMPLETE_IN_WORD # don't move cursor to the word end on completion
setopt GLOB_DOTS # don't require . to complete the hidden files/dirs
setopt LIST_PACKED # smaller completion list
setopt MENU_COMPLETE # tab through matches on ambiguous completion
setopt NO_LIST_TYPES # don't show file/dir types as trailing marks

# zmodload -i zsh/complist
# autoload -Uz compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump
# autoload -Uz bashcompinit && bashcompinit # for aws

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache

zstyle ':completion:*' completer _complete _match _approximate

zstyle ':completion:*' menu select

zstyle ':completion:*' list-separator ' '

# use dircolors for files & dirs based on https://github.com/marlonrichert/zcolors
zstyle ':completion:*' group-name '' # allow excluding groups in list-colors
zstyle ':completion:*' file-patterns \
  '%p(^-/):globbed-files *(-/):directories:my-dirs' # show files first
zstyle ':completion:*:default' list-colors \
  '(^(*argument*|*directories|*files))=(#b)(*[^ ]~*  *|)[ ]#(*)=38;5;8=37=38;5;8' \
  'ma=0' \
  ${(s.:.)LS_COLORS}

zstyle ':completion:*:default' select-prompt '%F{8}%m%f'

zstyle ':completion:*:messages' format '%F{white}%d%f'
zstyle ':completion:*:warnings' format '%F{yellow}no matches found%f'

# in a single matcher, try simple completion,
# then match upper-case when typing lower-case,
# then match partial words
zstyle ':completion:*' matcher-list \
  '' '+m:{[:lower:]}={[:upper:]}' '+l:|=* r:|=*'

# expand // to /
zstyle ':completion:*' squeeze-slashes true

# complete not only dirs but also options on -
zstyle ':completion:*' complete-options true

# insert manual scetions
# zstyle ':completion:*:manuals.*' insert-sections true
# zstyle ':completion:*:manuals.*' separate-sections true
zstyle ':completion:*' insert-sections true
zstyle ':completion:*' separate-sections true

zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/complist
zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/completion # after complist

# before zicompinit_fast
zi as'completion' lucid wait'0' for \
  OMZ::plugins/docker-compose/_docker-compose \
  OMZ::plugins/pip/_pip

# https://wiki.zshell.dev/docs/guides/commands#calling-compinit-with-turbo-mode
zi ice atload'zicompinit_fast' lucid nocompletions wait'0'
zi light "$ZDOTDIR"/compinit

# fzf-tab

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# https://github.com/z-shell/zi/issues/471
# https://github.com/z-shell/zi/issues/488
zi ice depth'1' lucid nocompletions wait'0' && zi light Aloxaf/fzf-tab

# history

HISTFILE=~/code/hist/$HOST/history

HISTSIZE=100000 # history memory limit
SAVEHIST=100000 # history file limit

HISTORY_IGNORE='(#i)(*bearer*|*jwt*|*password*|*secret*|*token*)'

setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE # don't add commands prefixed with space
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY # don't run command immediately
setopt INC_APPEND_HISTORY # immediately append instead of rewriting the history file

# aliases

alias df='df -h | grep -v tmpfs | grep -v efivars'
alias diff='diff --color'
alias du='du --exclude=lost+found -hd1 | sort -hr'
alias grep='grep --color=auto --exclude-dir={.git}'
alias la='ls -lAh'
alias ls='ls --color=auto'

# fzf

zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/fzf

export FZF_DEFAULT_OPTS="
  --bind=ctrl-d:page-down,ctrl-u:page-up
  --bind=ctrl-r:toggle-raw,ctrl-w:toggle-wrap
  --bind 'ctrl-y:execute-silent(echo -n {} | wl-copy)+abort'
  --bind=shift-down:preview-page-down,shift-up:preview-page-up
  --bind=alt-shift-down:preview-down,alt-shift-up:preview-up
  --border none
  --color dark
  --color fg:white,selected-fg:white,preview-fg:-1
  --color hl:yellow,selected-hl:yellow
  --color current-fg:-1,current-bg:-1,gutter:-1,current-hl:yellow
  --color info:bright-black
  --color border:bright-black,label:bright-black
  --color prompt:magenta,pointer:magenta,marker:magenta
  --color spinner:bright-black,header:bright-black
  --color nomatch:bright-black
  --ellipsis '…'
  --gutter ' ' --gutter-raw ' '
  --height 50%
  --info inline-right:''
  --layout reverse
  --margin 0
  --marker '▏'
  --marker-multi-line '▏▏▏'
  --no-bold
  --no-scrollbar
  --no-separator
  --padding 0
  --pointer '▎'
  --prompt ' '
  --scroll-off 4
  --tabstop 2
"

fzf-history-widget-no-numbers() {
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  local opts="$FZF_DEFAULT_OPTS $FZF_CTRL_R_OPTS --scheme=history --query=${(qqq)LBUFFER}"
  local selected=( $( fc -rln 1 | FZF_DEFAULT_OPTS=$opts $(__fzfcmd) ) )
  local ret=$?
  BUFFER=$selected
  zle vi-end-of-line
  zle reset-prompt
  return $ret
}

# oh my zsh

export ZSH_CACHE_DIR=$XDG_CACHE_HOME/zsh

# last working dir (must be synchronous)

zi ice lucid nocompletions
zi snippet OMZ::plugins/last-working-dir/last-working-dir.plugin.zsh

# dir history

zi ice lucid nocompletions wait'0'
zi snippet OMZ::plugins/dirhistory/dirhistory.plugin.zsh

zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/dirhistory

# yazi

export YAZI_ZOXIDE_OPTS="
  $FZF_DEFAULT_OPTS
  --height 100%
  --preview-window='down:33%'
  --bind 'alt-p:change-preview-window(right:50%|hidden|)'
"

my-cd() {
  local temp_file=$1
  if [[ -f "$temp_file" ]]; then
    local target_dir="$(cat "$temp_file")"
    rm -f "$temp_file"
    [[ -d "$target_dir" && "$target_dir" != "$(pwd)" ]] && cd "$target_dir"
  fi
  zle my-redraw-prompt
}

my-yazi-cd() {
  local temp_file="$(mktemp)"
  yazi "$@" --cwd-file="$temp_file" < $TTY
  my-cd $temp_file
}
zle -N my-yazi-cd
my-bindkey '\el' my-yazi-cd
my-bindkey '^y' my-yazi-cd

# fetch

my-fetch-cd() { my-cd /tmp/fetch-dir }
zle -N my-fetch-cd
my-bindkey '^f' my-fetch-cd

# dir colors

zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/dircolors

# feature-ritch syntax highlighting (https://wiki.zshell.dev/ecosystem/plugins/f-sy-h)

zi ice atload'fsh_theme CONFIG:gruvbox-material-dark --quiet' depth'1' lucid wait'0'
zi light z-shell/F-Sy-H

# autosuggestions

export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=32
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

typeset -U ZSH_AUTOSUGGEST_STRATEGY && ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# atload'_zsh_autosuggest_start' ice makes autosuggetsions work for the first command in a new shell
zi ice atload'_zsh_autosuggest_start' depth'1' lucid nocompletions wait'0'
zi light zsh-users/zsh-autosuggestions

# mise (before mise managed tools commands checks)

zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/mise

# ansible

if (( $+commands[ansible] )); then

  export ANSIBLE_HOME=$XDG_CONFIG_HOME/ansible
  export ANSIBLE_CONFIG=$XDG_CONFIG_HOME/ansible/ansible.cfg

  export ANSIBLE_GALAXY_CACHE_DIR=$XDG_CACHE_HOME/ansible/galaxy_cache
  export ANSIBLE_LOCAL_TEMP=$XDG_CACHE_HOME/ansible/tmp

fi

# aws

if (( $+commands[aws] )); then

  # export AWS_CONFIG_FILE=$XDG_CONFIG_HOME/aws/config
  # export AWS_SHARED_CREDENTIALS_FILE=$XDG_CONFIG_HOME/aws/credentials

  export AWS_SDK_LOAD_CONFIG=1

  export SAM_CLI_TELEMETRY=0

  zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/aws

fi

alias myip='curl http://checkip.amazonaws.com/'

# bat

# export MANPAGER="bat -plman"
# alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# bun (mise managed)

export DO_NOT_TRACK=1

export BUN_INSTALL_BIN=$XDG_DATA_HOME/bun/bin
export BUN_INSTALL_GLOBAL_DIR=$XDG_DATA_HOME/bun/install/global

export BUN_INSTALL_CACHE_DIR=$XDG_CACHE_HOME/bun/install/cache

# claude (mise managed)

zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/claude

# copilot

export COPILOT_HOME=$XDG_CONFIG_HOME/copilot

# alias copilot="copilot \
#   --deny-tool 'read(.env)' \
#   --deny-tool 'read(.secret)' \
#   --deny-tool 'read(.secrets)' \
#   --deny-tool 'read(.zshenv)' \
#   --deny-tool 'read(~/.ssh)' \
#   --deny-tool 'read(~/code/keys)' \
#   --deny-tool 'read(credentials)' \
#   --deny-tool 'read(settings.xml)'"

# docker

export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock # rootless

export COMPOSE_BAKE=true

# dotnet

if (( $+commands[dotnet] )); then

  export DOTNET_CLI_HOME=$XDG_CACHE_HOME/dotnet # https://github.com/dotnet/runtime/issues/98276
  export DOTNET_CLI_TELEMETRY_OPTOUT=1
  export DOTNET_GENERATE_ASPNET_CERTIFICATE=0
  export DOTNET_NOLOGO=1
  export DOTNET_SKIP_WORKLOAD_INTEGRITY_CHECK=1

  export OMNISHARPHOME=$XDG_DATA_HOME/omnisharp

  zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/dotnet

fi

# elixir

# export ERL_AFLAGS='-kernel shell_history enabled'
#
# export HEX_HOME=$XDG_CACHE_HOME/hex
# export MIX_HOME=$XDG_DATA_HOME/mix
#
# alias iex="iex --dot-iex $XDG_CONFIG_HOME/iex/iex.exs"

# eza

typeset -a eza_colors=(
  # permissions
  oc=37
  ur=37 uw=37 ux=37 ue=37
  gr=37 gw=37 gx=37
  tr=37 tw=37 tx=37
  su=37 sf=37 xa=37
  nb=90 nk=37 nm=33 ng=31 nt=91 # size
  uu=90 uR=31 un=37 gu=90 gR=31 gn=37 # owner & group
  # git
  ga=32 gm=33 gd=31 gv=33 gt=33 gi=90 gc=91
  Gm=34 Go=34 Gc=30 Gd=33
  da=37 # dates
  bO=31 # symlinks
  'mp=34;4' # mount points
  im=35 vi=35 mu=35 lo=35 # media
  cr=33 # cryptography
  do=0 # documents
  co=33 # compressed
  tm=90 # temp
  bu=0 sc=0 # dev
  ff=37 # flags
)
export EZA_COLORS=${(j.:.)eza_colors}
unset eza_colors

export EZA_ICONS_AUTO=1

alias ls='eza --all --group-directories-first'
alias la='eza --all --group-directories-first --long'

# fd

alias fd='fd --exclude .git --hidden'

# forgit

export FORGIT_COPY_CMD='wl-copy'
export FORGIT_GLO_FORMAT='%C(yellow)%h %C(auto)%s %C(cyan)%an %C(brightblack)%ar %C(auto)%D%C(reset)'

export FORGIT_FZF_DEFAULT_OPTS="
  --height 100%
  --preview-window='right:50%'
  --bind 'ctrl-r:toggle-raw,alt-p:change-preview-window(down|hidden|)'
"

zi ice depth'1' lucid nocompletions wait'0' && zi light wfxr/forgit

# git

my-git-checkout-branch() {
  BUFFER='git checkout -b '
  zle vi-end-of-line && zle vi-insert
}
zle -N my-git-checkout-branch
my-bindkey '^gb' my-git-checkout-branch

my-git-commit() {
  BUFFER="git commit -m ''"
  zle vi-end-of-line && zle vi-backward-char && zle vi-insert
}
zle -N my-git-commit
my-bindkey '^gc' my-git-commit

# gnupg

export GNUPGHOME=$XDG_DATA_HOME/gnupg

# go (mise managed)

export GOCACHE=$XDG_CACHE_HOME/go
export GOPATH=$XDG_DATA_HOME/go

export GOPRIVATE=github.com/efficy-sa/*

# gopass

alias pass='gopass'

# intellij

(( $+commands[intellij-idea-community-edition] )) &&
  idea() {
    nohup intellij-idea-community-edition "$@" >/dev/null 2>&1 &
    disown
  }

# java

if (( $+commands[java] )); then
  # export JAVA_TOOL_OPTIONS="-Djava.util.prefs.userRoot=$XDG_DATA_HOME/java -Djavafx.cachedir=$XDG_CACHE_HOME/openjfx"
  export GRADLE_USER_HOME=$XDG_DATA_HOME/gradle
fi

if (( $+commands[maven] )); then
  export MAVEN_ARGS="--settings $XDG_CONFIG_HOME/maven/settings.xml"
  export MAVEN_OPTS="-Dmaven.repo.local=$XDG_CACHE_HOME/maven/repository"
fi

# less

typeset -a less=(
  --quit-if-one-screen --RAW-CONTROL-CHARS --tilde --use-color
  -DEr -DTk -DPw -DSkY -Dd-d -Du-d
  # flagged colors
  -D1rR -D2rR -D3rR -D4rR -D5rR -DBrR -DCrR -DHrR -DJrR -DMrR -DNrR -DRrR -DWrR -DkrR -DsrR
)
export LESS=${(j. .)less}
unset less

export LESSHISTFILE=-

# alias less="less --quit-if-one-screen --RAW-CONTROL-CHARS --tilde --use-color -DEr -DTk -DPw -DSkY -Dd-d -Du-d \
#   -D1rR -D2rR -D3rR -D4rR -D5rR -DBrR -DCrR -DHrR -DJrR -DMrR -DNrR -DRrR -DWrR -DkrR -DsrR"
alias -g -- --help='--help 2>&1 | less'

# man() {
#   GROFF_NO_SGR=1 \
#     MANPAGER="less +Gg --RAW-CONTROL-CHARS --squeeze-blank-lines --tilde --use-color -DEr -DTk -DPw -DSkY -Dd-d -Du-d \
#       -D1rR -D2rR -D3rR -D4rR -D5rR -DBrR -DCrR -DHrR -DJrR -DMrR -DNrR -DRrR -DWrR -DkrR -DsrR" \
#     command man "$@"
# }
man() { GROFF_NO_SGR=1 MANPAGER='less +Gg' command man "$@" }

# linecast

if (( $+commands[linecast] )); then
  zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/linecast
fi

# mcp-remote

export MCP_REMOTE_CONFIG_DIR=$XDG_CONFIG_HOME/mcp-remote

# mpv

alias music="mpv --no-resume-playback --shuffle /run/media/$USER/data/music"

# neovim

export EDITOR='nvim'
export DIFFPROG='nvim -d'
export VISUAL='nvim'

alias v='nvim'
alias vim='nvim'

# node (mise managed)

export NODE_NO_WARNINGS=1
export NODE_REPL_HISTORY=''

export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc

# pass

export PASSWORD_STORE_DIR=$XDG_DATA_HOME/pass

# pkgfile

zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/command-not-found

# python

export PYLINTHOME=$XDG_CACHE_HOME/pylint
export RUFF_CACHE_DIR=$XDG_CACHE_HOME/ruff

# ripgrep

export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep/ripgreprc

# rust

export CARGO_HOME=$XDG_DATA_HOME/cargo
export RUSTUP_HOME=$XDG_DATA_HOME/rustup

if (( $+commands[rustup] )); then
  zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/rustup
fi

if (( $+commands[cargo] )); then
  zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/cargo
fi

# tex

(( $+commands[tex] )) &&
  export TEXMFVAR=$XDG_CACHE_HOME/texlive/texmf-var

# tiddl

export TIDDL_PATH=$XDG_CONFIG_HOME/tiddl

# vscode

export VSCODE_CLI_DATA_DIR=$XDG_CONFIG_HOME/vscode/cli
export VSCODE_PORTABLE=$XDG_CONFIG_HOME/vscode

alias c='code .'

# wget

export WGETRC=$XDG_CONFIG_HOME/wgetrc

# alias wget="wget --hsts-file=$XDG_STATE_HOME/wget-hsts"

# worktrunk

if (( $+commands[wt] )); then
  zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/wt
fi

# zed

alias z='zeditor .'
alias zed='zeditor .'

export LLAMA_API_KEY='foo' # https://zed.dev/docs/ai/llm-providers#openai-api-compatible

# zoxide

export _ZO_DATA_DIR=~/code/hist/$HOST
export _ZO_FZF_OPTS=$FZF_DEFAULT_OPTS

zi ice lucid nocompletions wait'0' && zi light "$ZDOTDIR"/zoxide

# powerlevel10k (https://wiki.zshell.dev/community/gallery/collection/themes#thp-romkatv-powerlevel10k)

zi ice atload'source $XDG_CONFIG_HOME/zsh/.p10k.zsh' depth'1' lucid nocd nocompletions
zi light romkatv/powerlevel10k

# completion (continued)

# https://wiki.zshell.dev/docs/guides/commands#calling-compinit-with-turbo-mode
zi ice atload'zicdreplay' lucid nocompletions wait'0' && zi light "$ZDOTDIR"/zicdreplay

# install.sh

if [[ -n $ZI_BOOTSTRAP ]]; then
  zi ice lucid nocompletions wait'2' && zi light "$ZDOTDIR"/exit
fi
