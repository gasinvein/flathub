#!/bin/bash
set -e
FLATPAK_ID=com.vivaldi.Vivaldi

ar p vivaldi.deb data.tar.xz | tar -xJf -

mv opt/vivaldi .
cp /app/bin/stub_sandbox vivaldi/vivaldi-sandbox
patch -d vivaldi -p1 < /app/share/vivaldi-wrapper.patch

install -Dm644 "usr/share/applications/vivaldi-stable.desktop" \
               "export/share/applications/$FLATPAK_ID.desktop"
for s in 16 22 24 32 48 64 128 256; do
    install -Dm644 "vivaldi/product_logo_$s.png" \
                   "export/share/icons/hicolor/${s}x${s}/apps/$FLATPAK_ID.png"
done
sed "s|Exec=/usr/bin/vivaldi-stable|Exec=vivaldi|g" -i "export/share/applications/$FLATPAK_ID.desktop"
sed "s|Icon=vivaldi|Icon=$FLATPAK_ID|g" -i "export/share/applications/$FLATPAK_ID.desktop"

rm -r etc usr opt vivaldi.deb
