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
| `install.sh` | Symlinks all of the above into place |

## Setup on a new machine

```sh
git clone https://github.com/roelvangils/dotfiles.git ~/repos/dotfiles
~/repos/dotfiles/install.sh    # symlinks; never overwrites existing files
brew bundle --file=~/repos/dotfiles/Brewfile
```

Then fill in `~/.secrets` (created from the template by the installer).
Open a new shell: antidote fetches the plugins on first run, which takes
a second or two; every start after that is under 100 ms.

Not covered by `brew bundle`: **yabai** is installed manually and blessed
via a hash-pinned sudoers rule — see `suyabai` and `yabai-rehash` in
`.zshrc`.

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
