#!/usr/bin/env bash
# toggle-layout.sh — flip the CURRENT space between bsp (tiled) and float,
# remembering the floating window arrangement so it comes back intact.
#
#   float -> bsp   snapshot every window's frame on this space, then tile
#   bsp   -> float untile, then restore each window to its saved frame
#
# yabai has no built-in "restore previous layout": once bsp tiles the windows,
# the original positions are gone. So we save them ourselves, keyed on the
# SPACE ID (not the index, which shifts when spaces are reordered; and not the
# uuid, which is empty on the macOS 27 beta).
#
# Order matters on restore: `--resize abs:` "cannot be used on managed windows"
# (doc/yabai.asciidoc:418), so the space must be set to float BEFORE we move
# anything back.
#
# Snapshots live in ~/.local/state/yabai/space-<id>.json and are overwritten on
# each float->bsp transition, so they always reflect the most recent floating
# arrangement. Deleting them is harmless — you just lose the restore.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
SKHD=/opt/homebrew/bin/skhd  # absolute: skhd runs under launchd with a minimal PATH
PY=/usr/bin/python3          # absolute: skhd runs under launchd with a minimal PATH
STATE_DIR="$HOME/.local/state/yabai"

beep() { osascript -e beep >/dev/null 2>&1 & }

space=$("$YABAI" -m query --spaces --space 2>/dev/null) || { beep; exit 0; }

space_id=$(printf '%s' "$space" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["id"])' 2>/dev/null)
layout=$(printf '%s' "$space"  | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["type"])'  2>/dev/null)
[ -n "$space_id" ] || { beep; exit 0; }

snapshot="$STATE_DIR/space-$space_id.json"

if [ "$layout" = "bsp" ]; then
    # ---- bsp -> float: untile first, then put windows back ----
    "$YABAI" -m space --layout float

    if [ -f "$snapshot" ]; then
        # Restore instantly. window_animation_duration animates every
        # --move/--resize, so replaying a whole saved layout at once turns that
        # into a jarring cascade. Snap the duration to 0 for the restore, then
        # put the user's value back so ordinary window animation is unaffected.
        # (Beats fading opacity to 0 and back: no flicker, and the windows never
        # visibly travel at all.)
        anim=$("$YABAI" -m config window_animation_duration 2>/dev/null)
        "$YABAI" -m config window_animation_duration 0.0  # yabai rejects integer 0

        "$PY" - "$snapshot" "$YABAI" <<'PYEOF'
import json, subprocess, sys

snapshot, yabai = sys.argv[1], sys.argv[2]
try:
    saved = json.load(open(snapshot))
except (OSError, ValueError):
    sys.exit(0)

def run(*args):
    # Windows may have been closed or moved to another space since the
    # snapshot; yabai just errors and we skip them.
    subprocess.run([yabai, "-m", "window", *args], capture_output=True)

# Current frames, so we can skip windows that are already where they belong.
# This is what stops hidden windows from flashing on screen: bsp never moved
# them, so re-applying their saved frame is a no-op that costs a visible flash.
try:
    now = subprocess.run([yabai, "-m", "query", "--windows", "--space"],
                         capture_output=True, text=True).stdout
    current = {w["id"]: w["frame"] for w in json.loads(now)}
except (ValueError, KeyError):
    current = {}

for w in saved:
    wid, f = str(w["id"]), w["frame"]

    have = current.get(w["id"])
    if have is None:
        continue  # closed, or moved to another space
    if all(abs(have[k] - f[k]) < 1 for k in ("x", "y", "w", "h")):
        continue  # already correct — don't touch it
    # RESIZE BEFORE MOVE, deliberately. macOS clamps a resize to the screen
    # edge, so a window whose saved frame overhangs the right/bottom edge
    # (e.g. x=143 w=1447 on a 1512px display) would come back 78px narrower
    # if we moved it into place first. Sizing it while it still sits at the
    # tiled origin avoids the clamp; the subsequent move is not clamped.
    run(wid, "--resize", "abs:{:.0f}:{:.0f}".format(f["w"], f["h"]))
    run(wid, "--move",   "abs:{:.0f}:{:.0f}".format(f["x"], f["y"]))
PYEOF

        # Put the user's animation setting back (fall back to yabai's default if
        # the query above returned nothing).
        "$YABAI" -m config window_animation_duration "${anim:-0.15}"
    fi

    # Restoring to float ends the interaction, so leave window mode -- this is
    # what dismisses the HUD. (Entering bsp, below, deliberately does NOT: the
    # HUD stays up so the fresh layout can be tuned immediately.)
    "$SKHD" -k "escape"

else
    # ---- float -> bsp: snapshot, then tile. Deliberately does NOT leave window
    # mode: the HUD stays up so you can immediately tune the new layout with
    # swap / rotate / balance, then press a leave key when done. ----
    mkdir -p "$STATE_DIR"
    if "$YABAI" -m query --windows --space 2>/dev/null | "$PY" -c '
import json, sys
try:
    windows = json.load(sys.stdin)
except ValueError:
    sys.exit(1)
# Only windows that are actually on screen.
#   is-minimized -> no meaningful frame to restore
#   is-visible false -> app is hidden (cmd-H) or the window sits on another
#     space. bsp never tiles these, so they need no restoring, and moving one
#     makes macOS briefly flash it on screen.
json.dump(
    [{"id": w["id"], "frame": w["frame"]}
     for w in windows
     if not w.get("is-minimized") and w.get("is-visible")],
    sys.stdout,
)
' > "$snapshot.tmp" 2>/dev/null; then
        mv "$snapshot.tmp" "$snapshot"
    else
        rm -f "$snapshot.tmp"
    fi
    "$YABAI" -m space --layout bsp
fi
