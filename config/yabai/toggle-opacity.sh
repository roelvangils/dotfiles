#!/usr/bin/env bash
# toggle-opacity.sh — flip the FOCUSED window between full opacity and 75%.
#
# yabai has no opacity toggle, only a setter, so we read the current value from
# the window query and pick. Restoring uses 0.0, which CLEARS the per-window
# override (doc: "--opacity 0.0 resets to default") rather than pinning 1.0 --
# visually identical, but the window follows global opacity rules again.
#
# Requires the scripting addition (opacity is SIP-gated). Beeps if nothing is
# focused, matching toggle-topmost.sh.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
PY=/usr/bin/python3          # absolute: skhd runs under launchd with a minimal PATH

beep() { osascript -e beep >/dev/null 2>&1 & }

info=$("$YABAI" -m query --windows --window 2>/dev/null) || { beep; exit 0; }

op=$(printf '%s' "$info" \
    | "$PY" -c 'import json,sys; print(json.load(sys.stdin).get("opacity", 1.0))' 2>/dev/null)

# Anything already below 1 counts as "translucent", so the toggle always lands
# on one of exactly two states even if some other tool set 0.9.
if awk -v o="${op:-1}" 'BEGIN { exit !(o > 0 && o < 0.999) }'; then
    "$YABAI" -m window --opacity 0.0 || beep   # reset to default (opaque)
else
    "$YABAI" -m window --opacity 0.75 || beep
fi
