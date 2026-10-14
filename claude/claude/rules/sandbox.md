# Sandboxed bash and excluded commands

`auth0`, `aws`, `docker`, `fetch`, `gh`, `git`, `podman`, `scp`, `ssh`, and `wt` are in `sandbox.excludedCommands`, so they run outside the sandbox with access to their credentials, but only when the whole Bash call matches. Pipes, `;`, `cd … &&`, env-var prefixes, `$(...)`, file redirects, `git -C`, `git clone <url> <dir>`, and `aws --profile` / `--endpoint-url` keep the call sandboxed (Claude Code bugs, e.g. anthropics/claude-code#95455, #95532, #97810).

A sandboxed call fails misleadingly because `~/.ssh`, `~/.aws`, and `~/.config/gh` are hidden: empty output, `Host key verification failed`, `gh` unauthenticated, `The config profile (…) could not be found`. When a command fails like that, retry it once with `dangerouslyDisableSandbox`. Don't rewrite it to dodge the sandbox, and don't retry commands that failed for other reasons.

Prefer shapes that escape anyway, so fewer calls need the retry: one bare command per call, filtering with the tool's own flags (`gh --jq`, `aws --query`, `git --format`), and `cd` in its own call. `$TMPDIR` is unset for commands that run outside the sandbox, so use explicit paths under the working directory.
