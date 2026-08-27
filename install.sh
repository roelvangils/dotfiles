#!/bin/zsh
# install.sh — symlink this repo's files into place. Idempotent and
# non-destructive: an existing file or directory that is not already the
# right symlink is reported and left alone, never overwritten.
#
#   ./install.sh              link everything, report what was skipped
#   ./install.sh --headless   shell, git and terminal tools only — for a
#                             machine driven over SSH, where the window
#                             manager, hotkey daemon and status bar have
#                             no display to draw on
#
set -uo pipefail

REPO="${0:A:h}"
linked=0 skipped=0 present=0

headless=0
[[ "${1:-}" == "--headless" ]] && headless=1

# Configs for tools that need a GUI session. Skipped under --headless:
# a symlink nothing ever reads is clutter, not configuration.
gui_only=(borders bottom karabiner requestly sketchybar sketchybar-top
          sunshine tock window-hud yabai zed notion fontforge
          neofetch osxphotos)

link() {
    local src="$1" dst="$2"
    if [[ -L "$dst" && "${dst:A}" == "${src:A}" ]]; then
        (( present++ ))
    elif [[ -e "$dst" || -L "$dst" ]]; then
        echo "skip: $dst exists and is not a link to the repo"
        (( skipped++ ))
    else
        ln -s "$src" "$dst" && echo "link: $dst" && (( linked++ ))
    fi
}

# Home-directory dotfiles
files=(.zshrc .zshenv .zsh_plugins.txt .gitconfig .gitconfig-personal
       .gitignore-global)
(( headless )) || files+=(.skhdrc .yabairc)
for f in $files; do
    link "$REPO/$f" "$HOME/$f"
done

# Everything under config/ becomes ~/.config/<name>
mkdir -p "$HOME/.config"
for dir in "$REPO"/config/*(/); do
    if (( headless )) && (( ${gui_only[(Ie)${dir:t}]} )); then
        continue
    fi
    link "$dir" "$HOME/.config/${dir:t}"
done

# ~/.local/bin is on PATH, so a file there is a global command. Two kinds
# land in it, and they are not the same kind of thing.

mkdir -p "$HOME/.local/bin"

# Ours: scripts with no repo of their own. The repo is their home, and
# without it they exist on exactly one machine.
# links.tsv is the manifest below, not a command.
for f in "$REPO"/bin/*(.); do
    [[ "${f:t}" == links.tsv ]] && continue
    link "$f" "$HOME/.local/bin/${f:t}"
done

# Everyone else's: a command that lives in another repository. We store the
# pointer, never the code. A row whose target is absent is reported and
# skipped — the repo is simply not cloned on this machine yet.
absent=0
while IFS=$'\t' read -r name target; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if [[ -e "$HOME/$target" ]]; then
        link "$HOME/$target" "$HOME/.local/bin/$name"
    else
        (( absent++ ))
    fi
done < "$REPO/bin/links.tsv"
(( absent )) && echo "bin: $absent command(s) skipped, their repo is not here — run doctor"

# Secrets: real values never live in the repo
if [[ ! -e "$HOME/.secrets" ]]; then
    cp "$REPO/.secrets.template" "$HOME/.secrets"
    echo "created ~/.secrets from the template — fill in real values"
fi

echo "done: $linked linked, $present already in place, $skipped skipped"
if (( headless )); then
    echo "headless: window manager, hotkeys and status bar left unlinked"
    echo "next: machine-specific lines go in ~/.zshrc.local and ~/.zshenv.local"
else
    echo "next: brew bundle --file=$REPO/Brewfile"
fi
