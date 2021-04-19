#!/bin/bash
FLATPAK_ID=im.trillian.Trillian

ar p trillian.deb data.tar.xz | tar -xJf -

mv usr/share/trillian trillian

mkdir -p export/share
cp -r usr/share/{icons,applications} export/share/
rename --no-overwrite "trillian" "$FLATPAK_ID" export/share/{icons/hicolor/*/*,applications}/*.*
desktop-file-edit \
    --set-key="Exec" --set-value="trillian" \
    --set-key="Icon" --set-value="$FLATPAK_ID" \
    "export/share/applications/$FLATPAK_ID.desktop"

rm -r usr trillian.deb
