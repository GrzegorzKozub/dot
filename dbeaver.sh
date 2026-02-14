#!/usr/bin/env bash
set -eo pipefail -ux

# repo

pushd "${BASH_SOURCE%/*}"

FILES=(
  .metadata/.config/connection-types.xml
  .metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.ui.editors.prefs
  .metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.ui.workbench.prefs
  .metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs
  .metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.ui.app.standalone.prefs
  .metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.ui.statistics.prefs
  .metadata/.plugins/org.jkiss.dbeaver.ui/dialog_settings.xml
  General/.dbeaver/data-sources.json
)

for FILE in "${FILES[@]}"; do
  git update-index --assume-unchanged dbeaver/DBeaverData/workspace6/"$FILE"
done

popd

# links

stow --dir="${BASH_SOURCE%/*}" --target="$XDG_DATA_HOME" --stow \
  dbeaver
