#!/usr/bin/env zsh

set -e -o verbose

# repo

pushd `dirname $0`

for ITEM (
  'intellij/JetBrains/IdeaIC2025.2/early-access-registry.txt'
  'intellij/JetBrains/IdeaIC2025.2/idea64.vmoptions'
  'intellij/JetBrains/IdeaIC2025.2/options/colors.scheme.xml'
  'intellij/JetBrains/IdeaIC2025.2/options/editor-font.xml'
  'intellij/JetBrains/IdeaIC2025.2/options/ide.general.xml'
  'intellij/JetBrains/IdeaIC2025.2/options/jdk.table.xml'
  'intellij/JetBrains/IdeaIC2025.2/options/laf.xml'
  'intellij/JetBrains/IdeaIC2025.2/options/project.default.xml'
  'intellij/JetBrains/IdeaIC2025.2/options/trusted-paths.xml'
  'maven/maven/settings.xml'
)
  git update-index --assume-unchanged $ITEM

popd

# links

stow --dir=`dirname $0` --target=$XDG_CONFIG_HOME --stow \
  intellij \
  maven

CACHE=/run/media/$USER/data/.cache
[[ -d $CACHE ]] || {
  sudo mkdir $CACHE
  sudo chown $USER $CACHE
  sudo chgrp users $CACHE
}

[[ -d $CACHE/maven ]] || mkdir $CACHE/maven
[[ -L $XDG_CACHE_HOME/maven ]] || ln -s $CACHE/maven $XDG_CACHE_HOME/maven

# intellij

intellij-idea-community-edition installPlugins \
  cucumber-java \
  gherkin \
  JUnit

