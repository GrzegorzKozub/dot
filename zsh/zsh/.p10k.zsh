'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases' ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob' ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m 'POWERLEVEL9K_*'
  autoload -Uz is-at-least && is-at-least 5.1 || return

  # options

  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir

  # layout

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs newline prompt_char)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time status) # aws

  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=

  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '

  typeset -g POWERLEVEL9K_BACKGROUND=

  # prompt_char

  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_{VIINS,VICMD,VIVIS,VIOWR}_CONTENT_EXPANSION='●•'

  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true

  # typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_FOREGROUND='blue'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='blue'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='red'

  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_FOREGROUND='white'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_FOREGROUND='green'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_FOREGROUND='yellow'

  # context

  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  typeset -g POWERLEVEL9K_CONTEXT_{ROOT,REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'

  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='magenta'
  typeset -g POWERLEVEL9K_CONTEXT_{ROOT,REMOTE,REMOTE_SUDO}_FOREGROUND='magenta'

  # dir

  local anchor_files=(.git go.mod mix.exs package.json)
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"

  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=

  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=64

  typeset -g POWERLEVEL9K_DIR_FOREGROUND='cyan'
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='cyan'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='cyan'

  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false

  # vcs

  function my_git_format() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_prompt=$P9K_CONTENT
      return
    fi

    local icon_behind='↓'
    local icon_ahead='↑'
    local icon_push_behind='⇣'
    local icon_push_ahead='⇡'

    local icon_stashes='←'

    local icon_conflicted='?'

    local icon_staged='+'
    local icon_unstaged='~'
    local icon_untracked='*'

    local prompt
    local branch_or_tag

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      prompt+='%4F'
      branch_or_tag=${(V)VCS_STATUS_LOCAL_BRANCH}
    elif [[ -n $VCS_STATUS_TAG ]]; then
      prompt+='%5F'
      branch_or_tag=${(V)VCS_STATUS_TAG}
    fi

    (( $#branch_or_tag > 32 )) && branch_or_tag[32,-1]='…'
    prompt+="${branch_or_tag//\%/%%}"

    [[ -z $branch_or_tag ]] && prompt+="%3F${VCS_STATUS_COMMIT[1,7]}"

    (( VCS_STATUS_COMMITS_BEHIND )) && prompt+=" %3F${icon_behind}${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_COMMITS_AHEAD )) && prompt+=" %2F${icon_ahead}${VCS_STATUS_COMMITS_AHEAD}"

    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && prompt+=" %3F${icon_push_behind}${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD )) && prompt+=" %2F${icon_push_ahead}${VCS_STATUS_PUSH_COMMITS_AHEAD}"

    (( VCS_STATUS_STASHES )) && prompt+=" %5F${icon_stashes}${VCS_STATUS_STASHES}"

    (( VCS_STATUS_NUM_CONFLICTED )) && prompt+=" %1F${icon_conflicted}${VCS_STATUS_NUM_CONFLICTED}"

    (( VCS_STATUS_NUM_STAGED )) && prompt+=" %2F${icon_staged}${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED )) && prompt+=" %3F${icon_unstaged}${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED )) && prompt+=" %1F${icon_untracked}${VCS_STATUS_NUM_UNTRACKED}"

    typeset -g my_git_prompt=$prompt
  }

  functions -M my_git_format 2>/dev/null

  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_format(1)))+${my_git_prompt}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_format(0)))+${my_git_prompt}}'

  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
  typeset -g POWERLEVEL9K_VCS_{COMMITS_BEHIND,COMMITS_AHEAD,CONFLICTED,STAGED,UNSTAGED,UNTRACKED}_MAX_NUM=-1

  # command_execution_time

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=5
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='magenta'

  # aws

  # typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws'
  #
  # typeset -g POWERLEVEL9K_AWS_CLASSES=(
  #   '*prod*' PROD
  #   '*beta*' TEST
  #   '*stage*' DEV
  #   '*' DEV
  # )
  #
  # typeset -g POWERLEVEL9K_AWS_{PROD,TEST,DEV}_VISUAL_IDENTIFIER_EXPANSION=''
  #
  # typeset -g POWERLEVEL9K_AWS_PROD_FOREGROUND='red'
  # typeset -g POWERLEVEL9K_AWS_TEST_FOREGROUND='yellow'
  # typeset -g POWERLEVEL9K_AWS_DEV_FOREGROUND='green'

  # status

  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=false
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR=true

  typeset -g POWERLEVEL9K_STATUS_{OK,ERROR}_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_STATUS_{OK,ERROR}_FOREGROUND='black'

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
