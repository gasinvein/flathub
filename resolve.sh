#!/bin/bash
shopt -s nullglob

this_cmd=$(basename "$0")

datadir=DaVinciResolve
test -d "$XDG_DATA_HOME/$datadir" || mkdir -p "$XDG_DATA_HOME/$datadir"
test -d "$HOME/.local/share/$datadir" || ln -s "$XDG_DATA_HOME/$datadir" "$HOME/.local/share/$datadir"

case "$this_cmd" in
    resolve)
        subdir=bin
    ;;
    BlackmagicRAWPlayer|BlackmagicRAWSpeedTest)
        subdir="$this_cmd"
    ;;
    *)
        exit 1
    ;;
esac

cd "/app/extra/resolve"
exec "$(pwd)/$subdir/$this_cmd" "$@"
