#!/bin/zsh
# Keep the LG ULTRAGEAR+ volume working through BetterDisplay updates/resets.
#
# Background: BetterDisplay shipped with the volume value range set to 1-10, so the
# whole 0-100% slider drove only the bottom sliver of the monitor's DDC range and the
# keyboard volume keys could never reach full. The monitor's real range is 0-100.
# DDC *reads* fail on this Mac (normal for LG panels on Apple Silicon), so the range
# cannot be auto-detected, and periodic polling must stay off or it re-applies a
# stale value mid-adjustment.
#
# Two failure modes are covered:
#   1. The value range / polling prefs drift (reinstall, settings reset, schema
#      migration, or the display re-enumerating under a new tag ID).
#   2. BetterDisplay simply isn't running - nothing then intercepts the volume keys.
#
# Idempotent and silent when all is well. Only quits/relaunches BetterDisplay when
# something actually needs repairing.
#
# Set ENSURE_RUNNING=0 below if you'd rather it never launch the app for you.
# The BDG_* env vars exist so the repair path can be tested against a throwaway
# prefs domain without touching the real BetterDisplay settings.

set -u

DOMAIN=${BDG_DOMAIN:-pro.betterdisplay.BetterDisplay}
NAME=${BDG_NAME:-LG ULTRAGEAR+}
LOW=${BDG_LOW:-0}
HIGH=${BDG_HIGH:-100}
ENSURE_RUNNING=${BDG_ENSURE_RUNNING:-1}
BIN=/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay
CACHE="$HOME/.cache/bd-volume-guard.tag"
LOG="$HOME/Library/Logs/bd-volume-guard.log"

log() { print -r -- "$(date '+%Y-%m-%d %H:%M:%S') $*" >>"$LOG" }

[[ -x "$BIN" || -n ${BDG_DOMAIN:-} ]] || { log "BetterDisplay not installed - nothing to do"; exit 0 }

# Failure mode 2: the app isn't running, so the volume keys are dead.
if (( ENSURE_RUNNING )) && [[ -z ${BDG_DOMAIN:-} ]] && ! pgrep -x BetterDisplay >/dev/null; then
  log "BetterDisplay was not running - launching it"
  open -a BetterDisplay
  for _ in {1..20}; do pgrep -x BetterDisplay >/dev/null && break; sleep 0.5; done
  sleep 2
fi

# Resolve the display's tagID by name. Only readable while the app is running, so
# cache it for the case where we must repair while it's down.
tag=${BDG_TAG:-}
if [[ -z "$tag" ]] && pgrep -x BetterDisplay >/dev/null; then
  ids=$("$BIN" get -identifiers 2>/dev/null)
  [[ -n "$ids" ]] && tag=$(printf '[%s]' "$ids" \
      | jq -r --arg n "$NAME" '.[]? | select(.name==$n) | .tagID' 2>/dev/null | head -1)
fi
if [[ -n "$tag" ]]; then
  print -r -- "$tag" >"$CACHE"
elif [[ -r "$CACHE" ]]; then
  tag=$(<"$CACHE")
fi
[[ -n "$tag" ]] || { log "could not resolve tagID for '$NAME' - skipping"; exit 0 }

typeset -A want
want[lowValue@volume-DDCController@Display:$tag]=$LOW
want[highValue@volume-DDCController@Display:$tag]=$HIGH
want[periodicUpdate@volume-DDCController@Display:$tag]=0
want[periodicUpdate@mute-DDCController@Display:$tag]=0

drift=()
for key val in ${(kv)want}; do
  cur=$(defaults read "$DOMAIN" "$key" 2>/dev/null)
  [[ "$cur" == "$val" ]] || drift+=("$key: ${cur:-<unset>} -> $val")
done
(( ${#drift} )) || exit 0

log "drift on Display:$tag -> ${(j:, :)drift}"

# BetterDisplay rewrites its plist on quit, so it must be down before we write.
was_running=0
if [[ -z ${BDG_DOMAIN:-} ]] && pgrep -x BetterDisplay >/dev/null; then
  was_running=1
  osascript -e 'tell application "BetterDisplay" to quit' >/dev/null 2>&1
  for _ in {1..20}; do pgrep -x BetterDisplay >/dev/null || break; sleep 0.5; done
  if pgrep -x BetterDisplay >/dev/null; then
    log "BetterDisplay would not quit - leaving it alone rather than losing the write"
    exit 1
  fi
fi

for key val in ${(kv)want}; do
  defaults write "$DOMAIN" "$key" -int "$val"
done
log "repaired Display:$tag (range $LOW-$HIGH, polling off)"

(( was_running )) && open -a BetterDisplay
exit 0
