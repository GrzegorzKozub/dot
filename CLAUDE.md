# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles for a Linux development environment. Configuration is deployed via **GNU Stow** — each top-level directory is a Stow package that gets symlinked into `$HOME` or `$XDG_CONFIG_HOME`. Several large configs (`nvim`, `vscode`, `mpv`, `yazi`, `nushell`) live in separate repos and are pulled in as **git submodules**.

## Key Scripts

| Script | Purpose |
|--------|---------|
| `./init.sh` | One-time repo setup: git submodules, sensitive file masking |
| `./install.sh` | Full system bootstrap: zsh/zinit, tmux, node (fnm), python (uv), rust (rustup), neovim, vscode, docker buildx |
| `./update.sh` | Incremental updates: self, submodules, zsh plugins, tmux plugins, language toolchains, neovim plugins, vscode extensions |
| `./links.sh` | Deploy symlinks via stow (also handles host-specific `environment/` configs) |
| `./reset.sh` | Targeted teardown of node, nvim, or rust installs |
| `./claude.sh` | Sync Claude Code config from external storage (for sensitive settings not in git) |

## Architecture

### Stow Deployment

`links.sh` calls `stow --target $HOME` for root-level dotfiles and `stow --target $XDG_CONFIG_HOME` for everything under `*/` directories. Host-specific environment configs (Intel/Nvidia/AMD GPU machines: `drifter`, `player`, `worker`, `sacrifice`) are symlinked from `environment/environment.d/`.

### XDG Layout

```
$XDG_CONFIG_HOME (~/.config)  ← stow target for app configs
$XDG_DATA_HOME  (~/.local/share)
$XDG_CACHE_HOME (~/.cache)
$ZDOTDIR        (~/.config/zsh)
```

### Git Submodules

Five separate repos tracked as submodules — update with `git submodule update --remote` or via `./update.sh`. The submodule paths are `nvim/nvim`, `vscode/user-data`, `mpv/mpv`, `yazi/yazi`, `nushell/nushell`.

### Claude Code Config

Two separate Claude-related directories with different purposes:
- `.claude/` — Claude Code settings *for this repo* (not deployed via stow): `settings.json` (sandboxing, permissions, model, vim mode, statusline hook), `settings.local.json` (machine-local overrides), plus `commands/`, `skills/`, and `agents/` subdirectories.
- `claude/` — a stow package that deploys `claude/claude/statusline.sh` to `~/.config/claude/statusline.sh`. This ~200-line bash script renders the Claude Code status line (git info, context %, tokens, cost, model, vim mode, worktree).

### Per-App Install Scripts

Root-level `*.sh` files (e.g. `ansible.sh`, `aws.sh`, `copilot.sh`, `dbeaver.sh`, `intellij.sh`, `teams.sh`, `work.sh`) are optional per-app installers — each typically calls `stow` for its package and runs any app-specific setup. They are not called by `install.sh` or `update.sh`; run manually when installing that app.

`zinit.zsh` updates zinit and zsh plugins; called by `update.sh`. `shared.sh` installs Go tools via `go install`; called by both `install.sh` and `update.sh`.

### Secrets

Sensitive shell environment (API keys, tokens) lives on an external drive at `/run/media/data/.secrets/.zshenv`, sourced from `.zprofile`. On `player`/`worker` hosts, HuggingFace and llama.cpp caches are redirected from `~/.cache/` to `/run/media/$USER/data/.cache/` via symlinks (set up in `links.sh`). Files like `btop/btop/btop.conf` and `tidal-hifi/tidal-hifi/config.json` are tracked with `git update-index --assume-unchanged` to avoid committing machine-local state.

## Shell Config

`zsh/zsh/.zshrc` (737 lines) sets up zinit plugin manager with `zsh-defer` lazy loading, Powerlevel10k prompt, fzf-tab completions, vi mode with cursor shape changes, and history filtering that strips bearer tokens/passwords/secrets. Zsh auto-launches tmux unless running inside VSCode, Zed, or JetBrains.

## Neovim Updates

```sh
nvim --headless -c 'Lazy! sync' -c 'TSUpdate' -c 'MasonToolsUpdate'
```

(Also run automatically by `./update.sh`.)
