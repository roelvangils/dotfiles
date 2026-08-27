# Dotfiles

Shell, git, window-management and tool configuration for my macOS
machines. Public, so others can read along — I have learned plenty from
other people's dotfiles.

No API keys or other secrets live here. Those sit in `~/.secrets`, which
is sourced by `.zshrc` and excluded by `.gitignore`.

## Contents

| Path | Purpose |
|---|---|
| `.zshrc` | Interactive shell: plugins, prompt, aliases, functions |
| `.zshenv` | Environment variables and `PATH`. Loaded by every zsh |
| `.zsh_plugins.txt` | Plugin list for [antidote](https://github.com/mattmc3/antidote) |
| `.gitconfig` | Git settings, with a conditional personal identity |
| `.gitconfig-personal` | Email used for repositories under `~/repos` |
| `.gitignore-global` | Ignore rules applied to every repository, credentials included |
| `.skhdrc` | skhd hotkeys for yabai window management |
| `.yabairc` | yabai tiling window manager |
| `.secrets.template` | Placeholder for `~/.secrets`; the real file stays untracked |
| `Brewfile` | Everything Homebrew installs on this machine |
| `config/` | Per-tool directories, each symlinked to `~/.config/<name>` |
| `macos/` | System keyboard shortcuts, exported and restorable |
| `bin/` | Scripts with no repo of their own, linked into `~/.local/bin` |
| `bin/links.tsv` | Commands that live in another repo: the pointer, never the code |
| `install.sh` | Symlinks all of the above into place |

## Setup on a new machine

```sh
git clone https://github.com/roelvangils/dotfiles.git ~/repos/dotfiles
~/repos/dotfiles/install.sh    # symlinks; never overwrites existing files
brew bundle --file=~/repos/dotfiles/Brewfile
```

On a machine driven over SSH there is no display for yabai, skhd or
sketchybar to draw on, so link the shell half only:

```sh
~/repos/dotfiles/install.sh --headless
```

Then fill in `~/.secrets` (created from the template by the installer).
Open a new shell: antidote fetches the plugins on first run, which takes
a second or two; every start after that is under 100 ms.

Not covered by `brew bundle`: **yabai** is installed manually and blessed
via a hash-pinned sudoers rule — see `suyabai` and `yabai-rehash` in
`.zshrc`.

## Per-machine differences

Anything true for one machine only — a keg-only JDK, a Rust toolchain, a
PATH entry for a locally built binary — goes in `~/.zshenv.local` (variables
and PATH) or `~/.zshrc.local` (everything interactive). Both are sourced
last, so they can override anything the repo sets, and both are untracked:
the repo describes what every machine shares and nothing else.

## Global commands

`~/.local/bin` is on PATH, so a file there is a global command. It holds
two kinds of thing and they are not the same. A handful of scripts have no
repo of their own — those live in `bin/` here, because otherwise they
exist on exactly one machine. The rest are commands belonging to other
repositories; `bin/links.tsv` records the pointer and `install.sh`
recreates it on any machine that has the repo, skipping the rest.

The directory itself is never symlinked. It is where things get installed
to — the user-level `/usr/local/bin` — not a place where anything is
authored, and it also holds build output and binaries that no dotfiles
repo should carry.

## What a machine is missing

Every dependency here is guarded, so a missing tool costs a feature rather
than throwing an error. The cost of that is silence: an absent command
looks exactly like one that was never configured. `doctor` says out loud
what the guards skip — tools, coupled repositories, per-machine files, and
window management on a machine that has a display.

## Coupled repositories

`.skhdrc` calls Hammerspoon functions (`yabaiHudShow`, `yabaiHudFlip`, …)
that live in the separate [`~/repos/hammerspoon`](https://github.com/roelvangils)
config; `config/window-hud/config.lua` documents the contract from this
side. The two repos move together.

## Design rules

**Guard everything.** Any line depending on an external tool checks whether
that tool exists. A machine without `mise`, `zoxide` or `yabai` starts
without a single error, and those features switch on by themselves once the
tool is installed.

**Aliases are free, tool initialisation is not.** Aliases are plain text and
cost nothing at startup, so they all stay. The expensive part is `eval` at
startup — that stays minimal and guarded. Nothing touches the network
synchronously; the startup joke arrives in the background with a 1 s
timeout.

**`.zshenv` stays light.** It is loaded by every zsh, including every script.
Variables and `PATH` only, never a subprocess.

**Static plugin loading.** Antidote compiles `.zsh_plugins.txt` into a single
file, bytecode-compiles it, and only rebuilds when that list changes.

## Plugins

- [zsh-completions](https://github.com/zsh-users/zsh-completions) — extra tab completions
- [zsh-autopair](https://github.com/hlissner/zsh-autopair) — closes quotes and brackets
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) — prefix search with the arrow keys
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) — colours commands as you type
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) — grey suggestion from history
