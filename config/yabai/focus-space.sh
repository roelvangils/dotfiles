#!/usr/bin/env bash
# focus-space.sh <space-index> — focus a yabai space, beep if it doesn't exist.
#
# Called from ~/.skhdrc. Exists so the "space not found" feedback is defined in
# ONE place rather than duplicated across every ctrl+<top row> binding.
#
# The beep uses the macOS system alert sound (yours is currently Tink), so it
# follows System Settings > Sound > Alert sound and respects the alert volume
# slider — including staying silent if you've muted alerts.
#
# If you'd rather have a fixed sound that ignores those settings, swap the
# osascript line for something like:
#     afplay /System/Library/Sounds/Basso.aiff &
# Basso is the conventional macOS "that didn't work" sound. afplay is also a
# touch faster, since osascript costs ~100ms of interpreter startup.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai

# stderr is discarded: yabai prints "could not locate the space" and we are
# deliberately replacing that message with the beep.
if ! "$YABAI" -m space --focus "$1" 2>/dev/null; then
    osascript -e beep >/dev/null 2>&1 &
fi
