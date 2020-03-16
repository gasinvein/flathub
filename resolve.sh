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

temp_libdir="$XDG_RUNTIME_DIR/app/$FLATPAK_ID/libs"
test -d "$temp_libdir" || mkdir -p "$temp_libdir"

cuda_lib=(/usr/lib/*/GL/*/lib/libcuda.so.1)
if [ -f "${cuda_lib[0]}" ] && [ ! -f "$temp_libdir/libcuda.so" ]; then
    ln -s "$(readlink -f "${cuda_lib[0]}")" "$temp_libdir/libcuda.so"
fi

if [ -z "$LD_LIBRARY_PATH" ]; then
    export LD_LIBRARY_PATH="$temp_libdir"
else
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$temp_libdir"
fi

cd "/app/extra/davinci-resolve"
exec "$(pwd)/$subdir/$this_cmd" "$@"
