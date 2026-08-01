#!/usr/bin/env bash

# set-wallpapers.sh — give each of the 9 spaces its own wallpaper.
#
#   set-wallpapers.sh                  # apply the active set (see ACTIVE_SET)
#   set-wallpapers.sh --set 2001       # apply a specific set
#   set-wallpapers.sh --list           # show the sets and whether they're ready
#   set-wallpapers.sh --set 2001 2     # ...on display 2
#
# ── EDIT HERE ─────────────────────────────────────────────────────────────
# Which set gets applied when no --set is given (this is what ~/.yabairc uses).
ACTIVE_SET="et"

WALLPAPER_DIR="$HOME/Pictures/Wallpapers 2026"

# Sets are defined in load_set() below. Two kinds:
#
#   EXPLICIT — a hand-written list of 9 filenames, in space order. Use when the
#              folder holds more images than you want (the top-level folder has
#              96), so the mapping has to be deliberate.
#
#   GLOB     — take the first 9 files in the subfolder, sorted by name. Use for
#              a folder you fill yourself: prefix the files 01- .. 09- and the
#              sort order becomes the space order. No filenames to maintain here.
#
# MODE is per set, because it depends on the source material:
#   fill — crop to cover the screen. Right when the images match the display
#          ratio (16:9 here).
#   fit  — show the whole frame, pad with black. Right for wider-than-16:9
#          cinema stills; `fill` would crop ~19% off the sides of a 2.20:1 frame.
load_set() {
    case "$1" in
        photos)
            # Landscape picks from the top-level folder, all >= 5120px wide so
            # nothing upscales on the 5120x2880 panel.
            SET_DIR="$WALLPAPER_DIR"
            SET_MODE="fill"
            SET_FILES=(
                "jigar-panchal-1.jpg"                          # 1  Sandbox
                "neom-9bE0LlCrX2M-unsplash.jpg"                # 2  Browsing & Research
                "Dark Layers by Oliur.jpg"                     # 3  Writing & Deep Work
                "pawel-czerwinski-83y-Ud-UHoo-unsplash.jpg"    # 4  Mail, Calendar & Tasks
                "robin-heemstra-Je7esBGb-mA-unsplash.jpg"      # 5  Slack, Notion & Harvest
                "karsten-winegeart-Vg8mpM58jEE-unsplash.jpg"   # 6  Chat & Personal Comms
                "shubham-dhage-urMiLE1Wo8c-unsplash.jpg"       # 7  Coding & Automation
                "mo-xf3o1tBz13o-unsplash.jpg"                  # 8  Music & Movies
                "boliviainteligente-ZPTv34ObQQs-unsplash.jpg"  # 9  Monitoring & Dashboards
            )
            ;;
        2001)
            # 2001 is 2.20:1 Super Panavision, so it letterboxes on a 16:9 panel
            # by design — that is the intended look, not a bug to crop away.
            # Frames from the 4K UHD are 3840x2160 with the picture occupying
            # ~3840x1745, which upscales ~1.33x here. Acceptable; cropping to
            # fill would wreck the one-point-perspective framing.
            SET_DIR="$WALLPAPER_DIR/2001"
            SET_MODE="fit"
            SET_FILES=()   # glob
            ;;
        interstellar)
            # The IMAX sequences are framed 1.78:1 on disc, so they fill a 16:9
            # screen edge to edge with no bars and no cropping. Prefer those
            # shots over the 2.39:1 non-IMAX ones, which would letterbox.
            SET_DIR="$WALLPAPER_DIR/Interstellar"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        tron)
            # 2.20:1, bars baked into the 3840x2160 disc frames — same shape as
            # 2001. From the 2025 4K restoration.
            SET_DIR="$WALLPAPER_DIR/TRON"
            SET_MODE="fit"
            SET_FILES=()   # glob
            ;;
        bladerunner)
            # 2.39:1, bars baked in. The Final Cut, 2017 4K UHD.
            SET_DIR="$WALLPAPER_DIR/Blade Runner"
            SET_MODE="fit"
            SET_FILES=()   # glob
            ;;
        bladerunner2049)
            # 2.4:1, bars baked in. 2018 4K UHD.
            SET_DIR="$WALLPAPER_DIR/Blade Runner 2049"
            SET_MODE="fit"
            SET_FILES=()   # glob
            ;;
        et)
            # TMDB backdrops, full-frame 16:9 with no bars — so `fill` maps them
            # edge to edge, same as the Interstellar set.
            SET_DIR="$WALLPAPER_DIR/ET"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        alien)
            # 2.35:1, bars baked in. 2019 4K UHD.
            # NOTE this is by far the darkest set — most of the 72 source frames
            # are near-black. The nine are deliberately drawn from the brighter,
            # more graphic end (cryo bay, amber panels, MOTHER's terminal).
            SET_DIR="$WALLPAPER_DIR/Alien"
            SET_MODE="fit"
            SET_FILES=()   # glob
            ;;
        moon)
            # 2.40:1, bars baked in. 2019 4K UHD.
            SET_DIR="$WALLPAPER_DIR/Moon"
            SET_MODE="fit"
            SET_FILES=()   # glob
            ;;
        bttf)
            # 1.85:1 — only slightly wider than the screen, so the bars are thin.
            # Still `fit`: cropping the little that overflows would clip framing
            # for no gain.
            SET_DIR="$WALLPAPER_DIR/Back to the Future"
            SET_MODE="fit"
            SET_FILES=()   # glob
            ;;
        ares)
            # 2.39:1, bars baked in. TRON: Ares, 2026 4K UHD.
            SET_DIR="$WALLPAPER_DIR/TRON Ares"
            SET_MODE="fit"
            SET_FILES=()   # glob
            ;;
        arrival)
            # TMDB backdrops, full-frame — `fill`. THIN SET: of 15 images, six
            # are variants of the same key art, so the nine include one poster
            # composition rather than nine distinct frames. No disc-screenshot
            # source exists for this film.
            SET_DIR="$WALLPAPER_DIR/Arrival"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        wargames)
            # TMDB backdrops, full-frame — `fill`.
            # THE ONE SET THAT IS NOT NATIVE RESOLUTION. No disc-screenshot source
            # exists (HighDefDiscNews never covered it) and TMDB has only THREE
            # images at 3840x2160, so six of the nine are ~1920px and upscale
            # ~2.7x on the 5120x2880 panel. Chosen knowingly: the film is a grainy
            # 1983 stock, which hides the softness better than a modern one would.
            SET_DIR="$WALLPAPER_DIR/WarGames"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        avatar)
            # TMDB backdrops, full-frame — `fill`.
            # Asked for as a "nature" set; it isn't really one. TMDB backdrops are
            # marketing selects, so 16 images gave five near-identical Neytiri
            # close-ups and only two true landscapes. The nine lean on what
            # landscape and bioluminescence there is.
            SET_DIR="$WALLPAPER_DIR/Avatar"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        jurassicpark)
            # TMDB backdrops, full-frame — `fill`. Same caveat as avatar: of 11
            # images, four are the same T-rex-in-the-rain setup, so the nine
            # include three from that scene.
            SET_DIR="$WALLPAPER_DIR/Jurassic Park"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        # ── TV shows ──────────────────────────────────────────────────────
        # All four are TMDB backdrops, full-frame 16:9 -> `fill`. TV backdrops
        # skew even harder to key art than film ones do, but for these shows the
        # key art IS the strong material (Severance's balloon head, For All
        # Mankind's Mars vistas), so it is less of a compromise than it sounds.
        severance)
            # Nearly monochrome teal/green by design. The nine differ by
            # composition, not colour — there is very little hue range to use.
            SET_DIR="$WALLPAPER_DIR/Severance"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        formankind)
            # The best-looking TMDB set of the lot: all landscape, no face
            # close-ups. Heavily orange/red, so leans on brightness and
            # composition to stay separable.
            SET_DIR="$WALLPAPER_DIR/For All Mankind"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        silo)
            # Portrait-heavy source (many Rebecca Ferguson key-art variants); the
            # nine favour the architectural shots — the staircase, the corridor,
            # the farm level.
            SET_DIR="$WALLPAPER_DIR/Silo"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        foundation)
            SET_DIR="$WALLPAPER_DIR/Foundation"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        walle)
            # TMDB backdrops, full-frame — `fill`. 20 images at native 4K, and the
            # most varied set of the lot: wide hue range AND wide brightness range,
            # so the nine separate easily.
            SET_DIR="$WALLPAPER_DIR/WALL-E"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        raiders)
            # TMDB backdrops, full-frame — `fill`. 11 at native 4K; two spares.
            SET_DIR="$WALLPAPER_DIR/Raiders of the Lost Ark"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        closeencounters)
            # TMDB backdrops, full-frame — `fill`. EXACTLY nine at native 4K, so
            # every image is in use and there are no spares to swap in. All nine
            # are distinct though, which is rare for a TMDB set.
            SET_DIR="$WALLPAPER_DIR/Close Encounters"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        hollywood)
            # Once Upon a Time in Hollywood. TMDB backdrops, full-frame — `fill`.
            # 20 at native 4K with plenty of genuinely distinct frames, which for
            # a TMDB set is unusual. Widest colour range after WALL-E.
            SET_DIR="$WALLPAPER_DIR/Once Upon a Time in Hollywood"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        *)
            echo "set-wallpapers: unknown set '$1'" >&2
            echo "  try: $SETS_ALL_STATIC" >&2
            return 1
            ;;
    esac
    SETS_ALL="$SETS_ALL_STATIC"
    return 0
}
# Declared outside load_set so the error branch above can name the sets too.
SETS_ALL_STATIC="photos 2001 interstellar tron bladerunner bladerunner2049 et alien moon bttf ares arrival wargames avatar jurassicpark severance formankind silo foundation walle raiders closeencounters hollywood"
# ──────────────────────────────────────────────────────────────────────────
#
# HOW THIS WORKS, AND WHY IT LOOKS CLUMSY
# There is no macOS API that sets the wallpaper of a space you are not on.
# setDesktopImageURL applies to the ACTIVE space, so the only way to dress nine
# spaces is to visit all nine. Expect the screen to flick through them briefly;
# your original space is restored at the end.
#
# That cost is why this is NOT run on every yabai start. ~/.yabairc calls it
# only when reset-spaces.sh reports that it actually created or destroyed
# spaces (exit 10) — a new space is born with the default wallpaper, so that is
# exactly when re-dressing is needed. Run it by hand any time you change sets.
#
# Wallpapers are stored per space in com.apple.wallpaper's Index.plist and
# survive reboots on their own, so there is nothing to re-apply on a normal day.
#
# NOTE the paths must be somewhere permanent. macOS stores the path, not the
# image, and keeps rendering from cache after the file goes missing — which is
# how every space once ended up pointing at a ~/Downloads file that no longer
# existed, looking fine until the cache flushed.

