#!/bin/zsh
# ~/.zshenv — Roel Van Gils
#
# Loaded by every zsh, including non-interactive ones. Keep it to variables
# and PATH only: no subprocesses, no tool initialisation.

# ============================================================
#  CORE
# ============================================================
export LANG=en_US.UTF-8
export EDITOR='code --wait'        # --wait is required for git commit
export VISUAL="$EDITOR"
export PAGER='less'
export LESS='-R'                   # keep colours in less
export CLICOLOR=1
export MAILCHECK=0

# ============================================================
#  XDG BASE DIRECTORIES
# ============================================================
# Many tools respect these and will keep their files out of $HOME.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# ============================================================
#  HOMEBREW
# ============================================================
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_BUNDLE_FILE="$HOME/repos/dotfiles/Brewfile"

# ============================================================
#  TOOL SETTINGS
# ============================================================
export BAT_PAGER=""
export BAT_THEME="Nord"
export BAT_STYLE="numbers,header-filename,header-filesize,changes"
export DIRENV_LOG_FORMAT=""        # keep direnv quiet

export BUN_INSTALL="$HOME/.bun"
export DENO_INSTALL="$HOME/.deno"
export PNPM_HOME="$HOME/Library/pnpm"

# ============================================================
#  PATH
# ============================================================
# typeset -U keeps the list unique, so duplicates drop out automatically.
typeset -U path

path=(
    # Personal scripts take precedence
    "$HOME/scripts"
    "$HOME/.local/bin"

    # Homebrew
    "/opt/homebrew/opt/sqlite/bin"
    "/opt/homebrew/opt/perl/bin"
    "/opt/homebrew/opt/git/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"

    # System
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"

    # Runtimes. Language versions are handled by mise, which adds its own
    # shims from .zshrc.
    "$BUN_INSTALL/bin"
    "$DENO_INSTALL/bin"
    "$PNPM_HOME"

    # Applications
    # Geen Xcode-pad hier: dat breekt zodra je op Xcode-beta zit. Gebruik
    # `xcrun <tool>`, dat volgt de actieve dir uit `xcode-select -p`.
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
)
export PATH

