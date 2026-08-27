#!/bin/zsh
# ~/.zshrc — Roel Van Gils
#
# Every line that depends on an external tool is guarded, so a machine
# without that tool starts without errors.

# Let's start with a joke — fetched in the background so the prompt is
# never blocked (a synchronous curl here cost ~190 ms per shell, and hung
# the prompt entirely on captive portals or flaky networks).
if command -v cowsay >/dev/null; then
    () {
        local joke
        joke=$(curl -s --max-time 1 https://icanhazdadjoke.com/) \
            && [ -n "$joke" ] && cowsay "$joke"
    } &!
fi

# ============================================================
#  PLUGINS
# ============================================================
# Antidote bundles all plugins into one file up front, so startup does no
# git work. Plugin list: ~/.zsh_plugins.txt
if [ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]; then
    source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
    zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins"
    # Rebuild the bundle only when the list changes.
    if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
        antidote bundle <"${zsh_plugins}.txt" >|"${zsh_plugins}.zsh"
        zcompile "${zsh_plugins}.zsh"
    fi
    source "${zsh_plugins}.zsh"
    unset zsh_plugins
fi

# ============================================================
#  SHELL BEHAVIOUR
# ============================================================
unsetopt BEEP
setopt AUTO_CD              # 'repos' instead of 'cd repos'
setopt GLOB_DOTS            # include hidden files in globs
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS # allow # comments on the command line
setopt HIST_IGNORE_SPACE    # a leading space keeps a command out of history
unsetopt FLOW_CONTROL       # free Ctrl-S / Ctrl-Q
bindkey -e                  # emacs keymap, even if $EDITOR ever contains "vi"

zmodload zsh/complist
zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
_comp_options+=(globdots)
zle_highlight=('paste:none')

autoload -Uz colors && colors

bindkey '^H' backward-kill-word                        # Ctrl+Backspace
bindkey -M menuselect '?' history-incremental-search-forward
bindkey -M menuselect '/' history-incremental-search-backward

# ============================================================
#  AUTOLOADED FUNCTIONS
# ============================================================
# Functions kept in their own repos, loaded lazily: the file is read the
# first time the command is used, and then runs in this shell instead of
# starting a new zsh the way a script would.
# Must come before compinit, which scans fpath.
if [ -d "$HOME/repos/dir" ]; then
    fpath=("$HOME/repos/dir" $fpath)
    autoload -Uz dir              # enhanced directory listing, wraps eza
fi

# ============================================================
#  COMPLETIONS
# ============================================================
# Full rebuild once a day, cached for the rest. compinit only rewrites
# the dump when fpath actually changed, so touch it ourselves — otherwise
# the mtime never advances and the slow branch runs on every startup.
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
    touch ~/.zcompdump
    # Bytecode-compile the dump; zsh picks up the .zwc automatically.
    # (Unconditional: we're already in the once-a-day branch, and -nt is
    # false in zsh when the .zwc doesn't exist yet.)
    zcompile ~/.zcompdump
else
    compinit -C
fi

# Arrow keys search on what is already typed
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ============================================================
#  PROMPT
# ============================================================
# Warp renders its own prompt; only other terminals get this one.
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
    autoload -Uz vcs_info
    setopt prompt_subst

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:git:*' formats \
        " %{$fg[blue]%}(%{$fg[red]%}%m%u%c%{$fg[magenta]%} %b%{$fg[blue]%})%{$reset_color%}"
    zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

    # ! marks untracked files
    +vi-git-untracked() {
        if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == 'true' ]] \
            && git status --porcelain | grep -q '??'; then
            hook_com[staged]+='!'
        fi
    }

    precmd_vcs_info() { vcs_info }
    precmd_functions+=( precmd_vcs_info )

    PROMPT='%B%{$fg[yellow]%}⚡%{$reset_color%} %(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}➜)%{$fg[cyan]%} %c%{$reset_color%}$vcs_info_msg_0_ '
fi

# ============================================================
#  MAGIC ENTER
# ============================================================
# Enter on an empty line: 'git status' in a repo, a 'dir' listing elsewhere.
: ${MAGIC_ENTER_GIT_COMMAND:="git status -u ."}
if (( $+functions[dir] )); then
    : ${MAGIC_ENTER_OTHER_COMMAND:="dir"}
