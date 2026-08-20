# yabai spaces, apps & wallpapers

Nine labelled spaces, each with its own wallpaper (switchable between themed
sets) and its own set of apps, which open there at login.

## The 30-second version

```sh
$EDITOR ~/.config/yabai/apps.conf               # which app lives on which space
~/.config/yabai/place-apps.sh check             # did I type that right?
yabai --restart-service                         # make it so

~/.config/yabai/set-wallpapers.sh --list        # what sets exist, * = default
~/.config/yabai/set-wallpapers.sh --set moon    # switch right now
```

To make a set the permanent default, edit `ACTIVE_SET` at the top of
`set-wallpapers.sh`. `--set` alone does NOT change it.

## The pieces

| File | Does what |
|---|---|
| `~/.yabairc` | yabai config. Calls `reset-spaces.sh` at the end, `set-wallpapers.sh` only if that reports a change, then `place-apps.sh`. |
| `reset-spaces.sh` | Forces display 1 to exactly 9 spaces and labels them. |
| `apps.conf` | **The one file you edit**: which app goes on which space, which ones open at login. |
| `place-apps.sh` | Machinery for `apps.conf`: adds the yabai rules, launches the apps, nudges stragglers into place. |
| `set-wallpapers.sh` | Applies a wallpaper set. All the set definitions live here. |
| `setwall.swift` | Tiny helper that sets ONE wallpaper. Compiled on demand to `bin/setwall`. |
| `~/Pictures/Wallpapers 2026/` | The images. One subfolder per set. Not in git (~1.8 GB). |

`bin/` is a build artifact — `set-wallpapers.sh` rebuilds it automatically
whenever `setwall.swift` is newer. Safe to delete.

## The space labels

Defined in `reset-spaces.sh` (NOT in `.yabairc`, despite what you might expect):

1. Sandbox
2. Browsing & Research
3. Writing & Deep Work
4. Mail, Calendar & Tasks
5. Slack, Notion & Harvest
6. Chat & Personal Comms
7. Coding & Automation
8. Music & Movies
9. Monitoring & Dashboards

Labels double as identifiers: `yabai -m window --space "Coding & Automation"`.
The window-mode HUD shows the current one top-right.

## Apps per space

All in `apps.conf`, one line per app:

```
# space | launch | app              | bundle id                  | url(s)
2       | yes    | Safari           |                            | https://www.vrt.be/vrtnws/nl/
4       | yes    | Things           | com.culturedcode.ThingsMac
9       | no     | Activity Monitor
```

- **space** `1`-`9` pins the app there: a yabai rule moves every window it ever
  opens to that space, also mid-session. `-` means no rule — launch only.
- **launch** `yes` opens it at login if it isn't running; `no` keeps just the
  rule (you open it yourself, it lands in the right place).
- **app** is the name macOS shows in the Dock, which is not always the `.app`
  filename: Things3 → `Things`, Beeper Desktop → `Beeper`, Visual Studio Code →
  `Code`. When in doubt: `yabai -m query --windows | jq -r '.[].app' | sort -u`.
- **bundle id** is normally looked up from the name; only Things needs it
  spelled out. `check` tells you when a name doesn't resolve.
- **url(s)** open with the app, but only when *this script* launches it — so
  once at login, not on every yabai restart.

Comment a line out to drop the app completely. After editing, run
`~/.config/yabai/place-apps.sh check` — it prints the table as parsed, with
line numbers for anything it rejects — then `yabai --restart-service`.

Current layout:

1. Sandbox — empty on purpose
2. Safari (opens VRT NWS)
3. Obsidian
4. Mimestream, Fantastical, Things
5. Slack, Notion
6. Beeper, Telegram, Ivory, EllyPhone
7. Warp, VS Code
8. Spotify, Infuse, Portal
9. Activity Monitor, PortKiller, Ghostty

### How it runs

