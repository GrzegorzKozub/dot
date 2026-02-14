#!/usr/bin/env bash
set -eo pipefail -ux

# repo

pushd "${BASH_SOURCE%/*}"

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
  git update-index --assume-unchanged intellij/JetBrains/IdeaIC2025.2/"$FILE"
done

popd

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_CONFIG_HOME" --stow \
  intellij

# plugins

intellij-idea-community-edition installPlugins \
  com.intellij.plugins.vscodekeymap \
  cucumber-java \
  gherkin
