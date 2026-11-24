#!/usr/bin/env bash
set -eo pipefail -ux

# TODO: setup jdk 21 from mise

# config

PRODUCT_INFO=$(pacman -Ql intellij-idea-oss | awk '/\/product-info\.json$/ { print $2; exit }')
IDE_HOME=$(dirname "$PRODUCT_INFO")

SRC=$(dirname "$(realpath "$0")")/intellij/config
DST=$XDG_CONFIG_HOME/JetBrains/$(jq -r .dataDirectoryName "$PRODUCT_INFO")

FILES=(
  codestyles/Default.xml
  early-access-registry.txt
  idea64.vmoptions
  options/advancedSettings.xml
  options/colors.scheme.xml
  options/editor-font.xml
  options/editor.xml
  options/ide.general.xml
  options/jdk.table.xml
  options/laf.xml
  options/linux/keymap.xml
  options/notifications.xml
  options/other.xml
  options/project.default.xml
  options/terminal.xml
  options/trusted-paths.xml
  options/ui.lnf.xml
  options/updates.xml
)

for FILE in "${FILES[@]}"; do
  mkdir -p "$(dirname "$DST/$FILE")"
  cp --update=none "$SRC/$FILE" "$DST/$FILE"
done

# plugins

"$IDE_HOME"/bin/idea installPlugins \
  com.intellij.plugins.vscodekeymap \
  cucumber-java \
  gherkin || true
