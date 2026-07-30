#!/usr/bin/env bash
# move-window-to-space.sh <target> [follow]
#
#   target : next | prev | first | last | <1-based index>
#   follow : "follow" to switch to that space too, anything else to stay put
#
# Why a script rather than two chained yabai calls:
#
#   1. WRAPAROUND. `yabai -m window --space next` just errors on the last
#      space. The index is resolved here so next/prev cycle, matching the
#      ctrl+arrow space switching.
#   2. next/prev MUST be resolved BEFORE the move. Chaining
#      `window --space next && space --focus next` moves the window one space
#      and then focuses the space after THAT, because "next" is re-evaluated
#      relative to the still-current space. Resolving to an absolute index
#      first is what makes "take it with me" land on the same space.
#   3. Failure should be audible, not silent — see focus-space.sh.
#
# Requires the scripting addition only for the focus half (instant switching).

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
PY=/usr/bin/python3          # absolute: skhd runs under launchd with a minimal PATH

TARGET="${1:?usage: move-window-to-space.sh <next|prev|first|last|N> [follow]}"
FOLLOW="${2:-}"

beep() { osascript -e beep >/dev/null 2>&1 & }

spaces=$("$YABAI" -m query --spaces 2>/dev/null)   || { beep; exit 0; }
current=$("$YABAI" -m query --spaces --space 2>/dev/null) || { beep; exit 0; }

# Grab the window id BEFORE moving. Sending a window to another space does not
# carry focus with it — after `space --focus` the WindowServer picks whatever
# it likes on the destination, usually the frontmost app there. Re-focusing by
# id afterwards is the only way to land on the window you actually moved, and
# the id has to be captured first because "the focused window" is no longer it.
wid=$("$YABAI" -m query --windows --window 2>/dev/null \
    | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["id"])' 2>/dev/null) || wid=""

count=$(printf '%s' "$spaces"  | "$PY" -c 'import json,sys; print(len(json.load(sys.stdin)))')
cur=$(printf '%s'   "$current" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["index"])')

case "$TARGET" in
    next)  t=$(( cur % count + 1 )) ;;
    prev)  t=$(( (cur - 2 + count) % count + 1 )) ;;
    first) t=1 ;;
    last)  t=$count ;;
    ''|*[!0-9]*) beep; exit 0 ;;       # not a number and not a keyword
    *)     t=$TARGET ;;
esac

# Out of range -> beep instead of failing silently. This is the common case:
# you have 4 spaces and hit the binding for 7.
if [ "$t" -lt 1 ] || [ "$t" -gt "$count" ]; then
    beep
    exit 0
fi

# Moving fails when nothing is focused, or the window is unmanaged (a
# scratchpad, a rule with manage=off). Beep rather than pretend it worked.
if ! "$YABAI" -m window --space "$t" 2>/dev/null; then
    beep
    exit 0
fi

if [ "$FOLLOW" = "follow" ]; then
    "$YABAI" -m space --focus "$t" 2>/dev/null
    # Then put focus back on the window we just moved. Without this you arrive
    # on the destination space with some unrelated window focused.
    [ -n "$wid" ] && "$YABAI" -m window --focus "$wid" 2>/dev/null
fi
exit 0
