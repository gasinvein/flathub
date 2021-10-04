#!/bin/bash

function msg() {
    echo "vivaldi-flatpak-wrapper: $*" >> /dev/stderr
}

read -r VERSION < <(xmllint --xpath 'string(/component/releases/release[1]/@version)' "/app/share/appdata/$FLATPAK_ID.appdata.xml")

STAMPFILE="$XDG_DATA_HOME/vivaldi-$VERSION-has-ffmpeg"
if [ -f "$STAMPFILE" ]; then
    msg "FFmpeg already downloaded for $VERSION"
else
    msg "Downloading FFmpeg for $VERSION, please wait"
    if /app/extra/vivaldi/update-ffmpeg --user; then
        touch "$STAMPFILE"
        msg "Downloaded FFmpeg for $VERSION"
    else
        msg "Downloading FFmpeg for $VERSION failed"
    fi
fi

exec /app/extra/vivaldi/vivaldi "$@"