`.yabairc` calls `place-apps.sh` twice, after `reset-spaces.sh` (the order
matters — yabai resolves `space=` to a space ID when the rule is added, and
`reset-spaces.sh` may have just created fresh ones):

1. `rules` (foreground, ~100 ms) adds one rule per app, labelled `place:<app>`,
   then `rule --apply` so windows that are already open move too.
2. `launch` (background) opens every `launch=yes` app that isn't running, with
   `open -g` so nothing steals focus. Running apps are skipped, which is why a
   `yabai --restart-service` during the day launches nothing.

Then a **settle pass** (10 s later) mops up the apps yabai didn't place by
itself — see below — and puts focus back on the space you were on.

Useful commands:

```sh
~/.config/yabai/place-apps.sh check                  # validate apps.conf
~/.config/yabai/place-apps.sh launch                 # open what's closed, by hand
yabai -m rule --list | jq '.[] | select(.label | startswith("place:")) | {app, space}'
yabai -m query --windows | jq -r '.[] | "\(.space)\t\(.app)"' | sort -n   # who is where
```

## Swapping an image within a set

The nine in use are the files prefixed `01-` … `09-`. Everything else in the
folder is a spare. **Sort order is space order**, so the prefix decides the space.
Each folder has a `zz-contact-sheet.jpg` showing every frame, numbered, so you
can pick without opening files one by one.

```sh
cd ~/Pictures/Wallpapers\ 2026/Alien
mv 03-corridor-light.png shot-56.png     # demote the current one
mv shot-49.png 03-infirmary.png          # promote the replacement
~/.config/yabai/set-wallpapers.sh        # re-apply
```

## Adding a new set

1. Make `~/Pictures/Wallpapers 2026/<Name>/` and put 9 images in it, named
   `01-…` through `09-…`. (More files are fine — only the first nine by sort
   order are used.)
2. Add a `case` block in `load_set()` in `set-wallpapers.sh`.
3. Append the set name to `SETS_ALL_STATIC`.

The only real decision is `SET_MODE`:

- **`fit`** — the frames are WIDER than 16:9 with black bars baked in. All the
  Blu-ray screenshot sets (2001, Blade Runner, TRON, Alien, Moon, BTTF).
  Shows the whole frame and pads with black.
- **`fill`** — the frames are full-frame 16:9. All the TMDB-sourced sets
  (Interstellar, E.T., Arrival, WarGames, Avatar, Jurassic Park).
  Scales until the screen is covered, cropping the overflow.

Guessing wrong is cosmetic, not fatal: `fill` on a letterboxed image crops the
picture; `fit` on a full-frame image does nothing bad at all.

Check which you have by sampling the top edge — if it's pure black across the
width, the bars are baked in and you want `fit`.

## Things that will confuse you later

**The screen flickers through all nine spaces when applying a set.** Unavoidable.
macOS's `setDesktopImageURL` only affects the space you are *currently on*, and
there is no API to address a space by index. So the script has to visit each one.
Your original space is restored at the end.

**Wallpapers are stored by PATH, not by content.** macOS keeps rendering from
cache after a file goes missing, so a broken set can look fine for weeks and then
go grey. Keep the images somewhere permanent — this already happened once, when
every space pointed at a `~/Downloads` file that had been moved.

**`reset-spaces.sh` exits 10 on purpose.** That means "I created or destroyed
spaces", and it is the signal `.yabairc` uses to decide whether wallpapers need
re-applying (a brand-new space starts on the macOS default). Exit 0 means nothing
structural changed. Don't "fix" the non-zero exit.

**Sets do not need re-applying on a normal day.** macOS persists per-space
wallpapers across reboots by itself.

**Some apps ignore their space rule at login — that's what the settle pass is
for.** Three failure modes, all seen in practice, all handled in `settle()` in
`place-apps.sh`:

- *The window comes back minimised* (Infuse). A window in the Dock belongs to
  no space at all, so nothing can place it. Fix: un-minimise via System Events.
