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

