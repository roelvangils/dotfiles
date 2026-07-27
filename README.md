# Dotfiles

Shell and tool configuration for my macOS machines. Public, so others can
read along — I have learned plenty from other people's dotfiles.

No API keys or other secrets live here. Those sit in `~/.secrets`, which is
sourced by `.zshrc` and excluded by `.gitignore`.

## Contents

| File | Purpose |
|---|---|
| `.zshrc` | Interactive shell: plugins, prompt, aliases, functions |
| `.zshenv` | Environment variables and `PATH`. Loaded by every zsh |
| `.zsh_plugins.txt` | Plugin list for [antidote](https://github.com/mattmc3/antidote) |
| `.gitconfig` | Git settings, with a conditional personal identity |
| `.gitconfig-personal` | Email used for repositories under `~/repos` |
| `.gitignore-global` | Ignore rules applied to every repository |

## Setup on a new machine

```sh
brew install antidote
git clone https://github.com/roelvangils/dotfiles.git ~/repos/dotfiles

for f in .zshrc .zshenv .zsh_plugins.txt .gitconfig .gitconfig-personal .gitignore-global; do
    ln -s ~/repos/dotfiles/$f ~/$f
done
```

Open a new shell. Antidote fetches the plugins on first run, which takes a
second or two; every start after that is around 60 ms.

## Design rules

**Guard everything.** Any line depending on an external tool checks whether
that tool exists. A machine without `mise`, `zoxide` or `yabai` starts
without a single error, and those features switch on by themselves once the
tool is installed.

**Aliases are free, tool initialisation is not.** Aliases are plain text and
cost nothing at startup, so they all stay. The expensive part is `eval` at
startup — that stays minimal and guarded.

**`.zshenv` stays light.** It is loaded by every zsh, including every script.
Variables and `PATH` only, never a subprocess.

**Static plugin loading.** Antidote compiles `.zsh_plugins.txt` into a single
file and only rebuilds it when that list changes.

## Plugins

- [zsh-completions](https://github.com/zsh-users/zsh-completions) — extra tab completions
- [zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use) — warns when an alias already exists for what you typed
- [zsh-autopair](https://github.com/hlissner/zsh-autopair) — closes quotes and brackets
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) — prefix search with the arrow keys
- [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) — colours commands as you type
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) — grey suggestion from history
