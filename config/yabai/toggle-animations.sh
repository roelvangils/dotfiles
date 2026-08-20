#!/usr/bin/env bash
# toggle-animations.sh — flip yabai's window animations between the configured
# 0.15s (see ~/.yabairc) and 0 (instant). Instant is what you want during
# screen recordings or when replaying layouts; toggle-layout.sh already snaps
# to 0 temporarily for its restores, this makes the choice global and sticky
# until toggled back (or until yabai restarts and ~/.yabairc reapplies 0.15).

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai

cur=$("$YABAI" -m config window_animation_duration 2>/dev/null) || { osascript -e beep >/dev/null 2>&1 & exit 0; }

if awk -v d="${cur:-0}" 'BEGIN { exit !(d > 0) }'; then
    "$YABAI" -m config window_animation_duration 0.0
else
    "$YABAI" -m config window_animation_duration 0.15
fi
