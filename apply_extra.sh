#!/bin/bash
set -e

FLATPAK_ID="com.softmaker.FreeOffice"
YEAR="2018"
SUITE="FreeOffice"
VARIANT="free"

mkdir freeoffice
tar -xOf freeoffice.tgz freeoffice${YEAR}.tar.lzma | tar -xJf - -C freeoffice

declare -A abbreviations
abbreviations=(
    [textmaker]="tm"
    [planmaker]="pm"
    [presentations]="pr"
)

declare -A fullnames
fullnames=(
    [textmaker]="$SUITE $YEAR TextMaker"
    [planmaker]="$SUITE $YEAR PlanMaker"
    [presentations]="$SUITE $YEAR Presentations"
)

app_icon_sizes=(16 24 32 48 64 72 128 256 512 1024)
mime_icon_sizes=(16 24 32 48 64 96 128 256 512 1024)

for app in textmaker planmaker presentations; do
    a=${abbreviations[$app]}
    # Install desktop entry
    desktop_file="export/share/applications/$FLATPAK_ID-$app.desktop"
    install -Dm644 "freeoffice/mime/${a}l${YEAR: -2}.dsk" "$desktop_file"
    desktop-file-edit \
        --set-key="Name" --set-value="${fullnames[$app]}" \
        --set-key="Icon" --set-value="$FLATPAK_ID-$app" \
        --set-key="Exec" --set-value="$app %F" \
        --set-key="TryExec" --set-value="$app" \
        --set-key="StartupWMClass" --set-value="${a}" \
        --set-key="X-Flatpak-RenamedFrom" --set-value="${app}-${VARIANT}${YEAR: -2}.desktop;" \
        "$desktop_file"
    # install application icons
    for s in "${app_icon_sizes[@]}"; do
        install -Dm644 "freeoffice/icons/${a}l_${s}.png" "export/share/icons/hicolor/${s}x${s}/apps/$FLATPAK_ID-$app.png"
    done
done

install -Dm644 "freeoffice/mime/softmaker-freeoffice${YEAR: -2}.xml" "export/share/mime/packages/$FLATPAK_ID.xml"

for t in {tmd,pmd,prd}{,_mso,_oth}; do
    suffix=${t/_/-}
    # install mime icons
    for s in "${mime_icon_sizes[@]}"; do
        install -Dm644 "freeoffice/icons/${t}_${s}.png" "export/share/icons/hicolor/${s}x${s}/mimetypes/$FLATPAK_ID-$suffix.png"
    done
    # change icon names in mimeinfo file
    sed "s/icon name=\"application-x-$suffix\"/icon name=\"$FLATPAK_ID-$suffix\"/g" -i "export/share/mime/packages/$FLATPAK_ID.xml"
done

rm freeoffice.tgz
