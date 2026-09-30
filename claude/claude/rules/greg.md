# Cloning and updaing git repos

Clone repositories with `fetch <repo name>`, never `git clone`. It clones via SSH (`git@github.com:<owner>/<name>.git`) and picks the local path:

- `efficy-sa/apsis-*` → `~/code/apsis/<rest of repo name>` (e.g. `fetch apsis-shared-claude-plugins` → `~/code/apsis/shared-claude-plugins`)
- `efficy-sa/efficy-*` → `~/code/efficy/<rest of repo name>` (e.g. `fetch efficy-claude-marketplace` → `~/code/efficy/claude-marketplace`)
- All other repos → `~/code/<repo name>`
- A second argument overrides the path, relative to `~/code`: `fetch <repo name> <dir>` → `~/code/<dir>`.
- `--wiki` clones the repo's GitHub wiki (`<repo name>.wiki.git`) instead, to the same path with `.wiki` appended (e.g. `fetch --wiki apsis-engine` → `~/code/apsis/engine.wiki`). `no wiki in <repo>` means the repo has no wiki pages; don't retry. It must be the first argument.

Use `fetch` only when the target directory doesn't exist yet. If it reports `unknown repo`, stop and ask the user.

Update an existing checkout with `git`, not `fetch`. On an existing checkout `fetch` switches to `main`/`master` and pulls, which moves the checkout off whatever branch you or another agent had checked out. Instead, `cd <dir>` (its own call), then `git fetch --prune`. That's enough for worktrees, which branch from `origin/<default-branch>`. Run `git pull --ff-only` only when the checkout is already on its default branch and you need its files current.

# Worktrees for story work

Sessions start in `~/code/apsis`, which is not a repo; a story usually spans several `apsis-*` repos. Never edit files, switch branches, or commit in a repo's main checkout — it stays on the default branch as a read-only reference.

Use worktrunk (`wt`) when it's installed, plain `git` otherwise. Check once per session with `command -v wt`. Both give the same result: branch and directory are the Jira key in **lowercase** (`AO-1234` → `ao-1234`), the same in every repo, at `<repo>/.worktrees/<key>`, based on `origin/<default-branch>` (`git symbolic-ref --short refs/remotes/origin/HEAD`).

For every repo the story touches:

1. `cd ~/code/apsis/<repo>` (its own call), then `git fetch --prune`.
2. Reuse the story's worktree if it exists:
   - `wt list`
   - without `wt`: `git worktree list`
3. Otherwise create it:
   - `wt switch --create ao-1234 --base origin/<default-branch> --no-cd --yes`
   - without `wt`: `git worktree add .worktrees/ao-1234 -b ao-1234 origin/<default-branch>`
4. Edit, build, test, and commit only under `~/code/apsis/<repo>/.worktrees/<key>`. `cd` there in its own call before running git. Install dependencies per worktree (`npm ci`, etc.).
5. After the PR merges, from the main checkout (never `rm -rf`):
   - `wt remove <key> --foreground --yes`
   - without `wt`: `git worktree remove .worktrees/<key>`, then `git branch -d <key>`

Exception: wiki repos (path ends in `.wiki`) are single-branch — edit them directly in the main checkout, no worktree needed. Don't suggest or create one; `worktree.sh` already permits direct edits there.

Don't use the EnterWorktree tool for this: it can only track one repo per session.

This also applies when you run `/implement-story`. If that skill checks out branches in the main checkout itself, this section is what tells Claude not to.

`.worktrees/` is ignored globally (`~/.config/git/ignore`). Don't add it to `.gitignore` or `.git/info/exclude`, and don't report on it. If a check says it isn't ignored, the check ran sandboxed, where the global ignore file is hidden. Re-check with a bare `git check-ignore -v .worktrees/`.

# Launching subagents

A subagent does not reliably inherit this file. **Every** agent prompt you write must restate the rules from this file that the agent's task could touch — copy the concrete values, don't paraphrase or refer to "the conventions".

The same applies to agent teams, workflows, and any skill you invoke that spawns its own agents.
