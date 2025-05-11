#!/bin/zsh
# ~/.zshrc - Roel van Gils
# Main ZSH configuration file with plugins, aliases, functions, and environment settings

# ===== CORE ZSH CONFIGURATION =====

# Load Zap plugin manager
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Load essential plugins
plug "zsh-users/zsh-autosuggestions"     # Fish-like autosuggestions
plug "zap-zsh/supercharge"               # Sensible ZSH defaults
plug "zap-zsh/zap-prompt"                # Prompt theme
plug "zsh-users/zsh-syntax-highlighting" # Syntax highlighting for commands
plug "zap-zsh/magic-enter"
plug "wintermi/zsh-lsd"

# Initialize completions
autoload -Uz compinit
compinit

# Load environment variables and secrets
source ~/.zshenv
source ~/.secrets

# ===== TOOL INITIALIZATIONS =====

# Development environment managers
eval "$(rbenv init - zsh)"  # Ruby version manager
eval "$(pyenv init --path)" # Python version manager
eval "$(pyenv init -)"
eval "$(direnv hook zsh)"   # Directory-specific environment variables
eval "$(thefuck --alias $)" # Command correction utility

# Navigation and utilities
eval "$(zoxide init zsh)" # Smart directory jumper (replaces cd)

# Completions for specific tools
[ -s "/Users/roelvangils/.bun/_bun" ] && source "/Users/roelvangils/.bun/_bun"
[ -s "/Users/roelvangils/.deno/env" ] && source "/Users/roelvangils/.deno/env"

# Add ngrok completions if installed
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi

# ===== ALIASES =====

# Navigation shortcuts
alias cd='z'              # Use zoxide instead of cd
alias b='cd ..'           # Go back one directory
alias h='cd ~/'           # Go to home directory
alias d='cd ~/Desktop'    # Go to Desktop
alias dl='cd ~/Downloads' # Go to Downloads
alias r='cd ~/Repos'      # Go to Repositories
alias s='cd ~/Servers'    # Go to Servers
alias v='cd /Volumes'     # Go to Volumes
alias ..='cd ..'          # Go up one directory
alias ...='cd ../..'      # Go up two directories
alias ....='cd ../../..'  # Go up three directories

# Override the uptime command
uptime() {
    print "It doesn't matter! 🙂"
}

# Remove .DS_Store files
rmds() {
    echo "Removing .DS_Store files up to 2 levels deep"
    find . -maxdepth 2 -type f -name '*.DS_Store' -print -execdir rm -f {} +
}

# Let me Google that for you
lmgtfy() {
    query=$1
    if [ -z "$query" ]; then
        read query
    fi
    echo "lEt ME goOgLE THAT fOr you…"
    open -a "Arc" "$(ddgr --np -n 1 --json "$query" | jq '.[0] .url' -r)"
}

# Development tools
alias ghw='gh repo view --web'                         # Open GitHub repo in browser
alias lg="lazygit"                                     # Git TUI
alias venv="source .venv/bin/activate"                 # Activate Python virtual environment
alias code='code -n'                                   # Always open new VS Code window
alias bt='bluetoothconnector'                          # Bluetooth connector
alias audio='switchaudiosource'                        # Switch audio source
alias sc='shortcuts'                                   # macOS Shortcuts CLI Tool
alias c='pbcopy'                                       # Copy to clipboard
alias p='pbpaste'                                      # Paste from clipboard
alias i='imgcat'                                       # Image display in terminal
alias claude="/Users/roelvangils/.claude/local/claude" # Claude AI CLI

# File and directory operations
alias dira='eza -alh --git --icons --time-style long-iso --sort modified --group-directories-first' # Enhanced directory listing
alias tree="tree -a -I 'node_modules'"                                                              # Tree view excluding node_modules
alias f='open .'                                                                                    # Open current directory in Finder
alias del='trash'                                                                                   # Move to trash instead of permanent delete

