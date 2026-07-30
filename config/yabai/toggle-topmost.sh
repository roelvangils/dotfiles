#!/usr/bin/env bash
# toggle-topmost.sh — flip the focused window between "always on top" and normal.
#
# yabai v7 removed `--toggle topmost`; the replacement is `--sub-layer <LAYER>`
# (LAYER := below | normal | above | auto), which is a SETTER, not a toggle.
# So we read the current sub-layer and flip it ourselves.
#
#   above -> auto    hands the window back to yabai's automatic management;
#                    note the query then reports it as "normal", not "auto"
#   anything else -> above
#
# Requires the scripting addition (sub-layer is one of the SIP-gated features).
# Deliberately uses grep rather than python3: this runs under launchd via skhd,
# which has a minimal PATH.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai

# Exits 1 with "could not retrieve window details" when nothing is focused
# (e.g. an empty space, or focus sitting on the desktop).
if ! info=$("$YABAI" -m query --windows --window 2>/dev/null); then
    osascript -e beep >/dev/null 2>&1 &
    exit 0
fi

if printf '%s' "$info" | grep -q '"sub-layer"[[:space:]]*:[[:space:]]*"above"'; then
    "$YABAI" -m window --sub-layer auto
else
    "$YABAI" -m window --sub-layer above
fi
