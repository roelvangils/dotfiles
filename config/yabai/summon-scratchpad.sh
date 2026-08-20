#!/usr/bin/env bash
# summon-scratchpad.sh <label> — show/hide the scratchpad, LOUDLY.
#
# `yabai -m window --toggle <label>` fails with "unknown value" when no window
# holds the label (after a yabai restart, or before anything was claimed).
# Bound to hyper-p that failure used to vanish into skhd's log file; this
# wrapper turns it into the beep + toast every other failing binding gets
# (see focus-space.sh / move-window-to-space.sh for the philosophy).

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
HS=/opt/homebrew/bin/hs
LABEL="${1:-pad}"

if ! "$YABAI" -m window --toggle "$LABEL" 2>/dev/null; then
    osascript -e beep >/dev/null 2>&1 &
    "$HS" -A -t 2 -c "require('toast').show([[No scratchpad claimed — tap ⇪, then ⇧P on a window]], { duration = 3 })" >/dev/null 2>&1 &
fi
