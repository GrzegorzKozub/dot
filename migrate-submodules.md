# Replace git submodules with a custom clone/update script

## Context

Five repos (`nvim/nvim`, `vscode/user-data`, `mpv/mpv`, `yazi/yazi`, `nushell/nushell`) are tracked as git submodules per `.gitmodules`, all pointing at `git@github.com:GrzegorzKozub/<name>.git`, branch `master`. Goal: drop git submodules entirely in favor of `repos.sh`, a small custom script that clones these repos on `init` and pulls them on `update`.

The catch: each submodule's working tree has machine-local, gitignored-inside-the-submodule content that must survive the migration (verified on the machine this was authored on):

- `nvim/nvim`: `lazy-lock.json`
- `vscode/user-data`: `Cache/`, and other runtime files under the submodule's own `**`-ignore
- `mpv/mpv`: none currently, but treat generically
- `yazi/yazi`: `package.toml`, `plugins/git.yazi/`, `plugins/toggle-pane.yazi/`
- `nushell/nushell`: `history.txt`

None of this content is tracked by git today (it's untracked in each submodule's own repo), so a naive `git rm` + delete + fresh clone would destroy it. The safe path is to convert each submodule's existing working directory *in place* into a standalone repo (absorb its `.git/modules/<path>` gitdir back into `<path>/.git`) rather than deleting and re-cloning — this is done identically on every machine, so one script (`migrate-submodules.sh`) serves both the one-time repo migration and every other machine's migration.

## Status

Done already (committed or not — check `git status`/`git log` on the machine you're on):

- [x] `repos.sh` created — `init`/`update` subcommands for the 5 repos, using `fetch` + `merge --ff-only` on update (mirrors old `git submodule update --merge --remote` semantics: fails loudly instead of silently rewriting history on divergence).
- [x] `migrate-submodules.sh` created — idempotent per-machine absorption script (see below).
- [x] `init.sh` updated — calls `./repos.sh init` instead of `git submodule update --init`.
- [x] `update.sh` updated — calls `./repos.sh update` instead of `git submodule update --merge --remote`.

Not done yet — remaining steps:

- [ ] Run `./migrate-submodules.sh` on this machine to convert the 5 local submodule checkouts to standalone repos in place.
- [ ] Delete `.gitmodules` (the script does this as its last step, once all 5 paths are converted).
- [ ] Add the 5 paths to `.gitignore`: `nvim/nvim`, `vscode/user-data`, `mpv/mpv`, `yazi/yazi`, `nushell/nushell`.
- [ ] Update `CLAUDE.md`: replace the "Git Submodules" section and the script table's `init.sh`/`update.sh` descriptions to describe `repos.sh`-managed clones instead of git submodules.
- [ ] Commit everything (removal of submodule metadata + new scripts + doc update). Commit only — don't push without asking, so it can be reviewed first.
- [ ] Push, then on every other machine: `git pull` followed by `./migrate-submodules.sh` (see below).

## What `migrate-submodules.sh` does

For each of the 5 known paths:
- If `<path>/.git` is already a plain directory, skip (already converted).
- If `<path>/.git` is a gitlink file: read the `gitdir:` target, `mv` that real gitdir (under the parent repo's `.git/modules/<path>`) into `<path>/.git`, then drop the `core.worktree`/`core.bare` settings in the moved config so it behaves as a normal standalone repo with its worktree colocated.
- `git rm --cached <path>` in the parent repo if the path is still in the index (no-op if already removed, e.g. on machines that already pulled the removal commit).
- Remove the `submodule.<path>` section from the parent repo's `.git/config` if present.

At the end it removes `.gitmodules` if it still exists.

It's safe to re-run, and safe to run on a machine that already pulled the "remove submodules" commit — it just skips the already-gone bits and does the local gitdir absorption, which can't be captured by a commit since `.git/modules/*` is local-only state.

## Migration sequence

**On this machine (authoring the change) — remaining steps:**
1. Run `./migrate-submodules.sh` to convert all 5 local submodule checkouts to standalone repos in place (preserves the untracked files listed above).
2. Delete `.gitmodules` if not already removed by the script, remove any leftover `[submodule ...]` sections from `.git/config`, add the 5 paths to `.gitignore`.
3. Update `CLAUDE.md`.
4. Commit everything. Don't push without asking first.

**On every other machine (after pulling this commit):**
1. `git pull`.
2. Run `./migrate-submodules.sh` once — this absorbs their local `.git/modules/<path>` into `<path>/.git` for each submodule, preserving whatever machine-local untracked files already exist there. (`git rm --cached` / `.gitmodules` removal are no-ops there since the pulled commit already did those.)

## Files changed / to change

- New: `repos.sh` — clone/update logic for the 5 repos.
- New: `migrate-submodules.sh` — one-time absorption script, kept in the repo (not deleted after use) since every other machine needs to run it too.
- `init.sh` — swapped submodule init lines for `./repos.sh init`.
- `update.sh` — swapped submodule update lines for `./repos.sh update`.
- `.gitmodules` — to be deleted (by `migrate-submodules.sh`).
- `.gitignore` — to add `nvim/nvim`, `vscode/user-data`, `mpv/mpv`, `yazi/yazi`, `nushell/nushell`.
- `CLAUDE.md` — to update "Git Submodules" section and script table.

This file (`migrate-submodules.md`) can be deleted once every machine has run the migration and `CLAUDE.md`/`.gitignore` are updated — it's a scratch tracking doc, not permanent documentation.

## Verification

- After running `migrate-submodules.sh`: `git status` in each of the 5 paths should show the same untracked files as before (compare against the "Context" list above), and `git -C <path> remote -v` should still show the correct origin.
- `git status` at the repo root should show `.gitmodules` deleted, the 5 paths no longer tracked (absent from `git ls-files`), and the new scripts present.
- Run `./repos.sh update` and confirm it fetches/updates each repo cleanly (no clone-from-scratch, no data loss).
- Run `./links.sh` afterward to confirm stow symlinks for `nvim`, `vscode`, `mpv`, `yazi`, `nushell` still resolve correctly (they point at the same paths, now plain repos instead of submodules, so this should be unaffected).
