# perf check: hyperfine 'zsh -i -c exit' --warmup 10
# key scan: cat -v or showkey -a

# env

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-~/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-~/.local/share}

# dirs

[[ -d $XDG_CACHE_HOME/zsh ]] || mkdir -p $XDG_CACHE_HOME/zsh
# [[ -d $XDG_DATA_HOME/zsh ]] || mkdir -p $XDG_DATA_HOME/zsh

# plugin support

declare -A ZINIT
export ZINIT[HOME_DIR]=$XDG_DATA_HOME/zinit
export ZINIT[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/zcompdump

source $ZINIT[HOME_DIR]/bin/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# delay support

zinit ice depth=1 && zinit light romkatv/zsh-defer

# functions

my-bindkey() {
  for keymap in vicmd viins; do bindkey -M $keymap $1 $2; done
}

my-redraw-prompt() {
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

# vi mode

bindkey -v # enable vi mode

my-bindkey '^[[1;5D' backward-word # ctrl+left
my-bindkey '^[[1;5C' forward-word # ctrl+right

my-bindkey '^[[1~' beginning-of-line # home
my-bindkey '^[[4~' end-of-line # end

my-bindkey '^P' up-history # ctrl+p
my-bindkey '^N' down-history # ctrl+n

my-bindkey '^[[3~' delete-char # delete
bindkey -M viins '^?' backward-delete-char # backspace

# complete from history
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M viins '^[[A' up-line-or-beginning-search # up
bindkey -M viins '^[[B' down-line-or-beginning-search # down

# handle muti-line commands
bindkey -M vicmd '^[[A' up-line-or-history # up
bindkey -M vicmd '^[[B' down-line-or-history # down

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
bindkey -M vicmd 'vv' edit-command-line

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

setopt NO_BEEP

[[ -o login ]] && stty -ixon # disable flow control (^s and ^c)

# prompt

setopt PROMPT_SUBST

autoload -Uz promptinit && promptinit

zinit ice lucid depth=1 && zinit light romkatv/powerlevel10k

# paths

typeset -U path

path=(
  ~/.local/bin
  $XDG_CACHE_HOME/dotnet/.dotnet/tools
  $XDG_DATA_HOME/cargo/bin
  $XDG_DATA_HOME/go/bin
  ~/code/arch
  $path[@]
)

  # ~/.local/share/gem/ruby/3.0.0/bin
  # ~/.local/share/npm/bin

# completion

typeset -U fpath

fpath=(
  ~/code/arch
  $fpath[@]
)

# my-completions() {
#   local dir=$XDG_CACHE_HOME/zsh/completions
#   [[ ! -d $dir ]] && mkdir $dir
#   fpath=($dir $fpath[@])
# }
# zsh-defer my-completions

setopt ALWAYS_TO_END # put cursor at the end of the completed word
setopt COMPLETE_ALIASES # don't substitute aliases
setopt COMPLETE_IN_WORD # don't move cursor to the word end on completion
setopt GLOB_DOTS # don't require . to complete the hidden files/dirs
setopt LIST_PACKED # smaller completion list
setopt MENU_COMPLETE # tab through matches on ambiguous completion
setopt NO_LIST_TYPES # don't show file/dir types as trailing marks

zsh-defer zmodload -i zsh/complist
zsh-defer autoload -Uz compinit && zsh-defer compinit -d $XDG_CACHE_HOME/zsh/zcompdump
zsh-defer autoload -Uz bashcompinit && zsh-defer bashcompinit # required by aws

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

zsh-defer bindkey -M menuselect '^[[Z' reverse-menu-complete # shift+tab

for key in '^[[5~' '^U' # page up, ctrl+u
  do zsh-defer bindkey -M menuselect $key backward-word; done

for key in '^[[6~' '^D' # page down, ctrl+d
  do zsh-defer bindkey -M menuselect $key forward-word; done

zsh-defer bindkey -M menuselect '^F' history-incremental-search-forward # ctrl+f
zsh-defer bindkey -M menuselect '^B' history-incremental-search-backward # ctrl+b

zinit wait lucid as'completion' for \
  OMZ::plugins/docker-compose/_docker-compose \
  OMZ::plugins/pip/_pip

# fzf-tab

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

zsh-defer zinit light Aloxaf/fzf-tab

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
alias du='du -hd1 | sort -hr'
alias grep='grep --color=auto --exclude-dir={.git}'
alias la='ls -lAh'
alias ls='ls --color=auto'

# fzf

zsh-defer source /usr/share/fzf/completion.zsh
zsh-defer source /usr/share/fzf/key-bindings.zsh

export FZF_DEFAULT_OPTS="
  --bind=ctrl-d:page-down,ctrl-u:page-up
  --bind=ctrl-w:toggle-wrap
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
  --ellipsis '…'
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
zsh-defer zle -N fzf-history-widget-no-numbers
zsh-defer my-bindkey '^r' fzf-history-widget-no-numbers

# last working dir

zinit snippet OMZ::plugins/last-working-dir/last-working-dir.plugin.zsh

# dir history

zsh-defer zinit snippet OMZ::plugins/dirhistory/dirhistory.plugin.zsh

zsh-defer bindkey -r '^[^[[B' # esc up
zsh-defer bindkey -r '^[^[[A' # esc down

zsh-defer bindkey -M viins '^O' dirhistory_zle_dirhistory_back # ctrl+o
zsh-defer bindkey -M vicmd '^O' dirhistory_zle_dirhistory_back
zsh-defer bindkey -M vicmd '^I' dirhistory_zle_dirhistory_future # ctrl+i

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

autoload -Uz colors && colors

eval $(dircolors -b $XDG_CONFIG_HOME/zsh/dir_colors)

# syntax highlighting

# using zinit's wait ice instead of zsh-defer causes delays when typing zinit command
zsh-defer zinit ice lucid depth=1 atload"fast-theme XDG:gruvbox-material-dark --quiet"
zsh-defer zinit light zdharma-continuum/fast-syntax-highlighting

# autosuggestions

export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=32
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
typeset -U ZSH_AUTOSUGGEST_STRATEGY && ZSH_AUTOSUGGEST_STRATEGY=(history completion)

zsh-defer zinit ice lucid depth=1
zsh-defer zinit light zsh-users/zsh-autosuggestions

# aws

export AWS_CONFIG_FILE=$XDG_CONFIG_HOME/aws/config
export AWS_SHARED_CREDENTIALS_FILE=$XDG_CONFIG_HOME/aws/credentials
export AWS_PROFILE=apsis-waw-stage
export AWS_SDK_LOAD_CONFIG=1

export SAM_CLI_TELEMETRY=0

zsh-defer complete -C /usr/bin/aws_completer aws

alias myip='curl http://checkip.amazonaws.com/'

# bat

export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat --language=man --style=plain'"

alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# docker

export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock # rootless

export COMPOSE_BAKE=true

# dotnet

export DOTNET_CLI_HOME=$XDG_CACHE_HOME/dotnet # https://github.com/dotnet/runtime/issues/98276
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_GENERATE_ASPNET_CERTIFICATE=0
export DOTNET_NOLOGO=1

export OMNISHARPHOME=$XDG_DATA_HOME/omnisharp

if [[ -a $commands[dotnet] ]]; then
  _my-compdef-dotnet() { _values = "${(ps:\n:)$(dotnet complete "$words")}" }
  zsh-defer compdef _my-compdef-dotnet dotnet
fi

# elixir

# export ERL_AFLAGS='-kernel shell_history enabled'
#
# export HEX_HOME=$XDG_CACHE_HOME/hex
# export MIX_HOME=$XDG_DATA_HOME/mix
#
# alias iex="iex --dot-iex $XDG_CONFIG_HOME/iex/iex.exs"

# eza

export EZA_COLORS="oc=37:ur=37:uw=37:ux=37:ue=37:gr=37:gw=37:gx=37:tr=37:tw=37:tx=37:su=37:sf=37:xa=37:nb=90:nk=37:nm=33:ng=31:nt=91:uu=90:uR=31:un=37:gu=90:gR=31:gn=37:ga=32:gm=33:gd=31:gv=33:gt=33:gi=90:gc=91:Gm=34:Go=34:Gc=30:Gd=33:da=37:bO=31:mp=34;4:cr=33:do=0:tm=90:bu=0:sc=0:ff=37"
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
  --bind 'alt-p:change-preview-window(down|hidden|)'
"

zsh-defer zinit ice lucid depth=1
zsh-defer zinit light wfxr/forgit

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

# go

export GOCACHE=$XDG_CACHE_HOME/go
export GOPATH=$XDG_DATA_HOME/go

export GOPRIVATE=github.com/efficy-sa/*

# gopass

alias pass='gopass'

# less

export LESSHISTFILE=-
# export MANPAGER='less --RAW-CONTROL-CHARS +Gg --squeeze-blank-lines --use-color -DEr -DPw -DSkY -Ddy -Dsm -Dub'

alias less='less --quit-if-one-screen --RAW-CONTROL-CHARS --use-color -DEr -DPw -DSkY -Ddy -Dsm -Dub'

# maven

export MAVEN_ARGS="--settings $XDG_CONFIG_HOME/maven/settings.xml"
export MAVEN_OPTS="-Dmaven.repo.local=$XDG_CACHE_HOME/maven/repository"

# mpv

alias music="mpv --no-resume-playback --shuffle /run/media/$USER/data/music"

# neovim

export EDITOR='nvim'
export DIFFPROG='nvim -d'
export VISUAL='nvim'

alias v='nvim'
alias vim='nvim'

# node

export NODE_NO_WARNINGS=1
export NODE_REPL_HISTORY=''

export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
# export NPM_CONFIG_PREFIX=$XDG_DATA_HOME/npm

# export NVM_DIR=$XDG_DATA_HOME/nvm
# zsh-defer source $NVM_DIR/nvm.sh

# zsh-defer -c 'eval "$(fnm env --use-on-cd)"' # fnm env is slow
# zsh-defer fnm use default --log-level quiet

if [[ -a $commands[fnm] ]]; then
  _my-fnm-init() {
    eval "$(fnm env --use-on-cd)"
    fnm use default --log-level quiet
  }
  zsh-defer _my-fnm-init
  _my-compdef-fnm() { eval "$(fnm completions --shell zsh)" }
  zsh-defer compdef _my-compdef-fnm fnm
fi

# pass

export PASSWORD_STORE_DIR=$XDG_DATA_HOME/pass

# pkgfile

zsh-defer source /usr/share/doc/pkgfile/command-not-found.zsh

# python

export PYLINTHOME=$XDG_CACHE_HOME/pylint

# ripgrep

export RIPGREP_CONFIG_PATH=$XDG_CONFIG_HOME/ripgrep/ripgreprc

# rust

export CARGO_HOME=$XDG_DATA_HOME/cargo
export RUSTUP_HOME=$XDG_DATA_HOME/rustup

# my-completions-rust() {
#   local dir=$XDG_CACHE_HOME/zsh/completions
#   [[ -a $commands[rustup] && ! -f $dir/_rustup ]] && rustup completions zsh > $dir/_rustup
#   [[ -a $commands[cargo] && ! -f $dir/_cargo ]] && rustup completions zsh cargo > $dir/_cargo
# }
# zsh-defer my-completions-rust

if [[ -a $commands[rustup] ]]; then
  _my-compdef-rustup() { eval "$(rustup completions zsh)" }
  zsh-defer compdef _my-compdef-rustup rustup
fi

if [[ -a $commands[cargo] ]]; then
  _my-compdef-cargo() { eval "$(rustup completions zsh cargo)" }
  zsh-defer compdef _my-compdef-cargo cargo
fi

# vscode

alias c='code . 2> /dev/null'
alias code='code 2> /dev/null'

# wget

alias wget="wget --hsts-file=$XDG_CACHE_HOME/wget-hsts"

# zed

alias z='zeditor .'
alias zed='zeditor'

# zoxide

export _ZO_DATA_DIR=~/code/hist/$HOST
export _ZO_FZF_OPTS=$FZF_DEFAULT_OPTS

zsh-defer eval "$(zoxide init --cmd cd zsh)"

# powerlevel10k

[[ -f $XDG_CONFIG_HOME/zsh/.p10k.zsh ]] && source $XDG_CONFIG_HOME/zsh/.p10k.zsh

# env (replaced by .zshenv)

# if [[ -f $XDG_CONFIG_HOME/zsh/.env ]]; then
#   set -o allexport
#   source $XDG_CONFIG_HOME/zsh/.env
#   set +o allexport
# fi

# tmux

if [[ ! $TERM_PROGRAM =~ 'vscode|zed' ]] && [[ -z $TMUX ]]; then
  tmux has-session -t 0 2> /dev/null
  if [[ $? = 0 ]]; then
    if [[ $(tmux list-clients -f '#{==:#{client_session},0}' 2> /dev/null) ]]; then
      tmux new-session
    else
      tmux attach-session -t 0
    fi
  else
    tmux new-session -s 0
  fi
fi

# zellij

# if [[ ! $TERM_PROGRAM =~ 'vscode|zed' ]] && [[ -z $ZELLIJ ]]; then
#   zellij attach --create
# fi

