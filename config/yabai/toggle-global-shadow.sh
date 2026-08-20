#!/usr/bin/env bash
# toggle-global-shadow.sh — flip window shadows for ALL windows (yabai config),
# as opposed to the per-window `d` toggle in window mode.
#
# `yabai -m config window_shadow` with no value PRINTS the current setting, so
# the toggle needs no state file. We flip between on and off; the third value
# ('float' = shadows only on floating windows) is deliberately never chosen --
# ~/.yabairc explains why it is a bad fit for a mixed bsp/float setup.
#
# Requires the scripting addition. Applies live to every window.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai

cur=$("$YABAI" -m config window_shadow 2>/dev/null) || { osascript -e beep >/dev/null 2>&1 & exit 0; }

if [ "$cur" = "on" ]; then
    "$YABAI" -m config window_shadow off
else
    "$YABAI" -m config window_shadow on
fi
