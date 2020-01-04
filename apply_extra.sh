#!/bin/bash
set -e
FLATPAK_ID=com.teamviewer.TeamViewer
TV_VER_MAJOR=15

mkdir -p teamviewer export/share/{dbus-1/services,polkit-1/actions,applications}
tar -xf teamviewer.tar.xz -C teamviewer --strip-components=1

install -Dm644 "teamviewer/tv_bin/script/${FLATPAK_ID}"{,.Desktop}.service -t export/share/dbus-1/services/
install -Dm644 "teamviewer/tv_bin/desktop/${FLATPAK_ID}.desktop" -t export/share/applications/
for s in 16 20 24 32 48 256; do
    install -Dm644 "teamviewer/tv_bin/desktop/teamviewer_$s.png" \
                   "export/share/icons/hicolor/${s}x${s}/apps/${FLATPAK_ID}.png"
done
for f in export/share/{"dbus-1/services/${FLATPAK_ID}"{,.Desktop}.service,"applications/${FLATPAK_ID}.desktop"}; do
    sed "s|/opt/teamviewer/|/app/extra/teamviewer/|g" -i "$f"
done
sed "s|Icon=.*|Icon=${FLATPAK_ID}|g" -i "export/share/applications/${FLATPAK_ID}.desktop"

sed \
    -e "s|TAR_NI|TAR_IN|g" \
    -e "s|/opt/teamviewer|/app/extra/teamviewer|g" \
    -e "s|.config/|.var/app/${FLATPAK_ID}/config/|g" \
    -e "s|.local/share/|.var/app/${FLATPAK_ID}/data/|g" \
    -i teamviewer/tv_bin/script/tvw_config

rmdir teamviewer/{config,logfiles}
ln -s "/var/config/teamviewer" teamviewer/config
ln -s "/var/data/teamviewer${TV_VER_MAJOR}/logfiles" teamviewer/logfiles
ln -s "/var/data/teamviewer${TV_VER_MAJOR}" teamviewer/profile

rm teamviewer.tar.xz
