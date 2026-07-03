#!/usr/bin/env bash
set -eo pipefail -ux

# yazi

rm -rf ~/.local/state/yazi/packages
pushd "$XDG_CONFIG_HOME"/yazi && git clean -dfx && popd

for PLUGIN in \
  yazi-rs/plugins:git \
  yazi-rs/plugins:toggle-pane; do
  ya pkg add "$PLUGIN"
done