else
    : ${MAGIC_ENTER_OTHER_COMMAND:="ls -lh ."}
fi

magic-enter() {
    [[ -n "$BUFFER" || "$CONTEXT" != start ]] && return
    if command git rev-parse --is-inside-work-tree &>/dev/null; then
        BUFFER="$MAGIC_ENTER_GIT_COMMAND"
    else
        BUFFER="$MAGIC_ENTER_OTHER_COMMAND"
    fi
}

if (( ! ${+functions[_magic-enter_accept-line]} )); then
    case "$widgets[accept-line]" in
        user:*)
            zle -N _magic-enter_orig_accept-line "${widgets[accept-line]#user:}"
            _magic-enter_accept-line() { magic-enter; zle _magic-enter_orig_accept-line -- "$@" } ;;
        builtin)
            _magic-enter_accept-line() { magic-enter; zle .accept-line } ;;
    esac
    zle -N accept-line _magic-enter_accept-line
fi

# ============================================================
#  SECRETS
# ============================================================
# API keys and tokens. Never tracked in this repo.
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# ============================================================
#  HISTORY
# ============================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt SHARE_HISTORY EXTENDED_HISTORY

# ============================================================
#  PATH
# ============================================================
# The bulk of PATH lives in .zshenv. Only conditional entries here.

# In login shells /etc/zprofile runs path_helper *after* .zshenv, which
# shuffles /usr/bin back in front of Homebrew. Re-assert our ordering
# (typeset -U in .zshenv drops the duplicates that end up further back).
path=(
    "$HOME/scripts"
    "$HOME/.local/bin"
    "/opt/homebrew/opt/sqlite/bin"
    "/opt/homebrew/opt/perl/bin"
    "/opt/homebrew/opt/git/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    $path
)

# The Zenit stack compiles with JDK 25; fall back to 21 if it is absent.
for _jdk in openjdk@25 openjdk@21; do
    if [ -d "/opt/homebrew/opt/$_jdk" ]; then
        export JAVA_HOME="/opt/homebrew/opt/$_jdk"
        export PATH="$JAVA_HOME/bin:$PATH"
        break
    fi
done
unset _jdk

# ============================================================
#  TOOLS
# ============================================================
# mise manages node, python, ruby and friends.
command -v mise   >/dev/null && eval "$(mise activate zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

[ -s "$HOME/.bun/_bun" ]  && source "$HOME/.bun/_bun"
[ -s "$HOME/.deno/env" ]  && source "$HOME/.deno/env"

[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]       && . "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

# ============================================================
#  ALIASES
# ============================================================

# --- Navigation ---
alias h='cd ~'
alias r='cd ~/repos'
alias d='cd ~/Desktop'
alias b='cd ..'
alias v='cd /Volumes'
alias dl='cd ~/Downloads'
alias gd='cd "$HOME/Library/CloudStorage/GoogleDrive-roel.van.gils@elevenways.be/"'
# Offers and their boilerplate. ~/vault links into Obsidian's iCloud
# container, the only place its iOS app reads a vault from.
alias o='cd ~/vault/Folio'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Files & directories ---
# Open a path in ForkLift.
fl() {
    open -a ForkLift "${1:-.}"
}

# Open a path in Finder. ~/.hammerspoon/forklift.lua normally hijacks every
# Finder window, so pause it briefly to let this one through.
f() {
    hs -c '_G.modules.forklift:suspend(4)' >/dev/null 2>&1
    open -a Finder "${1:-.}"
}
alias tree="tree -a -I 'node_modules'"
alias del='trash'                           # move to trash instead of deleting

# --- Clipboard ---
alias c='pbcopy'
alias p='pbpaste'
alias i='imgcat'                            # show an image in the terminal

# --- Development ---
alias code='code -n'                        # always a new window
alias lg='lazygit'
alias ghw='gh repo view --web'
alias venv='source .venv/bin/activate'

# --- System & macOS ---
alias sc='shortcuts'                        # macOS Shortcuts CLI
alias plb='/usr/libexec/PlistBuddy'
alias bt='bluetoothconnector'
alias audio='switchaudiosource'
alias hosts='sudo micro /etc/hosts'
alias vhosts='sudo micro /etc/apache2/extra/httpd-vhosts.conf'
alias httpd='sudo micro /etc/apache2/httpd.conf'