- *yabai hasn't really seen it yet* (Ivory, PortKiller). The window sits on
  the current space with an empty AX role; rules skip it and even
  `yabai -m window --space` says "could not locate the window". Fix: activate
  the app once — the role resolves and the rule fires by itself.
- *yabai cached it as `AXDialog`* (Safari restoring its session). Rules and
  `rule --apply` skip it for good, but `yabai -m window <id> --space` still
  works. Fix: the settle pass moves any of our windows still on the wrong
  space by hand.

The pass only touches apps it launched in that run, so mid-session it does
nothing. If an app is on the wrong space after login, check
`yabai -m query --windows` for its `role`/`subrole`/`is-minimized` first.

**Don't add the same apps to macOS Login Items.** Notion, Warp and Beeper were
removed from there on 2026-08-20 so `apps.conf` is the only owner. Two owners
works, but makes the launch order (and therefore placement) depend on which
one wins the race.

**Source quality varies, and it's recorded per set in the comments.** Three to
know: `wargames` is the only set far off native resolution (six of nine are
~1920px and upscale ~2.7x — no 4K source exists for that film), `expanse` is the
runner-up (four of nine at ~3000px, ~1.7x), and `arrival` includes one poster
rather than a ninth distinct frame.

## Where the images came from

- **Blu-ray screenshots** (frame-accurate, lossless PNG, best quality):
  <https://highdefdiscnews.com/4k-screenshots/> — note the site search is broken
  and returns the same recent posts for any query; navigate the index instead.
  Some galleries are JS-rendered with no URLs in the HTML (this is why Gattaca
  was never built).
- **TMDB backdrops** (fallback when no disc screenshots exist):
  `https://www.themoviedb.org/movie/<id>-<slug>/images/backdrops`, then
  `https://image.tmdb.org/t/p/original/<file>`. Caveat: these are
  marketing-selected, so they skew heavily to faces and key art rather than
  landscapes — which is why the "nature" sets didn't really work out.
- **TV shows** use the same TMDB pattern with `/tv/` instead of `/movie/`:
  `https://www.themoviedb.org/tv/<id>-<slug>/images/backdrops`. Blu-ray
  screenshot sites don't cover TV, so this is the only route. Useful ids:
  Severance 95396, For All Mankind 87917, Silo 125988, Foundation 93740,
  Fallout 106379, The Expanse 63639, Black Mirror 42009.
- **The TMDB website is now JS-rendered** — curl gets an empty grid. Use the
  API instead; `TMDB_API_KEY` is already in the shell environment:
  `https://api.themoviedb.org/3/movie/<id>/images?api_key=$TMDB_API_KEY`, then
  filter `.backdrops[]` on `iso_639_1 == null` (textless) and `width >= 3840`,
  and fetch `https://image.tmdb.org/t/p/original<file_path>`.
- **Per-EPISODE stills** (how the blackmirror set was built):
  `/3/tv/<id>/season/<s>/episode/<e>/images`, key `.stills` instead of
  `.backdrops`. Sparse — an episode typically has 2-8 stills, and famous ones
  are no exception (San Junipero: 7 total, 4 at 4K). Single-episode sets
  therefore use `SET_REPEAT=1` in `load_set()`, which cycles fewer-than-9
  images across the spaces (see `sanjunipero` and `hotelreverie`).
- **Screencap gallery sites are a dead end for automation** (tried 2026-08):
  fancaps.net, thetvshows.us, screencapped.net, kissthemgoodbye, IMDb media
  and the Fandom wikis all block or bot-challenge non-browser fetches, and
  fyscreencaps only offers Mega zip archives. They'd top out at 1080p anyway
  (~2.7x upscale) — grab caps manually through a real browser if a set truly
  needs them.

Only images at exactly 3840x2160 are worth taking — anything smaller upscales
visibly on this panel. Check the count before committing to a set; several films
have plenty of backdrops but only a handful at 4K.
