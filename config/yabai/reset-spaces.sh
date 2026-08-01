#!/usr/bin/env bash

# reset-spaces.sh — force the primary display to exactly 9 labelled spaces.
#
# Called from ~/.yabairc on every yabai start. Safe to run by hand at any time.
#
# WHY CONVERGE INSTEAD OF "DESTROY ALL, THEN CREATE 9"
# yabai refuses to destroy a display's LAST space (there is no such thing as a
# display with zero spaces), so a literal wipe is impossible. This adds the
# missing spaces or removes the surplus ones instead, which lands on the same
# end state and — importantly — is a no-op when the count is already right, so
# a yabai restart mid-session doesn't churn your desktop.
#
# Destroying a space does NOT close its windows: macOS migrates them to the
# neighbouring space. You may have to redistribute them afterwards.
#
# Requires the scripting addition (space --create/--destroy go through it).

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
JQ=/opt/homebrew/bin/jq

# Which display to normalise, and how many spaces it should end up with.
# Other displays are left completely alone.
DISPLAY_SEL="${1:-1}"
WANT=9

LABELS=(
    "Sandbox"
    "Browsing & Research"
    "Writing & Deep Work"
    "Mail, Calendar & Tasks"
    "Slack, Notion & Harvest"
    "Chat & Personal Comms"
    "Coding & Automation"
    "Music & Movies"
    "Monitoring & Dashboards"
)

# Space indices on the target display, in order. Native-fullscreen spaces are
# included here because they still occupy an index and still need a label.
spaces_on_display() {
    "$YABAI" -m query --spaces --display "$DISPLAY_SEL" 2>/dev/null |
        "$JQ" -r '.[].index'
}

# Destroyable = everything except native-fullscreen spaces, which yabai cannot
# remove while the app is in fullscreen. Highest index first, so destroying one
# never shifts the index of another we still intend to destroy.
destroyable_desc() {
    "$YABAI" -m query --spaces --display "$DISPLAY_SEL" 2>/dev/null |
        "$JQ" -r '[.[] | select(."is-native-fullscreen" == false) | .index] | sort | reverse | .[]'
}

count() { spaces_on_display | grep -c . ; }

have=$(count)
[ "$have" -eq 0 ] && { echo "reset-spaces: display $DISPLAY_SEL not found" >&2; exit 1; }

# Tracks whether the space LAYOUT changed, as opposed to labels being re-applied.
# Reported as exit 10 at the bottom; ~/.yabairc keys wallpaper re-application off
# it, because a freshly created space starts on the default wallpaper.
changed=0

# ── grow ──────────────────────────────────────────────────────────────────
while [ "$have" -lt "$WANT" ]; do
    "$YABAI" -m space --create "$DISPLAY_SEL" || {
        echo "reset-spaces: --create failed (scripting addition loaded?)" >&2
        break
    }
    changed=1
    sleep 0.15   # the SA creates asynchronously; querying too soon under-counts
    have=$(count)
done

# ── shrink ────────────────────────────────────────────────────────────────
if [ "$have" -gt "$WANT" ]; then
    while read -r idx; do
        [ "$have" -le "$WANT" ] && break
        "$YABAI" -m space --destroy "$idx" 2>/dev/null || continue
        changed=1
        sleep 0.15
        have=$(count)
    done < <(destroyable_desc)
fi

[ "$have" -ne "$WANT" ] &&
    echo "reset-spaces: wanted $WANT spaces, settled on $have (native-fullscreen spaces can't be destroyed)" >&2

# ── label ─────────────────────────────────────────────────────────────────
# By POSITION on the display, not by absolute index: with a second display
# attached the indices are offset, and labelling `space 1` would hit the wrong
# screen. Labels are re-applied every run so renames here take effect on reload.
i=0
while read -r idx; do
    [ "$i" -ge "${#LABELS[@]}" ] && break
    "$YABAI" -m space "$idx" --label "${LABELS[$i]}" 2>/dev/null
    i=$((i + 1))
done < <(spaces_on_display)

echo "reset-spaces: display $DISPLAY_SEL has $have spaces, $i labelled."

# Exit 10 = "the layout changed", the signal ~/.yabairc uses to decide whether
# wallpapers need re-applying. 0 = nothing structural happened (the common case,
# and the reason a yabai restart mid-session does not flicker through 9 spaces).
[ "$changed" -eq 1 ] && exit 10
exit 0
