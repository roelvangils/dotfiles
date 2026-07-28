#!/bin/zsh
# ~/.zshrc — Roel Van Gils
#
# Every line that depends on an external tool is guarded, so a machine
# without that tool starts without errors.

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
setopt NOMATCH
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS # allow # comments on the command line

zmodload zsh/complist
zstyle ':completion:*' menu yes select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
_comp_options+=(globdots)
zle_highlight=('paste:none')

autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
autoload -Uz colors && colors

bindkey '^H' backward-kill-word                        # Ctrl+Backspace
bindkey -M menuselect '?' history-incremental-search-forward
bindkey -M menuselect '/' history-incremental-search-backward

alias ls='ls -G'

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
# Full rebuild once a day, cached for the rest.
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
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
if [ -d "/opt/homebrew/opt/openjdk@21" ]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
    export PATH="$JAVA_HOME/bin:$PATH"
fi

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
# Offers and their boilerplate. Obsidian's iOS app only reads its own iCloud
# container, which is why the vault lives this far down.
alias o='cd "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/The Vault/Folio"'
alias vault='cd "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/The Vault"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Files & directories ---
alias f='open . -a Finder'
alias m='open . -a Marta'
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
alias jqq='~/.jqq/jqq.rb'
alias article='inspekt extract article --no-frontmatter --exclude-images --flatten | glow'

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
alias hue='hueadm'
alias ai='mods'
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

lmgtfy() {
    local query=$1
    [ -z "$query" ] && read query
    echo "lEt ME goOgLE THAT fOr you…"
    open -a "Arc" "$(ddgr --np -n 1 --json "$query" | jq '.[0] .url' -r)"
}

# Current selection from inspekt, as markdown
s() { curl -s http://inspekt:8000/api/selection/markdown | jq ".result.markdown" -r }

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

# Compile universal binaries
shc-intel() { arch -x86_64 /usr/local/bin/shc "$@" }

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
    sudo sed -i.bak "s|sha256:[a-f0-9]*|sha256:$sha|" /etc/sudoers.d/yabai \
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
#  TOOL COMPLETIONS
# ============================================================
_inspekt_completion() {
    local -a completions
    local -a completions_with_descriptions
    local -a response
    (( ! $+commands[inspekt] )) && return 1

    response=("${(@f)$(env COMP_WORDS="${words[*]}" COMP_CWORD=$((CURRENT-1)) _INSPEKT_COMPLETE=zsh_complete inspekt)}")

    for type key descr in ${response}; do
        if [[ "$type" == "plain" ]]; then
            if [[ "$descr" == "_" ]]; then
                completions+=("$key")
            else
                completions_with_descriptions+=("$key":"$descr")
            fi
        elif [[ "$type" == "dir" ]]; then
            _path_files -/
        elif [[ "$type" == "file" ]]; then
            _path_files -f
        fi
    done

    [ -n "$completions_with_descriptions" ] && _describe -V unsorted completions_with_descriptions -U
    [ -n "$completions" ] && compadd -U -V unsorted -a completions
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
    _inspekt_completion "$@"
else
    compdef _inspekt_completion inspekt
fi

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
