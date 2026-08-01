# yabai spaces & wallpapers

Nine labelled spaces, each with its own wallpaper, switchable between themed sets.

## The 30-second version

```sh
~/.config/yabai/set-wallpapers.sh --list        # what sets exist, * = default
~/.config/yabai/set-wallpapers.sh --set moon    # switch right now
```

To make a set the permanent default, edit `ACTIVE_SET` at the top of
`set-wallpapers.sh`. `--set` alone does NOT change it.

## The pieces

| File | Does what |
|---|---|
| `~/.yabairc` | yabai config. Calls `reset-spaces.sh` at the end, and `set-wallpapers.sh` only if that reports a change. |
| `reset-spaces.sh` | Forces display 1 to exactly 9 spaces and labels them. |
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

**Source quality varies, and it's recorded per set in the comments.** Two to know:
`wargames` is the only set that is not native resolution (six of nine are ~1920px
and upscale ~2.7x — no 4K source exists for that film), and `arrival` includes one
poster rather than a ninth distinct frame.

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
  Severance 95396, For All Mankind 87917, Silo 125988, Foundation 93740.

Only images at exactly 3840x2160 are worth taking — anything smaller upscales
visibly on this panel. Check the count before committing to a set; several films
have plenty of backdrops but only a handful at 4K.
