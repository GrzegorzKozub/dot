#!/usr/bin/env zsh

set -e -o verbose

# repo

pushd `dirname $0`

for ITEM (
  '.metadata/.config/connection-types.xml'
  '.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.ui.editors.prefs'
  '.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.ui.workbench.prefs'
  '.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.core.prefs'
  '.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.ui.app.standalone.prefs'
  '.metadata/.plugins/org.eclipse.core.runtime/.settings/org.jkiss.dbeaver.ui.statistics.prefs'
  '.metadata/.plugins/org.jkiss.dbeaver.ui/dialog_settings.xml'
  'General/.dbeaver/data-sources.json'
)
  git update-index --assume-unchanged dbeaver/DBeaverData/workspace6/$ITEM

popd

# links

stow --dir=`dirname $0` --target=$XDG_DATA_HOME --stow \
  dbeaver

