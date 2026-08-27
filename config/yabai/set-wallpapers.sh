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
ACTIVE_SET="severance"

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
#   REPEAT   — SET_REPEAT=1 lets a set with FEWER than 9 images cycle across
#              the spaces (1,2,…,n,1,2,…). For per-episode sets where only a
#              handful of stills exist anywhere. Without it, <9 is an error.
load_set() {
    SET_REPEAT=0
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
        fluted)
            # BasicAppleGuy "Fluted Gradients" (February 2026 edition):
            # basicappleguy.com/basicappleblog/fluted-gradients-february-2026-edition
            # Abstract gradients behind fluted-glass ribbing. Mac downloads are
            # 6016x3900 — LARGER than the panel, so nothing upscales (unique in
            # this roster). 14 existed; the nine picked for maximum hue spread,
            # with two dark frames (08/09) as low-light anchors.
            SET_DIR="$WALLPAPER_DIR/Fluted Gradients Feb 2026"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        september)
            # BasicAppleGuy "Gradients of September" (2025 edition):
            # basicappleguy.com/basicappleblog/gradients-of-september-2025-edition
            # Soft blurred gradients, no texture. Same 6016x3900 Mac size as
            # `fluted` — no upscaling. 16 existed, many in the same sunset
            # family; the nine avoid the near-duplicates and end on the black
            # CMYK frame (09) as the dark anchor.
            SET_DIR="$WALLPAPER_DIR/Gradients September 2025"
            SET_MODE="fill"
            SET_FILES=()   # glob
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
        westworld)
            # TMDB backdrops, full-frame 16:9, all native 3840x2160 — `fill`.
            # 93 backdrops on TMDB but heavy on duplicates (three of the same
            # skull key art, three of the S3 robot-in-desert); the nine are one
            # of each duplicate group plus the best photographic frames. Good
            # split: three graphic key-art pieces, six warm western landscapes.
            SET_DIR="$WALLPAPER_DIR/Westworld"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        devs)
            # TMDB backdrops, full-frame — `fill`. THIN SOURCE: only 13 usable
            # backdrops, 5 native 4K; most of the nine are ~3000px and upscale
            # on the 5120x2880 panel. Palette clusters into forest-green/blue
            # and Devs-lab gold; three frames are face portraits (unavoidable).
            SET_DIR="$WALLPAPER_DIR/Devs"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        snowpiercer)
            # TMDB backdrops, full-frame — `fill`. Every backdrop is character
            # key art — no clean landscapes exist for this show. Overwhelmingly
            # icy blue/teal; only 04 (burning W emblem) breaks the palette.
            # Four of nine are native 4K, the rest 2048px → visible upscale.
            SET_DIR="$WALLPAPER_DIR/Snowpiercer"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        alteredcarbon)
            # TMDB backdrops, full-frame — `fill`. Only 3 native-4K frames
            # existed (2 used); three of the nine are 1080p and upscale hard on
            # the 5120x2880 panel. Palette is heavily teal/green throughout —
            # closest neighbour to the Blade Runner sets in look.
            SET_DIR="$WALLPAPER_DIR/Altered Carbon"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        mandalorian)
            # TMDB backdrops, full-frame — `fill`. The deepest TV pool here:
            # 56 native-4K backdrops, all nine picks 3840x2160 textless. Mando
            # appears in every frame (no pure landscapes among the top-voted),
            # but the vistas behind him carry the variety.
            SET_DIR="$WALLPAPER_DIR/The Mandalorian"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        bebop)
            # Cowboy Bebop (1998 anime series). TMDB backdrops, full-frame —
            # `fill`. Only 3 of 153 backdrops are native 4K; most of the nine
            # are 1920-2560px and upscale ~2x+. Flat-colour anime art hides the
            # softness better than photography would (same logic as wargames).
            SET_DIR="$WALLPAPER_DIR/Cowboy Bebop"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        gits)
            # Ghost in the Shell (1995 film). TMDB backdrops, full-frame —
            # `fill`. 15 native-4K existed; six of the nine are 3840, three are
            # 1920. Heavy teal/cyan palette; the near-white ink-art frame (09)
            # and the dark atrium/rooftop frames anchor the contrast.
            SET_DIR="$WALLPAPER_DIR/Ghost in the Shell"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        akira)
            # Akira (1988). TMDB backdrops, full-frame — `fill`. 12 native-4K
            # but mostly text/logo variants — only 3 textless 4K made the nine;
            # the rest are 1920-2635px. Palette skews strongly red; 04 (cryo
            # chamber) is nearly black and works as the dark-space anchor.
            SET_DIR="$WALLPAPER_DIR/Akira"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        sunshine)
            # Sunshine (2007). TMDB backdrops, full-frame — `fill`. THIN: 5
            # native-4K, only one textless; most of the nine are 1920px and
            # upscale ~2.7x. Palette is dominated by orange/gold by design —
            # the three cool-toned frames (04/05/06) are spaced apart.
            SET_DIR="$WALLPAPER_DIR/Sunshine"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        annihilation)
            # TMDB backdrops, full-frame — `fill`. 37 native-4K, all nine picks
            # 3840x2160. Palette skews green/iridescent-pastel (the Shimmer);
            # three frames share a "figures in vegetation" motif but differ in
            # framing.
            SET_DIR="$WALLPAPER_DIR/Annihilation"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        oblivion)
            # TMDB backdrops, full-frame — `fill`. 13 native-4K but 7 are
            # near-duplicate Cruise promo crops, so only three of the nine are
            # native 4K; the smallest are ~1080p-2160px and soften visibly on
            # the 5120x2880 panel. Palette is desaturated blue-grey/white —
            # the golden Skytower frames (04/05) are the colour outliers.
            SET_DIR="$WALLPAPER_DIR/Oblivion"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        her)
            # Her (2013). TMDB backdrops, full-frame — `fill`. Three of nine
            # native 4K, the rest 2560px (moderate upscale). Nearly every frame
            # contains Theodore — the film offers no people-free frames — so
            # the nine were chosen for maximum colour spread instead:
            # red/teal/blue/gold/dark/grey/multi/black/white.
            SET_DIR="$WALLPAPER_DIR/Her"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        gattaca)
            # TMDB backdrops, full-frame — `fill`. Six of nine native 4K; only
            # ~13 genuinely distinct frames exist on TMDB (many dupes/crops).
            # Palette alternates amber-gold vs teal-green, with one deliberate
            # B&W frame (06, the helix staircase).
            SET_DIR="$WALLPAPER_DIR/Gattaca"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        tales)
            # Tales from the Loop. TMDB backdrops, full-frame — `fill`. Only
            # one native-4K frame; the rest are 1920px upscaled ~2.7x, which
            # the painterly Stålenhag-style art absorbs gracefully (same logic
            # as wargames). All illustrations, no photography; heavy
            # blue/winter bias in three frames.
            SET_DIR="$WALLPAPER_DIR/Tales from the Loop"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        dark)
            # Dark (2017). TMDB backdrops, full-frame — `fill`. Eight of nine
            # native 4K. Palette is deliberately desaturated teal/grey — the
            # spaces distinguish by subject and the few warm accents (red
            # house, lamplit workshop, red bedroom), not by hue.
            SET_DIR="$WALLPAPER_DIR/Dark"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        andor)
            # TMDB backdrops, full-frame — `fill`. All nine native 4K from a
            # 73-strong 4K pool, BUT the textless art is ~6 pieces in many
            # near-duplicate crops — only 7 distinct wide compositions existed,
            # so 08/09 are character close-ups to reach nine.
            SET_DIR="$WALLPAPER_DIR/Andor"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        scavengers)
            # Scavengers Reign. TMDB backdrops, full-frame — `fill`. Only two
            # distinct textless 4K compositions; the other seven are ~1080p
            # upscaled ~2.5x — flat-shaded animation, upscales cleanly. The
            # most saturated and varied palette of any set: excellent
            # space-differentiation.
            SET_DIR="$WALLPAPER_DIR/Scavengers Reign"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        raisedbywolves)
            # TMDB backdrops, full-frame — `fill`. Only SIX distinct frames
            # exist (the other 20 backdrops are crops/logo variants of the same
            # key art), so spaces 7-9 cycle back to frames 1-3 via SET_REPEAT.
            # Palette split between dark teal-grey and golden amber.
            SET_DIR="$WALLPAPER_DIR/Raised by Wolves"
            SET_MODE="fill"
            SET_REPEAT=1
            SET_FILES=()   # glob
            ;;
        threebody)
            # 3 Body Problem. TMDB backdrops, full-frame — `fill`. Four native
            # 4K; the rest 2160-3600px (mild upscale). Good colour spread —
            # orange desert, blue snowfield, gold VR frames, muted 1966 forest.
            SET_DIR="$WALLPAPER_DIR/3 Body Problem"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        bsg)
            # Battlestar Galactica (2004). TMDB backdrops, full-frame — `fill`.
            # ALL backdrops are cast promo art — no textless ship/space frames
            # exist on TMDB at all. Five of the nine are 1080p upscaled ~2.7x
            # (visibly soft). The weakest set technically; kept because the
            # Last Supper tableau and the Six-in-red frames are iconic.
            SET_DIR="$WALLPAPER_DIR/Battlestar Galactica"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        stationeleven)
            # Station Eleven. TMDB backdrops, full-frame — `fill`. Only EIGHT
            # distinct frames exist (21 native-4K backdrops collapse to two
            # compositions plus variants); space 9 cycles back to frame 1 via
            # SET_REPEAT. Two frames are 960p upscaled ~3x. Palette skews
            # muted/pale — the quiet set of the roster.
            SET_DIR="$WALLPAPER_DIR/Station Eleven"
            SET_MODE="fill"
            SET_REPEAT=1
            SET_FILES=()   # glob
            ;;
        contact)
            # Contact (1997). TMDB backdrops, full-frame — `fill`. THIN: the
            # pool is almost entirely faces, so five of nine are face-forward
            # frames, and three are 1280x720 → soft ~4x upscale on the
            # 5120x2880 panel. Heavy blue bias. The VLA night frame (01) is the
            # keeper.
            SET_DIR="$WALLPAPER_DIR/Contact"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        exmachina)
            # Ex Machina. TMDB backdrops, full-frame — `fill`. All nine picks
            # 3840x2160 textless from an 18-strong 4K pool. Strong light/dark
            # and colour variety — one of the cleanest TMDB sets.
            SET_DIR="$WALLPAPER_DIR/Ex Machina"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        solaris)
            # Solaris (1972, Tarkovsky). TMDB backdrops, full-frame — `fill`.
            # Three of nine native 4K; the ocean frame (01) is 1600px and the
            # station corridor (03) 1280px — noticeable upscaling, plus 1972
            # film grain throughout, which hides some of the softness.
            SET_DIR="$WALLPAPER_DIR/Solaris"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        stalker)
            # Stalker (1979, Tarkovsky). TMDB backdrops, full-frame — `fill`.
            # Only one usable native-4K frame; the rest are 1817-2649px and
            # everything upscales. Palette is nearly two-note — sepia/amber vs
            # desaturated green — so spaces distinguish by composition more
            # than colour.
            SET_DIR="$WALLPAPER_DIR/Stalker"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        furyroad)
            # Mad Max: Fury Road. TMDB backdrops, full-frame — `fill`. All nine
            # picks 3840x2160 textless from a 41-strong 4K pool. Dominated by
            # the film's orange/teal grade; the pale-sand frames (02/04/08) are
            # the outliers that keep spaces distinguishable. The loudest set.
            SET_DIR="$WALLPAPER_DIR/Fury Road"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        dune)
            # TMDB backdrops from BOTH parts (2021 movie id 438631 + 2024 id
            # 693134), full-frame 16:9 — `fill`. The deepest TMDB pool of any
            # set: 98 textless 4K backdrops; 28 downloaded, plenty of spares.
            SET_DIR="$WALLPAPER_DIR/Dune"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        matrix)
            # TMDB backdrops, full-frame — `fill`. 22 at 4K for a 1999 film,
            # remaster-fed. The nine favour iconography (code, pills, dojo)
            # over the face-heavy marketing shots.
            SET_DIR="$WALLPAPER_DIR/The Matrix"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        martian)
            # TMDB backdrops, full-frame — `fill`. 12 at 4K, so only three
            # spares — and one of those is a b/w Ridley Scott behind-the-scenes
            # shot, left unused deliberately.
            SET_DIR="$WALLPAPER_DIR/The Martian"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        fallout)
            # TMDB backdrops, full-frame — `fill`. 17 at 4K. Several are
            # variants of the same Vegas-sign and vault-door art; the nine keep
            # one of each.
            SET_DIR="$WALLPAPER_DIR/Fallout"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        expanse)
            # TMDB backdrops, full-frame — `fill`. THE WEAK SET resolution-wise,
            # WarGames-style: only 5 textless backdrops at 4K, the other four
            # are ~3000px and upscale ~1.7x. No spares at all — all nine
            # candidates are in use.
            SET_DIR="$WALLPAPER_DIR/The Expanse"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        blackmirror)
            # TMDB EPISODE STILLS, not show backdrops — full-frame, `fill`.
            # A best-of MIX across episodes: San Junipero (spaces 1-4), Hotel
            # Reverie (5-6), USS Callister, Joan Is Awful, Striking Vipers.
            # For single-episode sets use `sanjunipero` / `hotelreverie`.
            SET_DIR="$WALLPAPER_DIR/Black Mirror"
            SET_MODE="fill"
            SET_FILES=()   # glob
            ;;
        sanjunipero)
            # EVERY San Junipero still that exists on TMDB — all seven. Spaces
            # 1-4 get the 4K frames (convertible, brick wall, Tucker's, beach
            # house); 5-7 are 1400-2048px and upscale visibly (suffix = source
            # width); 8-9 cycle back to frames 1-2 via SET_REPEAT. Gallery
            # sites with 1080p full-episode caps exist (fancaps, thetvshows)
            # but block non-browser scraping, and 1080p wouldn't beat these
            # anyway.
            SET_DIR="$WALLPAPER_DIR/San Junipero"
            SET_MODE="fill"
            SET_REPEAT=1
            SET_FILES=()   # glob
            ;;
        hotelreverie)
            # All four Hotel Reverie stills on TMDB: three b/w in-Reverie
            # frames (3840/3750px) plus one colour Brandy frame at 1920px.
            # Cycles 1-4,1-4,1 across the nine spaces — heavy repetition, but
            # that is everything that exists.
            SET_DIR="$WALLPAPER_DIR/Hotel Reverie"
            SET_MODE="fill"
            SET_REPEAT=1
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
SETS_ALL_STATIC="photos fluted september 2001 interstellar tron bladerunner bladerunner2049 et alien moon bttf ares arrival wargames avatar jurassicpark dune matrix martian severance formankind silo foundation westworld devs snowpiercer alteredcarbon mandalorian bebop gits akira sunshine annihilation oblivion her gattaca tales dark andor scavengers raisedbywolves threebody bsg stationeleven contact exmachina solaris stalker furyroad fallout expanse blackmirror sanjunipero hotelreverie walle raiders closeencounters hollywood"
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
                    ! -name 'zz-*' 2>/dev/null | sort | head -"$WANT")
    fi
    # SET_UNIQUE = distinct images before any cycling; --list reports it.
    SET_UNIQUE="${#SET_RESOLVED[@]}"
    if [ "$SET_REPEAT" -eq 1 ] && [ "$SET_UNIQUE" -gt 0 ]; then
        i=0
        while [ "${#SET_RESOLVED[@]}" -lt "$WANT" ]; do
            SET_RESOLVED+=("${SET_RESOLVED[$i]}")
            i=$(( (i + 1) % SET_UNIQUE ))
        done
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
        if [ "$SET_REPEAT" -eq 1 ] && [ "$SET_UNIQUE" -lt "$WANT" ]; then
            status="ready ($SET_UNIQUE unique, cycled to $WANT)"
        elif [ "$n" -lt "$WANT" ]; then
            status="only $n/$WANT images — drop files in $SET_DIR"
        fi
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
