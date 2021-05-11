#!/bin/bash
export XCURSOR_PATH=$(echo "$XDG_DATA_DIRS" | sed 's,\(:\|$\),/icons\1,g')
export CHROME_WRAPPER=$(readlink -f "$0")
export TMPDIR="$XDG_RUNTIME_DIR/app/$FLATPAK_ID"
export ZYPAK_SANDBOX_FILENAME=vivaldi-sandbox

exec zypak-wrapper.sh /app/extra/vivaldi/vivaldi "$@"
