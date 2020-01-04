#!/bin/bash

TV_MAJOR=15

# symlink targets must exist before TV is started
for d in config logfiles profile; do
    mkdir -p "$(readlink -m "/app/extra/teamviewer/$d")"
done

# for some obscure reason, TV 15 stopped to repect paths set in tvw_main
mkdir -p $HOME/.config
ln -sr {$XDG_CONFIG_HOME,$HOME/.config}/teamviewer
mkdir -p $HOME/.local/share
ln -sr {$XDG_DATA_HOME,$HOME/.local/share}/teamviewer${TV_MAJOR}

# for some other obscure reason, in TV 15 the desktop client looks
# for teamviewerd.ipc in /var/run, while teamviewerd stores it in
# it's relative config dir, /app/extra/teamviewer/config
ln -srf /var/{config/teamviewer,run}/teamviewerd.ipc
ln -srf /var/{config/teamviewer,run}/teamviewerd.pid

exec /app/extra/teamviewer/tv_bin/script/teamviewer "$@"
