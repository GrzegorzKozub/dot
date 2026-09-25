#!/usr/bin/env bash
set -eo pipefail -u

# PreToolUse: block Bash calls that won't escape the sandbox via excludedCommands

TOOLS='auth0|aws|docker|gh|git|podman|scp|ssh'
USES="(^|[;&|(\`]|\\\$\\()[[:space:]]*([[:alnum:]_]+=[^[:space:]]*[[:space:]]+)*($TOOLS)([[:space:]]|$)"
SUBST="\\\$\\(|\`"
BARE="^($TOOLS)([[:space:]]|$)"
REDIR='[<>]'
GITDIR='^git[[:space:]]+(-C|-c|--git-dir|--work-tree)'

deny() {
  echo "Runs sandboxed ($1), so $TOOLS can't read their credentials. Use one bare command per call: no pipes, ;, cd, env prefix, \$(...), file redirects or git -C/-c/--git-dir. Filter with --jq/--query, cd in its own call, pass text via files under the working dir." >&2
  exit 2
}

CMD=$(jq -r '.tool_input.command // ""')
CMD=${CMD//$'\n'/;}

ENABLED=$({ cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/settings.json "${CLAUDE_PROJECT_DIR:-.}"/.claude/settings{,.local}.json 2> /dev/null || true; } |
  jq -s 'map(.sandbox.enabled | values) | last // false')
[[ $ENABLED == true ]] || exit 0

S=$(sed -E "s/'[^']*'//g" <<< "$CMD")
[[ $S =~ $USES ]] || exit 0
[[ $S =~ $SUBST ]] && deny 'command substitution'

S=$(sed -E 's/"([^"\\]|\\.)*"//g; s/[0-9]*>&[0-9-]+//g; s/&&|\|\||[;|&]/\n/g' <<< "$S")
while read -r P; do
  [[ -z $P ]] && continue
  [[ $P =~ $BARE ]] || deny "\`${P%% *}\` is not excluded"
  [[ $P =~ $REDIR ]] && deny 'file redirection'
  [[ $P =~ $GITDIR ]] && deny 'git path flag'
done <<< "$S"

exit 0