# System configuration shortcuts
alias hosts='sudo micro /etc/hosts'                            # Edit hosts file
alias vhosts='sudo micro /etc/apache2/extra/httpd-vhosts.conf' # Edit Apache vhosts
alias httpd='sudo micro /etc/apache2/httpd.conf'               # Edit Apache config

# Application shortcuts
alias mc="mc --nosubshell"                                                     # Midnight Commander without subshell
alias ai=mods                                                                  # AI assistant
alias hue=hueadm                                                               # Philips Hue admin
alias proxyman="/Applications/Setapp/Proxyman.app/Contents/MacOS/proxyman-cli" # HTTP debugging proxy
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"  # Chrome browser

# Raycast shortcuts
alias upcoming="open -g raycast://extensions/raycast/calendar/upcoming" # Show upcoming calendar events
alias emoji="open -g raycast://extensions/raycast/emoji/search-emoji"   # Search emojis

# Utility overrides
alias plb="/usr/libexec/PlistBuddy"        # Property list editor
alias jq=/opt/homebrew/bin/jq              # JSON processor
alias curl=/opt/homebrew/opt/curl/bin/curl # Use Homebrew curl
alias html2md=html2markdown                # HTML to Markdown converter

# Window management
alias bsp='yabai -m config layout bsp'     # Set window layout to binary space partition
alias float='yabai -m config layout float' # Set window layout to floating

# Shell management
alias reload='source ~/.zshrc'                                           # Reload ZSH configuration
alias rc='code ~/.zshrc ~/.secrets ~/.zshenv ~/.gitconfig ~/.ssh/config' # Edit important config files

# ===== FUNCTIONS =====

# Directory and file management
md() {
    # Create directory and navigate into it
    mkdir -p "$1" && cd "$1"
    echo "Created and moved into $(pwd)"
}

function cheat() {
    curl cht.sh/$1
}

function g() {
    open "http://www.google.com/search?q=$1"
}

# Needed for compiling universal binaries
function shc-intel() {
    arch -x86_64 /usr/local/bin/shc "$@"
}

