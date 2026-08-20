#!/usr/bin/env bash
# reset-overrides.sh — walk EVERY window and undo the per-window overrides the
# window-mode toggles can leave behind: opacity (o), missing shadow (d), and
# sub-layer above/below (t). Sticky and the scratchpad label are deliberately
# left alone: those are placements you chose, not cosmetic state you forget.
#
# Ends with a toast saying how many windows were touched, so "nothing happened"
# and "there was nothing to reset" look different.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
PY=/usr/bin/python3          # absolute: skhd runs under launchd with a minimal PATH
HS=/opt/homebrew/bin/hs

wins=$("$YABAI" -m query --windows 2>/dev/null) || { osascript -e beep >/dev/null 2>&1 & exit 0; }

count=$(printf '%s' "$wins" | "$PY" - "$YABAI" <<'PYEOF'
import json, subprocess, sys

yabai = sys.argv[1]
try:
    windows = json.load(sys.stdin)
except ValueError:
    print(0)
    sys.exit(0)

def run(wid, *args):
    subprocess.run([yabai, "-m", "window", str(wid), *args], capture_output=True)

touched = 0
for w in windows:
    dirty = False
    op = w.get("opacity", 1.0)
    if 0 < op < 0.999:
        run(w["id"], "--opacity", "0.0")   # 0.0 clears the override
        dirty = True
    if w.get("has-shadow") is False:
        run(w["id"], "--toggle", "shadow")
        dirty = True
    if w.get("sub-layer") in ("above", "below"):
        run(w["id"], "--sub-layer", "auto")
        dirty = True
    if dirty:
        touched += 1
print(touched)
PYEOF
)

"$HS" -A -t 2 -c "require('toast').show([[Reset overrides on ${count:-0} window(s)]], { duration = 2 })" >/dev/null 2>&1 &
