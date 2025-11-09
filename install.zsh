#!/usr/bin/env zsh

set -e -o verbose

# env

export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-~/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-~/.local/share}

# dirs

[[ -d $XDG_CONFIG_HOME ]] || mkdir -p $XDG_CONFIG_HOME
[[ -d $XDG_CACHE_HOME ]] || mkdir -p $XDG_CACHE_HOME
[[ -d $XDG_DATA_HOME ]] || mkdir -p $XDG_DATA_HOME

# zsh

export ZDOTDIR=$XDG_CONFIG_HOME/zsh

[[ -d $XDG_DATA_HOME/zinit ]] && rm -rf $XDG_DATA_HOME/zinit
mkdir -p $XDG_DATA_HOME/zinit

git clone https://github.com/zdharma-continuum/zinit.git $XDG_DATA_HOME/zinit/bin

export TMUX=1
zsh -c "source $XDG_CONFIG_HOME/zsh/.zshrc && exit"
unset TMUX

# tmux

[[ -d $XDG_DATA_HOME/tmux ]] && rm -rf $XDG_DATA_HOME/tmux
mkdir -p $XDG_DATA_HOME/tmux/plugins

git clone https://github.com/tmux-plugins/tpm $XDG_DATA_HOME/tmux/plugins/tpm

tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf new-session -d
$XDG_DATA_HOME/tmux/plugins/tpm/bindings/install_plugins
tmux kill-server

# yazi

rm -rf ~/.local/state/yazi/packages
pushd $XDG_CONFIG_HOME/yazi && git clean -dfx && popd

for PLUGIN in \
  yazi-rs/plugins:git
do
  ya pkg add "$PLUGIN"
done

# gnupg

# export GNUPGHOME=$XDG_DATA_HOME/gnupg

# [[ -d $GNUPGHOME ]] && rm -rf $GNUPGHOME
# mkdir $GNUPGHOME && chmod 700 $GNUPGHOME

# gpg --batch --passphrase '' --quick-gen-key grzegorz.kozub@gmail.com rsa auth,encr,sign never

# gpg --batch --generate-key <<EOF
# %no-protection
# Key-Type: rsa
# Key-Length: 3072
# Key-Usage: auth,encr,sign
# Name-Real: Grzegorz Kozub
# Name-Email: grzegorz.kozub@gmail.com
# EOF

# pass

export PASSWORD_STORE_DIR=$XDG_DATA_HOME/pass

[[ -d $PASSWORD_STORE_DIR ]] && rm -rf $PASSWORD_STORE_DIR

pass init grzegorz.kozub@gmail.com

# shared

. `dirname $0`/shared.zsh

# bat

bat cache --build

# node

export NPM_CONFIG_CACHE=$XDG_CACHE_HOME/npm
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
# export NPM_CONFIG_PREFIX=$XDG_DATA_HOME/npm

# nvm install node --latest-npm
# nvm install-latest-npm
# nvm cache clear

eval "$(fnm env)"
fnm install --latest
fnm use default

npm install --global \
  eslint \
  neovim \
  typescript

  # @anthropic-ai/claude-code @google/gemini-cli artillery autocannon mdpdf

# python

for TOOL in lastversion tidal-dl-ng; do uv tool install $TOOL; done

if [[ $HOST =~ ^(drifter|worker)$ ]]; then # work
  for TOOL in awscli-local cfn-lint; do uv tool install $TOOL; done
fi

# rust

path=($XDG_DATA_HOME/cargo/bin $path[@])

export CARGO_HOME=$XDG_DATA_HOME/cargo
export RUSTUP_HOME=$XDG_DATA_HOME/rustup

cargo install cargo-update
  # --force --features vendored-libgit2 --features vendored-openssl
  # https://github.com/nabijaczleweli/cargo-update/issues/243

# neovim

# nvim -c 'autocmd User VeryLazy lua require("lazy").load({ plugins = { "mason-lspconfig.nvim", "mason-null-ls.nvim" } })'
nvim -c 'autocmd User MasonToolsUpdateCompleted quitall' -c 'autocmd User VeryLazy MasonToolsUpdate'

# silicon

pushd $XDG_CONFIG_HOME/silicon

[[ -d syntaxes ]] || mkdir syntaxes
silicon --build-cache

popd

# vscode

set +e

for EXTENSION in \
  Catppuccin.catppuccin-vsc-icons \
  dbaeumer.vscode-eslint \
  editorconfig.editorconfig \
  esbenp.prettier-vscode \
  golang.go \
  grzegorzkozub.gruvbox-material-flat \
  miguelsolorio.symbols \
  ms-azuretools.vscode-containers \
  ms-python.debugpy \
  ms-python.python \
  ms-python.vscode-pylance \
  rust-lang.rust-analyzer \
  streetsidesoftware.code-spell-checker \
  sumneko.lua \
  tamasfe.even-better-toml
do
  code --install-extension $EXTENSION --force
done

  # jakebecker.elixir-ls \
  # vadimcn.vscode-lldb \

if [[ $HOST =~ ^(drifter|worker)$ ]]; then # work

  for EXTENSION in \
    bierner.markdown-mermaid \
    cucumberopen.cucumber-official \
    github.copilot \
    github.copilot-chat \
    kddejong.vscode-cfn-lint \
    ms-dotnettools.csdevkit \
    ms-dotnettools.csharp \
    ms-dotnettools.vscode-dotnet-runtime \
    redhat.java \
    redhat.vscode-yaml
  do
    code --install-extension $EXTENSION --force
  done

fi

set -e

# docker

export DOCKER_CONFIG=$XDG_CONFIG_HOME/docker
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock # rootless

docker run --privileged --rm tonistiigi/binfmt --install arm64
docker rmi $(docker images tonistiigi/binfmt -a -q)

docker buildx create --name builder --use

