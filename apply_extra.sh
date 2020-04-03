#!/bin/bash
set -e
FLATPAK_ID="com.blackmagicdesign.resolve"
VERSION="16.2"
DIST_BASENAME="DaVinci_Resolve_${VERSION}_Linux"

APPDIR=/app/extra/resolve
DATADIR=/app/extra/export/share

mkdir -p "${APPDIR}" "${DATADIR}"
unzip -p "${DIST_BASENAME}.zip" "${DIST_BASENAME}.run" | bsdtar -x -f - -C "${APPDIR}"

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
                install -Dm644 "${APPDIR}/graphics/${desktop_names[$dsk]}_${s}x${s}_apps.png" \
                               "${DATADIR}/icons/hicolor/${s}x${s}/apps/${dsk}.png"
            done
        ;;
        DaVinciResolve*)
            if [ -n "${icon_files[$dsk]}" ]; then
                install -Dm644 "${APPDIR}/graphics/${icon_files[$dsk]}.png" \
                               "${DATADIR}/icons/hicolor/128x128/apps/${dsk}.png"
            fi
        ;;
    esac

    # Install .desktop file
    install -Dm644 "${APPDIR}/share/${desktop_names[$dsk]}.desktop" \
                   "${DATADIR}/applications/${dsk}.desktop"
    sed "s|RESOLVE_INSTALL_LOCATION|${APPDIR}|g" \
        -i "${DATADIR}/applications/${dsk}.desktop"
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
        "${DATADIR}/applications/${dsk}.desktop"
done

# Install Resolve mime

install -Dm644 "${APPDIR}/share/resolve.xml" \
               "${DATADIR}/mime/packages/${FLATPAK_ID}.xml"

install -Dm644 "${APPDIR}/graphics/DV_ResolveProj.png" \
               "${DATADIR}/icons/hicolor/128x128/mimetypes/${FLATPAK_ID}.x-resolveproj.png"

sed "s|\\(<mime-type type=\"application/x-resolveproj\">\\)|\\1\\n<icon name=\"${FLATPAK_ID}.x-resolveproj\"/>|g" \
     -i "${DATADIR}/mime/packages/${FLATPAK_ID}.xml"

# Install Blackmagic RAW mime

install -Dm644 "${APPDIR}/share/blackmagicraw.xml" \
               "${DATADIR}/mime/packages/${FLATPAK_ID}.raw.xml"

for m in x-braw-sidecar x-braw-clip; do
    for s in 48 256; do
        install -Dm644 "${APPDIR}/graphics/application-${m}_${s}x${s}_mimetypes.png" \
                       "${DATADIR}/icons/hicolor/${s}x${s}/mimetypes/${FLATPAK_ID}.${m}.png"
    done
    sed "s|\\(<mime-type type=\"application/${m}\">\\)|\\1\\n<icon name=\"${FLATPAK_ID}.${m}\"/>|g" \
        -i "${DATADIR}/mime/packages/${FLATPAK_ID}.raw.xml"
done

# Install desktop directory

install -Dm644 "${APPDIR}/share/DaVinciResolve.directory" \
               "${DATADIR}/desktop-directories/${FLATPAK_ID}.directory"

sed "s|RESOLVE_INSTALL_LOCATION|${APPDIR}|g" \
    -i "${DATADIR}/desktop-directories/${FLATPAK_ID}.directory"

# Hook scripts

desktop-file-edit \
    --set-key="Exec" --set-value="resolve %f" \
    "${DATADIR}/applications/${dsk}.desktop"

# Cleanup

rm ${APPDIR}/libs/lib{ssl,crypto}.so*

rm "${DIST_BASENAME}.zip"
