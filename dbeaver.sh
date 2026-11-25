#!/usr/bin/env bash
set -eo pipefail -ux

# config

SRC=$(dirname "$(realpath "$0")")/dbeaver/DBeaverData
DST=$XDG_DATA_HOME/DBeaverData

FILES=(
  settings/product-config.json
  workspace6/.metadata/.config/connection-types.xml
  workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.ui.editors.prefs
  workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.ui.workbench.prefs
  workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs
  workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.ui.statistics.prefs
  workspace6/General/.dbeaver/data-sources.json
)

for FILE in "${FILES[@]}"; do
  mkdir -p "$(dirname "$DST/$FILE")"
  cp --update=none "$SRC/$FILE" "$DST/$FILE"
done
