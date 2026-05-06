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

`.claude/settings.json` contains the main Claude Code config: sandboxing rules, permission allowlist/denylist (blocks `.ssh`, `.env`, `pass`, secrets), model selection, vim mode, and the custom statusline hook. `.claude/settings.local.json` holds machine-local overrides. `claude/claude/statusline.sh` is the 193-line bash script that renders the status line (git info, context %, tokens, cost, model, vim mode).

### Secrets

Sensitive shell environment (API keys, tokens) lives on an external drive at `/run/media/data/.secrets/.zshenv`, sourced from `.zprofile`. Files like `btop/btop/btop.conf` and `tidal-hifi/tidal-hifi/config.json` are tracked with `git update-index --assume-unchanged` to avoid committing machine-local state.

## Shell Config

`zsh/zsh/.zshrc` (737 lines) sets up zinit plugin manager with `zsh-defer` lazy loading, Powerlevel10k prompt, fzf-tab completions, vi mode with cursor shape changes, and history filtering that strips bearer tokens/passwords/secrets. Zsh auto-launches tmux unless running inside VSCode, Zed, or JetBrains.

## Neovim Updates

```sh
nvim --headless -c 'Lazy! sync' -c 'TSUpdate' -c 'MasonToolsUpdate'
```

(Also run automatically by `./update.sh`.)
