#!/usr/bin/env bash
set -eo pipefail -ux

# config

SRC=$(dirname "$(realpath "$0")")/dbeaver/DBeaverData/workspace6
DST=$XDG_DATA_HOME/DBeaverData/workspace6

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
  mkdir -p "$(dirname "$DST/$FILE")"
  cp --update=none "$SRC/$FILE" "$DST/$FILE"
done