set -uo pipefail

YABAI=/opt/homebrew/bin/yabai
JQ=/opt/homebrew/bin/jq
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETWALL="$HERE/bin/setwall"
WANT=9

# ── arguments ─────────────────────────────────────────────────────────────
CHOSEN="$ACTIVE_SET"
DISPLAY_SEL=1
DO_LIST=0
while [ $# -gt 0 ]; do
    case "$1" in
        --set)  CHOSEN="${2:-}"; shift 2 ;;
        --list) DO_LIST=1; shift ;;
        *)      DISPLAY_SEL="$1"; shift ;;
    esac
done

# Collect a set's 9 files into SET_RESOLVED, whether it is explicit or glob.
# Sorted by name for glob sets, which is why the 01-..09- prefix convention
# matters: sort order IS space order.
resolve_set() {
    load_set "$1" || return 1
    SET_RESOLVED=()
    if [ "${#SET_FILES[@]}" -gt 0 ]; then
        for f in "${SET_FILES[@]}"; do SET_RESOLVED+=("$SET_DIR/$f"); done
    else
        while IFS= read -r f; do
            [ -n "$f" ] && SET_RESOLVED+=("$f")
        done < <(find "$SET_DIR" -maxdepth 1 -type f \
                    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.heic' \) \
                    2>/dev/null | sort | head -"$WANT")
    fi
    return 0
}

# ── --list ────────────────────────────────────────────────────────────────
if [ "$DO_LIST" -eq 1 ]; then
    load_set "$ACTIVE_SET" >/dev/null 2>&1
    for s in $SETS_ALL; do
        resolve_set "$s" >/dev/null 2>&1
        n="${#SET_RESOLVED[@]}"
        mark=" "; [ "$s" = "$ACTIVE_SET" ] && mark="*"
        status="ready"
        [ "$n" -lt "$WANT" ] && status="only $n/$WANT images — drop files in $SET_DIR"
        printf "%s %-14s %-5s %s\n" "$mark" "$s" "$SET_MODE" "$status"
    done
    echo
    echo "* = active (edit ACTIVE_SET at the top of this script to change)"
    exit 0
fi

# ── build the helper ──────────────────────────────────────────────────────
# On first run, or whenever the source is newer. Keeps this dependency-free:
# no Homebrew formula, no build step to remember.
if [ ! -x "$SETWALL" ] || [ "$HERE/setwall.swift" -nt "$SETWALL" ]; then
    mkdir -p "$HERE/bin"
    if ! swiftc -O -o "$SETWALL" "$HERE/setwall.swift"; then
        echo "set-wallpapers: failed to build setwall (Xcode CLT installed?)" >&2
        exit 1
    fi
fi

resolve_set "$CHOSEN" || exit 1

# Validate the WHOLE set before touching anything, so a missing file doesn't
# leave you with half the spaces changed and half not.
if [ "${#SET_RESOLVED[@]}" -lt "$WANT" ]; then
    echo "set-wallpapers: set '$CHOSEN' has only ${#SET_RESOLVED[@]}/$WANT images." >&2
    echo "  Put 9 files in: $SET_DIR" >&2
    echo "  Name them 01-… through 09-… — they are applied in sort order." >&2
    exit 1
fi
missing=0
for f in "${SET_RESOLVED[@]}"; do
    [ -f "$f" ] || { echo "set-wallpapers: missing: $f" >&2; missing=1; }
done
[ "$missing" -eq 1 ] && exit 1

# ── apply ─────────────────────────────────────────────────────────────────
# macOS bash is 3.2, which has no `mapfile`. Do not "simplify" to mapfile
# unless you also change the shebang to a Homebrew bash.
SPACES=()
while read -r line; do
    SPACES+=("$line")
done < <("$YABAI" -m query --spaces --display "$DISPLAY_SEL" 2>/dev/null | "$JQ" -r '.[].index')
[ "${#SPACES[@]}" -eq 0 ] && { echo "set-wallpapers: display $DISPLAY_SEL not found" >&2; exit 1; }

ORIGINAL=$("$YABAI" -m query --spaces --space | "$JQ" -r '.index')

applied=0
for i in "${!SPACES[@]}"; do
    [ "$i" -ge "${#SET_RESOLVED[@]}" ] && break
    idx="${SPACES[$i]}"

    # --focus errors when you are already on that space, which is harmless.
    "$YABAI" -m space --focus "$idx" 2>/dev/null

    # WAIT FOR CONFIRMATION, don't just sleep. The space switch is asynchronous
    # and a fixed sleep is a coin flip: if setwall runs before the switch lands
    # it silently dresses the PREVIOUS space, and you get one space with two
    # wallpapers and one with none. Observed taking >0.7s while testing.
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        [ "$("$YABAI" -m query --spaces --space | "$JQ" -r '.index')" = "$idx" ] && break
        sleep 0.2
    done
    if [ "$("$YABAI" -m query --spaces --space | "$JQ" -r '.index')" != "$idx" ]; then
        echo "set-wallpapers: could not settle on space $idx, skipping" >&2
        continue
    fi

    if "$SETWALL" "${SET_RESOLVED[$i]}" "$SET_MODE"; then
        applied=$((applied + 1))
    else
        echo "set-wallpapers: space $idx failed" >&2
    fi
done

[ "$ORIGINAL" != "$("$YABAI" -m query --spaces --space | "$JQ" -r '.index')" ] &&
    "$YABAI" -m space --focus "$ORIGINAL" 2>/dev/null

echo "set-wallpapers: applied $applied/${#SET_RESOLVED[@]} from '$CHOSEN' ($SET_MODE) on display $DISPLAY_SEL."
