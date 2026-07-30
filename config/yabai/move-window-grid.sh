#!/usr/bin/env bash
# move-window-grid.sh <dir> [step]
#
#   dir  : up | down | left | right | ul | ur | dl | dr | center
#   step : pixels to nudge (default 50)
#
# Nudges the focused window. The moves are issued with window_animation_duration
# forced to 0 (restored afterwards): yabai's animated --move spawns an animation
# proxy for the window, and that proxy is what makes the drop shadow flicker
# during the move. An instant move has no proxy, so the shadow stays put. The
# arrow keys get their own smooth sliding in Hammerspoon (Accessibility API);
# this script handles the discrete numpad grid (diagonals + centre).
#
# Only floating windows can be positioned freely; on a managed (tiled) window
# yabai just errors and we stay quiet (2>/dev/null), same as the other scripts.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
PY=/usr/bin/python3          # absolute: skhd runs under launchd with a minimal PATH

DIR="${1:?usage: move-window-grid.sh <up|down|left|right|ul|ur|dl|dr|center> [step]}"
STEP="${2:-50}"

# Force instant moves (no animation proxy -> no shadow flicker), restore after.
anim=$("$YABAI" -m config window_animation_duration 2>/dev/null)
"$YABAI" -m config window_animation_duration 0.0 2>/dev/null
restore() { "$YABAI" -m config window_animation_duration "${anim:-0.15}" 2>/dev/null; }
trap restore EXIT

case "$DIR" in
    up)     "$YABAI" -m window --move "rel:0:-$STEP" 2>/dev/null ;;
    down)   "$YABAI" -m window --move "rel:0:$STEP"  2>/dev/null ;;
    left)   "$YABAI" -m window --move "rel:-$STEP:0" 2>/dev/null ;;
    right)  "$YABAI" -m window --move "rel:$STEP:0"  2>/dev/null ;;
    ul)     "$YABAI" -m window --move "rel:-$STEP:-$STEP" 2>/dev/null ;;
    ur)     "$YABAI" -m window --move "rel:$STEP:-$STEP"  2>/dev/null ;;
    dl)     "$YABAI" -m window --move "rel:-$STEP:$STEP"  2>/dev/null ;;
    dr)     "$YABAI" -m window --move "rel:$STEP:$STEP"   2>/dev/null ;;
    center)
        # No native "center"; compute display-centre from the window and display
        # frames, then move there. abs move can't touch a managed window, so this
        # too is a floating-only operation and stays quiet otherwise.
        "$YABAI" -m query --windows --window 2>/dev/null | "$PY" - "$YABAI" <<'PYEOF'
import json, subprocess, sys
w = json.load(sys.stdin)
yabai = sys.argv[1]
d = subprocess.run([yabai, "-m", "query", "--displays", "--display"],
                   capture_output=True, text=True).stdout
df, wf = json.loads(d)["frame"], w["frame"]
x = df["x"] + (df["w"] - wf["w"]) / 2
y = df["y"] + (df["h"] - wf["h"]) / 2
subprocess.run([yabai, "-m", "window", "--move", "abs:%.0f:%.0f" % (x, y)],
               capture_output=True)
PYEOF
        ;;
    *) exit 0 ;;
esac