# --- Applications ---
alias mc='mc --nosubshell'
alias ai='llm'
alias html2md='html2markdown'
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias chrome-debug='killall "Google Chrome" 2>/dev/null || true; /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 --remote-debugging-address=127.0.0.1 --user-data-dir="$HOME/.chrome-debug-profile" >/dev/null 2>&1 &'
alias proxyman='/Applications/Setapp/Proxyman.app/Contents/MacOS/proxyman-cli'

# --- Raycast ---
alias upcoming='open -g raycast://extensions/raycast/calendar/upcoming'
alias emoji='open -g raycast://extensions/raycast/emoji/search-emoji'

# --- Window management ---
alias bsp='yabai -m config layout bsp'
alias float='yabai -m config layout float'

# --- Shell management ---
alias reload='source ~/.zshrc'
alias rc='code ~/.zshrc ~/.zshenv ~/.secrets ~/.gitconfig ~/.ssh/config'
alias rsa='key'

# --- Path-bound overrides ---
# Guarded: an alias to a missing path would break the command entirely.
[ -x /opt/homebrew/opt/curl/bin/curl ] && alias curl=/opt/homebrew/opt/curl/bin/curl
[ -x /opt/homebrew/bin/jq ]            && alias jq=/opt/homebrew/bin/jq

# ============================================================
#  FUNCTIONS
# ============================================================

# Create a directory and step into it
md() {
    mkdir -p "$1" && cd "$1" && echo "Created and moved into: $(pwd)"
}

# Jump to the frontmost Finder window's directory
cdf() {
    local p
    p=$(osascript -e 'tell application "Finder"
        try
            set f to (folder of the front window as alias)
        on error
            set f to (path to desktop folder as alias)
        end try
        POSIX path of f
    end tell')
    [ -n "$p" ] && cd "$p" || { echo "Could not read the Finder path"; return 1; }
}

# Jump to the directory shown in ForkLift's active tab. ForkLift reports a URL,
# which is percent-encoded and may point at a remote connection (sftp://, smb://)
# that has no local path to cd into.
cdfl() {
    # Not named `path`: in zsh that is tied to PATH, and localising it would
    # empty PATH for the rest of this function.
    local url dir
    # The running check sits outside the tell block on purpose: addressing an app
    # inside one would launch ForkLift just to answer a cd.
    url=$(osascript -e 'if application "ForkLift" is not running then return ""
    tell application "ForkLift"
        if (count of windows) is 0 then return ""
        return displayedUrl of activeTab 1 of window 1
    end tell' 2>/dev/null)

    if [[ -z "$url" ]]; then
        echo "ForkLift is not running, or has no open window"
        return 1
    fi
    if [[ "$url" != file://* ]]; then
        echo "ForkLift is showing a remote location: ${url%%:*}"
        return 1
    fi

    dir=$(printf '%s' "${url#file://}" | perl -pe 's/%([0-9A-Fa-f]{2})/chr(hex($1))/ge')
    cd "$dir" || return 1
}

# Yazi, staying in the directory you left it in
y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Copy the public SSH key to the clipboard
key() {
    pbcopy < "$HOME/.ssh/id_ed25519.pub" && echo "Public key copied to clipboard"
}

# Universal archive extractor
extract() {
    [ -f "$1" ] || { echo "'$1' is not a valid file"; return 1; }
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz)  tar xzf "$1" ;;
        *.tbz2)    tar xjf "$1" ;;
        *.tgz)     tar xzf "$1" ;;
        *.tar)     tar xf  "$1" ;;
        *.bz2)     bunzip2 "$1" ;;
        *.gz)      gunzip  "$1" ;;
        *.rar)     unrar e "$1" ;;
        *.zip)     unzip   "$1" ;;
        *.Z)       uncompress "$1" ;;
        *.7z)      7z x    "$1" ;;
        *) echo "'$1' cannot be extracted" ;;
    esac
}

# Remove .DS_Store files nearby
rmds() {
    echo "Removing .DS_Store files up to 2 levels deep"
    find . -maxdepth 2 -type f -name '*.DS_Store' -print -execdir rm -f {} +
}

