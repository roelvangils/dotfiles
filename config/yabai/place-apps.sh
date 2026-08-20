#!/usr/bin/env bash

# place-apps.sh rules|launch|check — give every app a home space, open them at login.
#
# WHICH app goes WHERE is configured in apps.conf, next to this script.
# This file is only the machinery; you should not need to edit it.
#
#   rules   add a yabai rule per app so its windows always land on its space
#           (also mid-session: a new Safari window opened from space 7 goes to
#           space 2), then `rule --apply` to move windows that are already open.
#   launch  open every app marked launch=yes that isn't running, in the
#           background and without stealing focus. Idempotent: running apps
#           are skipped, so a `yabai --restart-service` during the day
#           re-launches nothing. Apps yabai hasn't picked up a few seconds
#           later get nudged into place — see settle() below.
#   check   parse apps.conf and show what would happen, flagging problems
#           (bad columns, names that don't resolve to an app). Run this after
#           editing the config.
#
# Called from ~/.yabairc, AFTER reset-spaces.sh. That order matters: yabai
# resolves `space=` to a space ID at --add time, and reset-spaces.sh may have
# just created fresh spaces with fresh IDs.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
JQ=/opt/homebrew/bin/jq

DISPLAY_SEL=1
CONF="$(cd "$(dirname "$0")" && pwd)/apps.conf"

# Pause between launches so a dozen apps don't all hit the disk at once.
LAUNCH_STAGGER=0.3

# How long to give the launched apps to open their windows before the settle
# pass checks which ones yabai still has not seen.
SETTLE_WAIT=10

# ── config ────────────────────────────────────────────────────────────────

