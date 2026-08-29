#!/usr/bin/env bash
# move-window-to-space.sh <target> [follow]
#
#   target : next | prev | first | last | recent | <1-based index>
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

TARGET="${1:?usage: move-window-to-space.sh <next|prev|first|last|recent|N> [follow]}"
FOLLOW="${2:-}"

HS=/opt/homebrew/bin/hs

beep() { osascript -e beep >/dev/null 2>&1 & }

# A beep alone never said WHICH thing went wrong, so a failed move looked
# identical to a mistyped space number. Pair it with an on-screen toast.
#
# There is deliberately no fallback path here. Moving another app's window
# between spaces goes through SkyLight (SLSMoveWindowsToManagedSpace), which
# modern macOS only honours from a process injected into Dock — that is exactly
# what yabai's scripting addition is for. Hammerspoon's hs.spaces.moveWindowToSpace
# returns true and moves nothing (verified on this machine, on ordinary
# AX-visible windows too), so when yabai can't act, nothing else can either.
fail() {
    beep
    "$HS" -A -t 2 -c "require('toast').show([[$1]], { duration = 3 })" >/dev/null 2>&1 &
}

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
    # The space you came from, so the window follows the same toggle as
    # ctrl+tab / ctrl+à. yabai tracks this itself; it is empty right after a
    # restart, when nothing has been "recent" yet.
    recent)
        t=$("$YABAI" -m query --spaces --space recent 2>/dev/null \
            | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["index"])' 2>/dev/null) || t=""
        if [ -z "$t" ]; then
            fail "No recent space to move to yet"
            exit 0
        fi
        ;;
    ''|*[!0-9]*) beep; exit 0 ;;       # not a number and not a keyword
    *)     t=$TARGET ;;
esac

# Out of range -> say so instead of failing silently. This is the common case:
# you have 4 spaces and hit the binding for 7.
if [ "$t" -lt 1 ] || [ "$t" -gt "$count" ]; then
    fail "No space $t — you have $count"
    exit 0
fi

# Moving fails when nothing is focused, when the window is unmanaged (a
# scratchpad, a rule with manage=off), or when yabai holds no Accessibility
# reference for it (the app stopped publishing its AX window list — Safari does
# this). yabai spells that last one "could not locate the window to act on",
# which is worth translating: the fix is to relaunch the app, and nothing about
# the keystroke was wrong.
if ! err=$("$YABAI" -m window --space "$t" 2>&1); then
    # Ask macOS, not yabai, which app is in front: in the AX-dark case yabai has
    # no focused window to report, which is the whole problem.
    app=$("$HS" -A -t 2 -c 'return hs.application.frontmostApplication():name()' 2>/dev/null | tail -1)
    case "$err" in
        *"locate the window"*)
            fail "${app:-This window} is invisible to Accessibility — relaunch it to regain window control" ;;
        *)
            fail "Could not move ${app:-the window} to space $t" ;;
    esac
    exit 0
fi

if [ "$FOLLOW" = "follow" ]; then
    "$YABAI" -m space --focus "$t" 2>/dev/null
    # Then put focus back on the window we just moved. Without this you arrive
    # on the destination space with some unrelated window focused.
    [ -n "$wid" ] && "$YABAI" -m window --focus "$wid" 2>/dev/null
fi
exit 0