# Assert that commands exist. Meant to be called inside scripts.
require() {
    local -a missing
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null || missing+=("$cmd")
    done
    if (( ${#missing[@]} )); then
        print -u2 "Missing: ${missing[*]}"
        print -u2 "Please install these and try again."
        return 1
    fi
}

# What this machine is missing. Every dependency in this file is guarded, so
# a missing tool costs you a feature instead of an error — which is the right
# default, but it means an absent command is indistinguishable from one that
# was never configured. This says out loud what the guards silently skip.
doctor() {
    local -a gone
    local r name

    print "tools"
    # Only what this config actually calls. Anything else you may like, but
    # its absence changes nothing about the shell you get.
    for name in antidote mise zoxide eza micro git gh; do
        if command -v "$name" >/dev/null; then
            print "  ok    $name"
        else
            print "  MISS  $name"
            gone+=("$name")
        fi
    done

    print "\ncoupled repositories"
    # Loaded by path, not by PATH: without the directory the command does not
    # exist at all. See the fpath block near the top and codescribe() below.
    for r in dir codescribe; do
        if [[ -d "$HOME/repos/$r" ]]; then
            print "  ok    ~/repos/$r"
        else
            print "  MISS  ~/repos/$r — git clone https://github.com/roelvangils/$r.git ~/repos/$r"
            gone+=("$r")
        fi
    done
    # codescribe runs from its own virtualenv, so the clone alone is not enough.
    if [[ -d "$HOME/repos/codescribe" && ! -x "$HOME/repos/codescribe/engine/.venv/bin/python" ]]; then
        print "  MISS  codescribe venv — (cd ~/repos/codescribe/engine && uv venv --python 3.12 && uv pip install -r requirements-lock.txt -e .)"
        gone+=("codescribe-venv")
    fi

    print "\ncommands in ~/.local/bin"
    # Each row of bin/links.tsv points at another repo. A row we cannot link
    # is a command this machine does not have — the clone is missing, or a
    # build step has not run yet.
    local n_ok=0 target
    local -a no_repo stale
    while IFS=$'\t' read -r name target; do
        [[ -z "$name" || "$name" == \#* ]] && continue
        if [[ -e "$HOME/.local/bin/$name" ]]; then
            (( n_ok++ ))
        elif [[ -L "$HOME/.local/bin/$name" ]]; then
            stale+=("$name")           # link is there, what it points at is not
        else
            no_repo+=("$name")
        fi
    done < "$HOME/repos/dotfiles/bin/links.tsv"
    print "  ok    $n_ok linked"
    (( ${#no_repo[@]} )) && { print "  MISS  ${#no_repo[@]} not linked: ${no_repo[*]}"; gone+=("${no_repo[@]}") }
    (( ${#stale[@]} ))   && print "  STALE ${#stale[@]} link(s) point nowhere: ${stale[*]}"

    print "\nper-machine files"
    # Untracked by design: the repo holds what every machine shares.
    for name in .secrets .zshenv.local .zshrc.local; do
        [[ -e "$HOME/$name" ]] && print "  ok    ~/$name" || print "  --    ~/$name (none)"
    done

    # Window management is linked only on a machine with a display. Reporting
    # yabai as missing on a headless box would be noise, not news.
    if [[ -e "$HOME/.yabairc" ]]; then
        print "\nwindow management"
        for name in yabai skhd sketchybar borders hs; do
            if command -v "$name" >/dev/null; then
                print "  ok    $name"
            else
                print "  MISS  $name"
                gone+=("$name")
            fi
        done
    fi

    (( ${#gone[@]} )) && print "\n${#gone[@]} missing: ${gone[*]}" || print "\nnothing missing"
}

# codescribe — AD Studio Engine CLI
codescribe() {
    (
        [ -f "$HOME/.secrets" ] && source "$HOME/.secrets"
        PYTHONPATH="$HOME/repos/codescribe/engine" \
            "$HOME/repos/codescribe/engine/.venv/bin/python" -m codescribe.cli "$@"
    )
}

# Restore a file from the trash to where it came from
undel() {
    local trash_dir="$HOME/.Trash"
    local current_dir="$PWD"
    [ $# -eq 0 ] && { echo "Usage: undel <filename>"; return 1; }

    for file in "$@"; do
        local trashed="$trash_dir/$file"
        if [ ! -e "$trashed" ]; then
            echo "Error: '$file' not found in the trash."
            continue
        fi
        local original target_dir
        original=$(xattr -p com.apple.metadata:kMDItemWhereFroms "$trashed" 2>/dev/null \
            | xxd -r -p | plutil -convert xml1 -o - - 2>/dev/null \
            | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')
        if [ -n "$original" ] && [ -d "$(dirname "$original")" ]; then
            target_dir="$(dirname "$original")"
        else
            target_dir="$current_dir"
        fi
        if [ -e "$target_dir/$file" ]; then
            echo "Warning: '$file' already exists in $target_dir. Skipped."
        else
            mv "$trashed" "$target_dir/" && echo "Restored '$file' to $target_dir"
        fi
    done
}
_undel_completion() { _files -W "$HOME/.Trash" && return 0 }
compdef _undel_completion undel

# --- Quick lookups ---
cheat()     { curl "cht.sh/$1" }
weather()   { curl "wttr.in/$1" }
g()         { open "http://www.google.com/search?q=$1" }
urlencode() { python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "$1" }

# Write VS Code project settings with sensible exclusions
vsp() {
    mkdir -p .vscode
    printf '{\n\t"files.exclude": {\n\t\t"**/.git": true,\n\t\t"**/.svn": true,\n\t\t"**/.hg": true,\n\t\t"**/CVS": true,\n\t\t"**/.DS_Store": true\n\t}\n}\n' > .vscode/settings.json
}

# Move a dotfile into this repo and symlink it back
trackdotfile() {
    [ -e "$HOME/$1" ] || { echo "File does not exist. Aborting."; return 1; }
    [ -e "$HOME/repos/dotfiles/$1" ] && { echo "Already in dotfiles. Aborting."; return 1; }
    mv "$HOME/$1" "$HOME/repos/dotfiles/" \
        && ln -s "$HOME/repos/dotfiles/$1" "$HOME/$1" \
        && echo "$1 is now tracked in the dotfiles repo."
}

# --- Remote machines ---
# Both rely on host aliases defined in ~/.ssh/config, which is not tracked
# here. Keeps addresses out of a public repository.
imac()   { command ssh evelyn "$@" }
shamon() { ssh evelyn -t 'zsh -lc "screen -dr shamon || screen -S shamon"' }

# ============================================================
#  YABAI
# ============================================================
# Allow yabai to load its scripting addition without a password
suyabai() {
    echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(command -v yabai) | cut -d ' ' -f 1) $(command -v yabai) --load-sa" \
        | sudo tee /private/etc/sudoers.d/yabai
}

# Update the sudoers hash after yabai changes
yabai-rehash() {
    local sha
    sha=$(shasum -a 256 "$(command -v yabai)" | awk '{print $1}')
    sudo sed -i '' "s|sha256:[a-f0-9]*|sha256:$sha|" /etc/sudoers.d/yabai \
        && sudo visudo -c -f /etc/sudoers.d/yabai \
        && sudo -n yabai --load-sa \
        && echo "yabai sudoers updated: $sha"
}

# Keep that hash in sync automatically after brew upgrades
brew() {
    command brew "$@"
    local rc=$?
    if [[ "$1" =~ ^(upgrade|install|reinstall)$ ]] \
        && command -v yabai >/dev/null \
        && ! sudo -n yabai --load-sa &>/dev/null; then
        echo "-> yabai SHA changed, updating sudoers..."
        yabai-rehash
    fi
    return $rc
}

# ============================================================
#  COLOURS
# ============================================================
# Shared palette for sketchybar and janky borders
export BLACK=0xff181819
export WHITE=0xffe2e2e3
export RED=0xfffc5d7c
export GREEN=0xff9ed072
export BLUE=0xff76cce0
export YELLOW=0xffe7c664
export ORANGE=0xfff39660
export MAGENTA=0xffb39df3
export GREY=0xff7f8490
export TRANSPARENT=0x00000000
export BG0=0xff2c2e34
export BG1=0xff363944
export BG2=0xff414550

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section


# ============================================================
#  PER-MACHINE OVERRIDES
# ============================================================
# Interactive-shell counterpart to .zshenv.local. Sourced last, so it can
# override anything above it. Untracked; see the README.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