trim() {
    local v="$*"
    v="${v#"${v%%[![:space:]]*}"}"
    v="${v%"${v##*[![:space:]]}"}"
    printf '%s' "$v"
}

# Reads apps.conf and prints one normalised, |-separated line per app (not TAB:
# read collapses consecutive whitespace separators, which would swallow an
# empty bundle column):
#   space  launch  app  bundle  urls
# Bad lines are reported on stderr and skipped; the exit status says whether
# there were any.
parse_conf() {
    local line n=0 bad=0 space launch app bundle urls
    [ -r "$CONF" ] || { echo "place-apps: $CONF not found" >&2; return 1; }
    while IFS= read -r line || [ -n "$line" ]; do
        n=$((n + 1))
        line="${line%%#*}"
        [ -z "$(trim "$line")" ] && continue
        IFS='|' read -r space launch app bundle urls <<< "$line"
        space=$(trim "$space"); launch=$(trim "${launch:-}")
        app=$(trim "${app:-}"); bundle=$(trim "${bundle:-}"); urls=$(trim "${urls:-}")
        if ! [[ "$space" =~ ^([1-9]|-)$ ]]; then
            echo "place-apps: apps.conf:$n: space must be 1-9 or -, got '$space'" >&2
            bad=1; continue
        fi
        if ! [[ "$launch" =~ ^(yes|no)$ ]]; then
            echo "place-apps: apps.conf:$n: launch must be yes or no, got '$launch'" >&2
            bad=1; continue
        fi
        if [ -z "$app" ]; then
            echo "place-apps: apps.conf:$n: missing app name" >&2
            bad=1; continue
        fi
        printf '%s|%s|%s|%s|%s\n' "$space" "$launch" "$app" "$bundle" "$urls"
    done < "$CONF"
    return "$bad"
}

# Bundle id for an app: the configured one, else looked up by name.
bundle_for() {
    local app="$1" bundle="$2"
    [ -n "$bundle" ] && { printf '%s' "$bundle"; return 0; }
    osascript -e "id of app \"$app\"" 2>/dev/null
}

# Anchored regex that matches exactly this app name (yabai rules take regexes).
regex_for() {
    printf '^%s$' "$(printf '%s' "$1" | sed 's/[][\.*^$+?(){}|\\]/\\&/g')"
}

# ── yabai helpers ─────────────────────────────────────────────────────────

# Space indices on the target display, in order. Same trick as reset-spaces.sh:
# work by POSITION on the display, because with a second display attached the
# absolute indices are offset and "space 2" would be the wrong screen.
spaces_on_display() {
    "$YABAI" -m query --spaces --display "$DISPLAY_SEL" 2>/dev/null |
        "$JQ" -r '.[].index'
}

# Position (1-based) -> absolute space index, or empty if the display is short.
index_for_position() {
    spaces_on_display | sed -n "${1}p"
}

is_running() {
    [ -n "$(lsappinfo find "bundleid=$1" 2>/dev/null)" ]
}

# Does yabai know at least one USABLE window for this app? A window with an
# empty role (AX wasn't ready when yabai first saw it) doesn't count: rules
# skip it and `window --space` can't even locate it — only activation fixes it.
yabai_sees() {
    "$YABAI" -m query --windows 2>/dev/null |
        "$JQ" -e --arg a "$1" 'any(.[]; .app == $a and .role != "")' >/dev/null
}

# ── rules ─────────────────────────────────────────────────────────────────

do_rules() {
    local added=0 skipped=0 space launch app bundle urls idx
    while IFS='|' read -r space launch app bundle urls; do
        [ "$space" = "-" ] && continue
        idx=$(index_for_position "$space")
        if [ -z "$idx" ]; then
            echo "place-apps: no space at position $space for $app — skipped" >&2
            skipped=$((skipped + 1))
            continue
        fi
        # The label lets you see/remove these as a group: yabai -m rule --list
        if "$YABAI" -m rule --add label="place:$app" app="$(regex_for "$app")" space="$idx"; then
            added=$((added + 1))
        else
            echo "place-apps: rule for $app failed" >&2
            skipped=$((skipped + 1))
        fi
    done < <(parse_conf)
    # Move windows that are already open (yabai restart mid-session) into place.
    "$YABAI" -m rule --apply 2>/dev/null
    echo "place-apps: $added rules added, $skipped skipped."
}

# ── launch ────────────────────────────────────────────────────────────────

do_launch() {
    local launched=0 running=0 space launch app bundle urls id
    local just_launched=()
    while IFS='|' read -r space launch app bundle urls; do
        [ "$launch" = "yes" ] || continue
        id=$(bundle_for "$app" "$bundle")
        if [ -z "$id" ]; then
            echo "place-apps: can't find an app called '$app' — add its bundle id in apps.conf" >&2
            continue
        fi
        if is_running "$id"; then
            running=$((running + 1))
            continue
        fi
        # -g: don't bring it to the foreground; the rule decides where it goes.
        # $urls deliberately unquoted: zero or more space-separated URLs.
        # shellcheck disable=SC2086
        if open -g -b "$id" $urls 2>/dev/null; then
            launched=$((launched + 1))
            just_launched+=("$space|$app|$id")
            sleep "$LAUNCH_STAGGER"
        else
            echo "place-apps: could not open $app ($id)" >&2
        fi
    done < <(parse_conf)
    echo "place-apps: $launched launched, $running already running."
    [ "$launched" -gt 0 ] && settle "${just_launched[@]}"
}

# Three ways an app launched with -g ends up outside its space rule:
#   * its window comes back MINIMIZED (Infuse does this) — a window in the Dock
#     belongs to no space at all, for yabai and for macOS alike;
#   * yabai never picks it up until it has been frontmost once (Ivory,
#     PortKiller): the window sits on the current space with an empty AX role,
#     rules skip it and `window --space` can't even locate it;
#   * yabai samples the AX role once, at creation, and if the app wasn't ready
#     the window is cached as AXDialog (Safari restoring its session) — rules
#     and `rule --apply` skip it for good, but `window --space` still works.
# So after the launches settle: every app we started that yabai still has no
# usable window for gets un-minimized and activated — once; then
# `rule --apply`; then anything of ours still on the wrong space is moved by
# hand. Focus goes back where it was. At login this is a brief flicker at
# most; mid-session it never runs because nothing gets launched.
settle() {
    local entry space app id start_space idx moved=0
    sleep "$SETTLE_WAIT"
    start_space=$("$YABAI" -m query --spaces --space 2>/dev/null | "$JQ" -r '.index')
    for entry in "$@"; do
        IFS='|' read -r space app id <<< "$entry"
        yabai_sees "$app" && continue
        osascript \
            -e "tell application \"System Events\" to tell (first process whose bundle identifier is \"$id\")" \
            -e "    set value of attribute \"AXMinimized\" of every window to false" \
            -e "end tell" >/dev/null 2>&1
        osascript -e "tell application id \"$id\" to activate" >/dev/null 2>&1
        sleep 1
    done
    "$YABAI" -m rule --apply 2>/dev/null
    for entry in "$@"; do
        IFS='|' read -r space app id <<< "$entry"
        [ "$space" = "-" ] && continue
        idx=$(index_for_position "$space")
        [ -z "$idx" ] && continue
        while read -r wid; do
            [ -z "$wid" ] && continue
            "$YABAI" -m window "$wid" --space "$idx" 2>/dev/null && moved=$((moved + 1))
        done < <("$YABAI" -m query --windows 2>/dev/null |
            "$JQ" -r --arg a "$app" --argjson s "$idx" \
                '.[] | select(.app == $a and .space != $s and ."is-minimized" == false) | .id')
    done
    [ "$moved" -gt 0 ] && echo "place-apps: moved $moved stray window(s) by hand."
    [ -n "$start_space" ] && "$YABAI" -m space --focus "$start_space" 2>/dev/null
}

# ── check ─────────────────────────────────────────────────────────────────

do_check() {
    local space launch app bundle urls id problems=0 parsed
    parsed=$(parse_conf) || problems=1
    echo "place-apps: $CONF"
    printf '%-5s %-6s %-18s %-34s %s\n' SPACE LAUNCH APP "BUNDLE ID" URLS
    while IFS='|' read -r space launch app bundle urls; do
        [ -z "$app" ] && continue
        id=$(bundle_for "$app" "$bundle")
        if [ -z "$id" ]; then
            id="?? not found — add the bundle id"
            problems=1
        elif [ -z "$bundle" ]; then
            id="$id (looked up)"
        fi
        printf '%-5s %-6s %-18s %-34s %s\n' "$space" "$launch" "$app" "$id" "$urls"
    done <<< "$parsed"
    if [ "$problems" -eq 0 ]; then
        echo "place-apps: config OK."
    else
        echo "place-apps: config has problems (see above)." >&2
        return 1
    fi
}

# ── main ──────────────────────────────────────────────────────────────────

case "${1:-}" in
    rules)  do_rules ;;
    launch) do_launch ;;
    check)  do_check ;;
    *)
        echo "usage: place-apps.sh rules|launch|check" >&2
        exit 2
        ;;
esac
