# Bun on Arch Linux — notes

## Version management

Bun has no official version manager (no fnm/nvm equivalent shipped by the Bun team).

Options:

1. **Third-party Bun-only managers** — small, unproven compared to fnm:
   - [BVM](https://github.com/EricLLLLLL/bvm) — nvm/fnm-style, uses `.bvmrc` for per-project pinning, shell shims for auto-switching.
   - [BunVM](https://bunvm.com/) — similar concept, zero-dep, auto-switching, tab completion.

2. **`.bun-version` file** — Bun's own semi-official convention. Read by the `oven-sh/setup-bun` GitHub Action for CI. Not a local shell auto-switcher like the `.nvmrc` fnm hook.

3. **[mise](https://mise.jdx.dev/)** (formerly `rtx`) — Rust-based polyglot version manager, replaces fnm/nvm/pyenv/etc. with one tool + one config (`mise.toml` or `.tool-versions`). Natively supports Node and Bun (`mise use node@20`, `mise use bun@1.3`), and still reads existing `.nvmrc` files. This is the realistic upgrade path if per-project Bun version pinning becomes necessary — one CLI/shell hook for both runtimes instead of a second Bun-only manager bolted on next to fnm.

**Current call:** keep fnm for Node, install Bun standalone via pacman (no per-project pinning yet). Revisit `mise` only if a project actually needs a different pinned Bun version than another.

## Installing Bun

- `sudo pacman -S bun` — Bun is in the official `extra` repo. Cleanest option on Arch: distro-maintained, avoids a live AVX2-detection bug currently affecting the `bun-bin` AUR package.
- AUR packages (`bun-bin`, `bun-git`) are redundant/buggy now that Bun is in `extra` — avoid.
- `curl -fsSL https://bun.com/install | bash` — Bun's universal install script (handles AVX2/baseline detection), unnecessary on Arch given the pacman package.

## Is a manager even needed?

- Just adopting Bun as a tool (no per-repo version pinning) → `pacman -S bun` + periodic `bun upgrade` is sufficient.
- Different projects need different pinned Bun versions → BVM/BunVM, or migrate Node+Bun both onto `mise`.
