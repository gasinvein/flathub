#!/bin/bash -x
mkdir -p teamviewer export/share/{dbus-1/services,polkit-1/actions,applications}
tar -xf teamviewer.tar.xz -C teamviewer --strip-components=1

install -Dm644 teamviewer/tv_bin/script/com.teamviewer.TeamViewer{,.Desktop}.service -t export/share/dbus-1/services/
install -Dm644 teamviewer/tv_bin/desktop/com.teamviewer.TeamViewer.desktop -t export/share/applications/
#install -Dm644 teamviewer/tv_bin/script/com.teamviewer.TeamViewer.policy -t export/share/polkit-1/actions/
for res in 16 20 24 32 48 256; do
    install -Dm644 teamviewer/tv_bin/desktop/teamviewer_$res.png export/share/icons/hicolor/${res}x${res}/apps/com.teamviewer.TeamViewer.png
done
for f in export/share/{dbus-1/services/com.teamviewer.TeamViewer{,.Desktop}.service,applications/com.teamviewer.TeamViewer.desktop}; do
    sed 's|/opt/teamviewer/|/app/extra/teamviewer/|g' -i $f
done
sed 's|Icon=.*|Icon=com.teamviewer.TeamViewer|g' -i export/share/applications/com.teamviewer.TeamViewer.desktop

sed 's|TAR_NI|TAR_IN|g' -i teamviewer/tv_bin/script/tvw_config
rmdir teamviewer/{config,logfiles}
ln -s /var/config/teamviewer teamviewer/config
ln -s /var/data/teamviewer/logfiles teamviewer/logfiles
ln -s /var/data/teamviewer teamviewer/profile

rm teamviewer.tar.xz
