#!/bin/bash
set -e
FLATPAK_ID="com.blackmagicdesign.resolve"
VERSION="16.2"
DIST_BASENAME="DaVinci_Resolve_${VERSION}_Linux"

mkdir -p davinci-resolve export/share
unzip -p "${DIST_BASENAME}.zip" "${DIST_BASENAME}.run" | bsdtar -x -f - -C davinci-resolve

# Install .desktop files

declare -A desktop_names
desktop_names=(
    [${FLATPAK_ID}]="DaVinciResolve"
    [${FLATPAK_ID}-Installer]="DaVinciResolveInstaller"
    [${FLATPAK_ID}-CaptureLogs]="DaVinciResolveCaptureLogs"
    [${FLATPAK_ID}-Panels]="DaVinciResolvePanelSetup"
    [${FLATPAK_ID}.rawplayer]="blackmagicraw-player"
    [${FLATPAK_ID}.rawspeedtest]="blackmagicraw-speedtest"
)

declare -A icon_files
icon_files=(
    [${FLATPAK_ID}]="DV_Resolve"
    [${FLATPAK_ID}-Installer]="DV_Uninstall"
    [${FLATPAK_ID}-Panels]="DV_Panels"
)

declare -A wm_classes
wm_classes=(
    [${FLATPAK_ID}.rawplayer]="BlackmagicRAWPlayer"
    [${FLATPAK_ID}.rawspeedtest]="BlackmagicRAWSpeedTest"
)

for dsk in "${!desktop_names[@]}"; do
    # Install icons
    case "${desktop_names[$dsk]}" in
        blackmagicraw-*)
            for s in 48 256; do
                install -Dm644 "davinci-resolve/graphics/${desktop_names[$dsk]}_${s}x${s}_apps.png" \
                               "export/share/icons/hicolor/${s}x${s}/apps/${dsk}.png"
            done
        ;;
        DaVinciResolve*)
            if [ -n "${icon_files[$dsk]}" ]; then
                install -Dm644 "davinci-resolve/graphics/${icon_files[$dsk]}.png" \
                               "export/share/icons/hicolor/128x128/apps/${dsk}.png"
            fi
        ;;
    esac

    # Install .desktop file
    install -Dm644 "davinci-resolve/share/${desktop_names[$dsk]}.desktop" \
                   "export/share/applications/${dsk}.desktop"
    sed 's|RESOLVE_INSTALL_LOCATION|/app/extra/davinci-resolve|g' \
        -i "export/share/applications/${dsk}.desktop"
    edit_args=(
        "--remove-key=Path"
        "--set-key=X-Flatpak-RenamedFrom" "--set-value=${desktop_names[$dsk]}.desktop;"
    )
    wm_class="${wm_classes[$dsk]}"
    if [ -n "$wm_class" ]; then
        edit_args+=(
            "--set-key=StartupWMClass" "--set-value=$wm_class"
        )
    fi
    if [ "${dsk}" != "${FLATPAK_ID}-CaptureLogs" ]; then
        edit_args+=(
            "--set-key=Icon" "--set-value=${dsk}"
        )
    fi
    desktop-file-edit "${edit_args[@]}" \
        "export/share/applications/${dsk}.desktop"
done

# Install Resolve mime

install -Dm644 "davinci-resolve/share/resolve.xml" \
               "export/share/mime/packages/${FLATPAK_ID}.xml"

install -Dm644 "davinci-resolve/graphics/DV_ResolveProj.png" \
               "export/share/icons/hicolor/128x128/mimetypes/${FLATPAK_ID}.x-resolveproj.png"

sed "s|\\(<mime-type type=\"application/x-resolveproj\">\\)|\\1\\n<icon name=\"${FLATPAK_ID}.x-resolveproj\"/>|g" \
     -i "export/share/mime/packages/${FLATPAK_ID}.xml"

# Install Blackmagic RAW mime

install -Dm644 "davinci-resolve/share/blackmagicraw.xml" \
               "export/share/mime/packages/${FLATPAK_ID}.raw.xml"

for m in x-braw-sidecar x-braw-clip; do
    for s in 48 256; do
        install -Dm644 "davinci-resolve/graphics/application-${m}_${s}x${s}_mimetypes.png" \
                       "export/share/icons/hicolor/${s}x${s}/mimetypes/${FLATPAK_ID}.${m}.png"
    done
    sed "s|\\(<mime-type type=\"application/${m}\">\\)|\\1\\n<icon name=\"${FLATPAK_ID}.${m}\"/>|g" \
        -i "export/share/mime/packages/${FLATPAK_ID}.raw.xml"
done

# Install desktop directory

install -Dm644 "davinci-resolve/share/DaVinciResolve.directory" \
               "export/share/desktop-directories/${FLATPAK_ID}.directory"

sed 's|RESOLVE_INSTALL_LOCATION|/app/extra/davinci-resolve|g' \
    -i "export/share/desktop-directories/${FLATPAK_ID}.directory"

# Hook scripts

desktop-file-edit \
    --set-key="Exec" --set-value="resolve %f" \
    "export/share/applications/${dsk}.desktop"

# Cleanup

rm davinci-resolve/libs/lib{ssl,crypto}.so*

rm "${DIST_BASENAME}.zip"
