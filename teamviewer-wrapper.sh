#!/bin/bash

# symlink targets must exist before TV is started
for d in config logfiles profile; do
    mkdir -p "$(readlink -m "/app/extra/teamviewer/$d")"
done

exec /app/extra/teamviewer/tv_bin/script/teamviewer $@
