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

fnm install --latest
fnm use default

npm install --global \
  autocannon \
  eslint \
  neovim \
  typescript

  # mdpdf

# rust

export CARGO_HOME=$XDG_DATA_HOME/cargo

# https://github.com/nabijaczleweli/cargo-update/issues/243
cargo install \
  cargo-update \
  --force --features vendored-libgit2 --features vendored-openssl

cargo install \
  jwt-cli

# neovim

# nvim -c 'autocmd User VeryLazy lua require("lazy").load({ plugins = { "mason-lspconfig.nvim", "mason-null-ls.nvim" } })'
nvim -c 'autocmd User MasonToolsUpdateCompleted quitall' -c 'autocmd User VeryLazy MasonToolsUpdate'

# silicon

pushd $XDG_CONFIG_HOME/silicon

[[ -d syntaxes ]] || mkdir syntaxes
silicon --build-cache

popd

# vscode

for EXTENSION in \
  antfu.icons-carbon \
  asvetliakov.vscode-neovim \
  CucumberOpen.cucumber-official \
  dbaeumer.vscode-eslint \
  editorconfig.editorconfig \
  esbenp.prettier-vscode \
  golang.Go \
  kddejong.vscode-cfn-lint \
  ms-azuretools.vscode-docker \
  ms-dotnettools.csdevkit \
  ms-dotnettools.csharp \
  ms-dotnettools.vscode-dotnet-runtime \
  ms-python.black-formatter \
  ms-python.debugpy \
  ms-python.isort \
  ms-python.python \
  ms-python.pylint \
  ms-python.vscode-pylance \
  pkief.material-icon-theme \
  redhat.vscode-yaml \
  sainnhe.gruvbox-material \
  streetsidesoftware.code-spell-checker \
  sumneko.lua
do
  code --install-extension $EXTENSION --force
done

  # JakeBecker.elixir-ls

# docker

docker run --privileged --rm tonistiigi/binfmt --install arm64
docker rmi $(docker images tonistiigi/binfmt -a -q)

docker buildx create --name builder --use

# yazi

FILE=$XDG_CONFIG_HOME/yazi/package.toml
[[ -f $FILE ]] && rm -f $FILE

for PLUGIN in \
  KKV9/compress \
  yazi-rs/plugins#jump-to-char
do
  ya pack --add "$PLUGIN"
done

