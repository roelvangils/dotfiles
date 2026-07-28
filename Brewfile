# Brewfile — Roel Van Gils
#
#   brew bundle                 install everything listed here
#   brew bundle check           report what is missing
#   brew bundle cleanup         list installed packages NOT in this file
#
# HOMEBREW_BUNDLE_FILE points here from .zshenv, so brew bundle works from
# any directory.
#
# Optional packages are commented out. Uncomment what you want and rerun
# brew bundle — it only installs what is missing.

tap "asmvik/formulae"
tap "darrylmorley/whatcable"

# ============================================================
#  SHELL
# ============================================================
brew "zsh"                  # newer than the system one
brew "antidote"             # zsh plugin manager
brew "mise"                 # node, python, ruby version manager
brew "direnv"               # per-directory environment variables
brew "zoxide"               # smarter cd
brew "fzf"                  # fuzzy finder, also powers the fzf-tab plugin
brew "coreutils"            # GNU utilities, used via the gnubin path

# ============================================================
#  FILES & SEARCH
# ============================================================
brew "eza"                  # ls replacement, used by the dira alias
brew "bat"                  # cat with syntax highlighting
brew "tree"
brew "trash"                # used by the del alias
brew "yazi"                 # file manager, used by the y function
brew "midnight-commander"   # used by the mc alias
brew "micro"                # editor used by the hosts/vhosts aliases

# ============================================================
#  DATA & TEXT
# ============================================================
brew "jq"
brew "glow"                 # markdown in the terminal, used by the article alias
brew "html2markdown"        # used by the html2md alias

# ============================================================
#  DEVELOPMENT
# ============================================================
brew "git"                  # newer than Apple's; .zshenv puts it first on PATH
brew "gh"
brew "lazygit"              # used by the lg alias
brew "node"
brew "bun"
brew "deno"
brew "rust"
brew "oxlint"
brew "perl"
brew "shc"                  # shell script compiler, used by shc-intel
brew "openjdk@21"           # JAVA_HOME in .zshrc points here

# ============================================================
#  MEDIA
# ============================================================
brew "ffmpeg"

# ============================================================
#  SYSTEM & MONITORING
# ============================================================
brew "btop"
brew "bluetoothconnector"   # used by the bt alias
brew "z"

# ============================================================
#  AI
# ============================================================
# mods is deprecated: charmbracelet archived the repo in March 2026.
# It still installs, with a warning. The ai alias and tolkie both depend on
# it, so it stays until those switch to fabric-ai, llm or aichat.
brew "mods"
brew "ddgr"                 # DuckDuckGo search, used by lmgtfy

# ============================================================
#  MAC APP STORE
# ============================================================
# Needs `mas` and a signed-in App Store account.
brew "mas"
mas "Consent-O-Matic", id: 1606897889   # cookie banners, open source, Aarhus University

# ============================================================
#  CASKS
# ============================================================
cask "ghostty"
cask "warp"
cask "hammerspoon"
cask "dockdoor"
cask "mos"
cask "whichspace"
cask "whatcable"
cask "latest"

# ============================================================
#  OPTIONAL — uncomment what you want back
# ============================================================

# --- Shell & files ---
# brew "fd"                 # faster find
# brew "ripgrep"            # faster grep
# brew "gum"                # pretty shell scripts
# brew "procs"              # ps replacement
# brew "bottom"             # system monitor
# brew "htop"
# brew "glances"
# brew "gdu"                # disk usage
# brew "fastfetch"
# brew "lf"
# brew "nnn"
# brew "nushell"
# brew "mmv"
# brew "parallel"
# brew "sevenzip"
# brew "yank"

# --- Text & data ---
# brew "yq"
# brew "hq"                 # jq for HTML
# brew "htmlq"
# brew "jtbl"               # JSON to tables
# brew "pandoc"
# brew "multimarkdown"
# brew "html2text"
# brew "prettier"
# brew "tailspin"           # log highlighter
# brew "lnav"               # log viewer

# --- Media ---
# brew "ffmpeg-full"        # .zshrc puts this ahead of plain ffmpeg on PATH
# brew "mpv"
# brew "sox"
# brew "exiftool"
# brew "ocrmypdf"
# brew "gifsicle"
# brew "oxipng"
# brew "pngpaste"
# brew "potrace"
# brew "chafa"
# brew "zbar"
# brew "id3v2"
# brew "opus-tools"
# brew "chromaprint"
# brew "epubcheck"
# brew "verapdf"

# --- Network ---
# brew "nmap"
# brew "wget"
# brew "httpie"
# brew "xh"
# brew "curlie"
# brew "hurl"
# brew "socat"
# brew "arp-scan"
# brew "gobuster"
# brew "cloudflared"
# brew "autossh"
# brew "wakeonlan"
# brew "wifi-password"

# --- Development ---
# brew "go"
# brew "zig"
# brew "php"
# brew "uv"                 # fast Python package installer
# brew "pipx"
# brew "cmake"
# brew "watchman"
# brew "entr"               # run a command when files change
# brew "fswatch"
# brew "hyperfine"          # benchmarking
# brew "git-filter-repo"
# brew "overmind"
# brew "posting"            # API client in the terminal
# brew "serve"
# brew "create-dmg"
# brew "cocoapods"

# --- AI ---
# brew "aichat"
# brew "llm"
# brew "llama.cpp"
# brew "gemini-cli"
# brew "fabric-ai"

# --- macOS utilities ---
# brew "mas"                # Mac App Store CLI
# brew "tag"                # file tags
# brew "cliclick"           # emulate mouse and keyboard
# brew "displayplacer"      # arrange displays
# brew "m1ddc"              # external monitor brightness, built for Apple Silicon
# brew "ddcctl"             # older alternative to m1ddc, unmaintained since 2022
# brew "blueutil"
# brew "switchaudio-osx"    # used by the audio alias
# brew "terminal-notifier"
# brew "sleepwatcher"
# brew "wallpaper"
# brew "mole"
# brew "witr"
# brew "rclone"
# brew "doctl"
# brew "flyctl"
# brew "neovim"

# --- Toys ---
# brew "cowsay"
# brew "cmatrix"
# brew "fortune"
# brew "lolcat"
# brew "sl"
# brew "figlet"
# brew "yetris"
# brew "mdp"                # markdown presentations
# brew "vhs"                # record terminal sessions
# brew "lynx"

# --- Optional casks ---
# cask "1password-cli"      # needed to move secrets out of ~/.secrets
# cask "karabiner-elements"
# cask "orbstack"
# cask "mitmproxy"
# cask "ngrok"
# cask "stats"
# cask "maestral"           # Dropbox client
# cask "calibre"
# cask "libreoffice"
# cask "wireshark-app"
# cask "keycastr"
# cask "sloth"
# cask "swiftdialog"
# cask "font-hack-nerd-font"          # icons for eza and sketchybar
# cask "font-jetbrains-mono"
# cask "font-symbols-only-nerd-font"

# Not listed on purpose:
#   nvm, pyenv, rbenv, python@3.11  -> mise handles language versions
#   thefuck                         -> slow, removed from .zshrc
#   zsh-autosuggestions, zsh-syntax-highlighting -> antidote provides these
