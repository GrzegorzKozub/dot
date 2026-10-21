# Cloning and updaing git repos

Clone repositories with `fetch <repo name>`, never `git clone`. It clones via SSH (`git@github.com:<owner>/<name>.git`) and picks the local path:

- `efficy-sa/apsis-*` → `~/code/apsis/<rest of repo name>` (e.g. `fetch apsis-shared-claude-plugins` → `~/code/apsis/shared-claude-plugins`)
- `efficy-sa/efficy-*` → `~/code/efficy/<rest of repo name>` (e.g. `fetch efficy-claude-marketplace` → `~/code/efficy/claude-marketplace`)
- All other repos → `~/code/<repo name>`
- A second argument overrides the path, relative to `~/code`: `fetch <repo name> <dir>` → `~/code/<dir>`.
- `--wiki` clones the repo's GitHub wiki (`<repo name>.wiki.git`) instead, to the same path with `.wiki` appended (e.g. `fetch --wiki apsis-engine` → `~/code/apsis/engine.wiki`). `no wiki in <repo>` means the repo has no wiki pages; don't retry. It must be the first argument.

Use `fetch` only when the target directory doesn't exist yet. If it reports `unknown repo`, stop and ask the user.

Update an existing checkout with `git`, not `fetch`. On an existing checkout `fetch` switches to `main`/`master` and pulls, which moves the checkout off whatever branch you or another agent had checked out. Instead, `cd <dir>` (its own call), then `git fetch --prune`. That's enough for worktrees, which branch from `origin/<default-branch>`. Run `git pull --ff-only` only when the checkout is already on its default branch and you need its files current.

