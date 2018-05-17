#!/bin/bash
FO_DIR=$1
FO_VER="18"
APPID="$2"

declare -A abbreviations
abbreviations=(
    [textmaker]="tml"
    [planmaker]="pml"
    [presentations]="prl"
)

declare -A fullnames
fullnames=(
    [textmaker]="FreeOffice 2018 TextMaker"
    [planmaker]="FreeOffice 2018 PlanMaker"
    [presentations]="FreeOffice 2018 Presentations"
)

app_icon_sizes=(16 24 32 48 64 72 128 256 512 1024)
mime_icon_sizes=(16 24 32 48 64 96 128 256 512 1024)

for app in textmaker planmaker presentations; do
    a=${abbreviations[$app]}
    # install .desktop file
    desktop_file="/app/share/applications/$APPID-$app.desktop"
    install -Dm644 "$FO_DIR/mime/${a}${FO_VER}.dsk" "$desktop_file"
    {
        echo "Version=1.0";
        echo "Name=${fullnames[$app]}";
        echo "Icon=$APPID-$app";
        echo "Exec=$app %F";
        echo "TryExec=$app";
        echo "StartupWMClass=${a/l/}";
    } >> "$desktop_file"
    # install application icons
    for s in "${app_icon_sizes[@]}"; do
        install -Dm644 "$FO_DIR/icons/${a}_${s}.png" "/app/share/icons/hicolor/${s}x${s}/apps/$APPID-$app.png"
    done
done

install -Dm644 "$FO_DIR/mime/softmaker-freeoffice${FO_VER}.xml" "/app/share/mime/$APPID.xml"

for t in tmd tmd_mso tmd_oth pmd pmd_mso pmd_oth prd prd_mso prd_oth; do
    suffix=${t/_/-}
    # install mime icons
    for s in "${mime_icon_sizes[@]}"; do
        install -Dm644 "$FO_DIR/icons/${t}_${s}.png" "/app/share/icons/hicolor/${s}x${s}/mimetypes/$APPID-$suffix.png"
    done
    # change icon names in mimeinfo file
    sed "s/application-x-$suffix/$APPID-$suffix/g" -i "/app/share/mime/$APPID.xml"
done
