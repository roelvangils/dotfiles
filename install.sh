#!/bin/zsh
# install.sh — symlink this repo's files into place. Idempotent and
# non-destructive: an existing file or directory that is not already the
# right symlink is reported and left alone, never overwritten.
#
#   ./install.sh          link everything, report what was skipped
#
set -uo pipefail

REPO="${0:A:h}"
linked=0 skipped=0 present=0

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
for f in .zshrc .zshenv .zsh_plugins.txt .gitconfig .gitconfig-personal \
         .gitignore-global .skhdrc .yabairc; do
    link "$REPO/$f" "$HOME/$f"
done

# Everything under config/ becomes ~/.config/<name>
mkdir -p "$HOME/.config"
for dir in "$REPO"/config/*(/); do
    link "$dir" "$HOME/.config/${dir:t}"
done

# Secrets: real values never live in the repo
if [[ ! -e "$HOME/.secrets" ]]; then
    cp "$REPO/.secrets.template" "$HOME/.secrets"
    echo "created ~/.secrets from the template — fill in real values"
fi

echo "done: $linked linked, $present already in place, $skipped skipped"
echo "next: brew bundle --file=$REPO/Brewfile"
