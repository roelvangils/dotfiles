#!/bin/sh
# Turns on the cozy lights (Home Office Desk Lamp + Corner lamp).
# Used by the login LaunchAgent (be.elevenways.hue-cozy-login) and ~/.wakeup.
export HOME="/Users/roelvangils"
export XDG_CONFIG_HOME="$HOME/.config"
LOG=/tmp/hue-cozy-login.log

for i in 1 2 3 4 5; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') attempt $i" >> "$LOG"
    if /opt/homebrew/bin/openhue set light "Home Office Desk Lamp" "Corner lamp" \
        --on --brightness 35 -t 450 --transition-time 3s >> "$LOG" 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') success" >> "$LOG"
        exit 0
    fi
    sleep 3
done
echo "$(date '+%Y-%m-%d %H:%M:%S') giving up after 5 attempts" >> "$LOG"
exit 1
