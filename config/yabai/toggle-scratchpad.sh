#!/usr/bin/env bash
# toggle-scratchpad.sh <label> — claim or release the focused window as a
# scratchpad under <label>.
#
# `yabai -m window --scratchpad <LABEL>` assigns, and calling it with NO value
# releases (doc/yabai.asciidoc:450-456). There is no single "toggle assignment"
# command, so we look at the window's current scratchpad field and pick.
#
# Assigning makes the window floating and unmanaged, and hides it until you
# summon it with `yabai -m window --toggle <LABEL>`. Releasing hands it back to
# normal management.
#
# Requires the scripting addition (scratchpad is SIP-gated).

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
PY=/usr/bin/python3          # absolute: skhd runs under launchd with a minimal PATH
LABEL="${1:-pad}"

beep() { osascript -e beep >/dev/null 2>&1 & }

if ! info=$("$YABAI" -m query --windows --window 2>/dev/null); then
    beep   # nothing focused
    exit 0
fi

current=$(printf '%s' "$info" \
    | "$PY" -c 'import json,sys; print(json.load(sys.stdin).get("scratchpad",""))' 2>/dev/null)

if [ "$current" = "$LABEL" ]; then
    # Release: passing no value clears the assignment.
    "$YABAI" -m window --scratchpad
else
    # Claim. Fails harmlessly if another window already holds this label.
    if ! "$YABAI" -m window --scratchpad "$LABEL" 2>/dev/null; then
        beep
    fi
fi