extract() {
    # Universal archive extractor
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar e $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7z x $1 ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Yazi file manager with directory tracking
function y() {
    # Use Yazi file manager and change to selected directory on exit
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Finder integration
cdf() {
    # Change to current Finder directory
    local currFolderPath
    currFolderPath=$(
        osascript <<EOT
        tell application "Finder"
            try
                set currFolder to (folder of the front window as alias)
            on error
                set currFolder to (path to desktop folder as alias)
            end try
            POSIX path of currFolder
        end tell
EOT
    )

    if [[ -n "$currFolderPath" ]]; then
        echo "Changing to: $currFolderPath"
        cd "$currFolderPath" || return
    else
        echo "Failed to get the current Finder path."
        return 1
    fi
}

# Trash management
undel() {
    # Restore files from trash
    local trash_dir="$HOME/.Trash"
    local current_dir=$(pwd)

    if [ $# -eq 0 ]; then
        echo "Usage: undel <filename>"
        return 1
    fi

    for file in "$@"; do
        local trashed_file="$trash_dir/$file"
        if [ -e "$trashed_file" ]; then
            local original_path=$(xattr -p com.apple.metadata:kMDItemWhereFroms "$trashed_file" 2>/dev/null | xxd -r -p | plutil -convert xml1 -o - - 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')

            if [ -n "$original_path" ]; then
                local target_dir=$(dirname "$original_path")
                if [ ! -d "$target_dir" ]; then
                    target_dir="$current_dir"
                fi
            else
                target_dir="$current_dir"
            fi

            if [ -e "$target_dir/$file" ]; then
                echo "Warning: '$file' already exists in the target directory. Skipping."
            else
                mv "$trashed_file" "$target_dir/"
                echo "Restored '$file' to $target_dir"
            fi
        else
            echo "Error: '$file' not found in the trash."
        fi
    done
}

# Development tools
trackdotfile() {
    # Track a dotfile in the dotfiles repository
    if [ -e ~/$1 ]; then
        if [ -e ~/dotfiles/$1 ]; then
            echo "File already exists in dotfiles directory. Aborting."
        else
            mv ~/$1 ~/dotfiles/
            if [ -e ~/$1 ]; then
                echo "Symbolic link or file already exists in home directory. Aborting."
            else
                ln -s ~/dotfiles/$1 ~/$1
                echo "Successfully tracked $1 in dotfiles directory."
            fi
        fi
    else
        echo "File does not exist. Aborting."
    fi
}

vsp() {
    # Create VS Code settings file with common exclusions
    mkdir -p .vscode && echo '{\n\t"files.exclude": {\n\t\t"**/.git": true,\n\t\t"**/.svn": true,\n\t\t"**/.hg": true,\n\t\t"**/CVS": true,\n\t\t"**/.DS_Store": true\n\t}\n}' >.vscode/settings.json
}

function require() function require() {
    # Check if required commands are available in the system
    # Usage: require brew ffmpeg git
    local -a commands
    commands=("$@")
    local all_installed=1
    local -a missing_commands
    local script_name=$(basename "$0")

    for cmd in "${commands[@]}"; do
        if ! [ -x "$(command -v "$cmd")" ]; then
            missing_commands+=("$cmd")
            all_installed=0
        fi
    done

    if [ $all_installed -eq 0 ]; then
        if [ ${#missing_commands[@]} -eq 1 ]; then
            # Single missing command format
            echo "To run \`${script_name}\`, \`${missing_commands[1]}\` is required:" >&2
            echo "" >&2
            echo "Please install the \`${missing_commands[1]}\` using your favorite package manager, and try again." >&2
        else
            # Multiple missing commands format
            echo "To run \`${script_name}\`, these commands are required:" >&2
            echo "" >&2
            for cmd in "${missing_commands[@]}"; do
                echo "• $cmd" >&2
            done
            echo "" >&2
            echo "Please install the missing commands using your favorite package manager, and try again." >&2
        fi
        # exit 1
    fi
}

suyabai() {
    # Update yabai SHA in sudoers file
    SHA256=$(shasum -a 256 /opt/homebrew/bin/yabai | awk "{print \$1;}")
    if [ -f "/private/etc/sudoers.d/yabai" ]; then
        sudo /usr/bin/sed -i '' -e 's/sha256:[[:alnum:]]*/sha256:'${SHA256}'/' /private/etc/sudoers.d/yabai
    else
        echo "sudoers file does not exist yet"
    fi
}

kill() {
    # Kill process by name
    command kill -KILL $(pidof "$@")
}

urlencode() {
    # URL encode a string
    python -c 'import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))' "$1"
}

weather() {
    # Show weather for location
    curl wttr.in/$1
}

key() {
    # Copy SSH public key to clipboard
    echo "Copied to clipboard"
    pbcopy <~/.ssh/id_rsa.pub
}
alias rsa=key

# ===== COMPLETION CONFIGURATION =====

# Completion for undel function
_undel_completion() {
    local trash_dir="$HOME/.Trash"
    _files -W "$trash_dir" && return 0
}

compdef _undel_completion undel

# ===== ENVIRONMENT VARIABLES =====

# Color scheme definitions
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

# NVM Settings
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# ===== STARTUP COMMANDS =====

# Janky Borders (window manager)
# borders style=round active_color=0xFFFDFDFD inactive_color=0xFF606060 background_color=0x00000000 width=3.0 hidpi=on ax_focus=on blacklist="SystemUIServer,Control Center,Menu Bar,Notification Center" &

# Display welcome message
# clear
# echo "\r"
# fortune | lolcat
# echo "\r"

# Added by Windsurf
export PATH="/Users/roelvangils/.codeium/windsurf/bin:$PATH"
