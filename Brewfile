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

tap "asmvik/formulae"       # skhd (original tap orphaned); trusted via `brew trust`
tap "darrylmorley/whatcable"
tap "danielgatis/imgcat"    # imgcat, used by the i alias
tap "homebrew-ffmpeg/ffmpeg" # ffmpeg with extra codecs; shadows homebrew/core

# ============================================================
#  SHELL
# ============================================================
brew "zsh"                  # newer than the system one
brew "antidote"             # zsh plugin manager
brew "mise"                 # node, python, ruby version manager
brew "direnv"               # per-directory environment variables
brew "zoxide"               # smarter cd
brew "fzf"                  # fuzzy finder
brew "atuin"                # ctrl-R with context: directory, exit code, duration
brew "coreutils"            # GNU utilities, available as g-prefixed commands

# ============================================================
#  FILES & SEARCH
# ============================================================
brew "eza"                  # ls replacement, used by the dir function
brew "bat"                  # cat with syntax highlighting
brew "fd"                   # find replacement; also what FZF_DEFAULT_COMMAND uses
brew "tree"
brew "trash"                # used by the del alias
brew "yazi"                 # file manager, used by the y function
brew "midnight-commander"   # used by the mc alias
brew "micro"                # editor used by the hosts/vhosts aliases
brew "fastfetch"            # system info, neofetch successor
brew "macchina"             # system info in Rust, TOML-themable

# ============================================================
#  DATA & TEXT
# ============================================================
brew "jq"
brew "yq"                   # jq's grip, but for YAML, TOML and plists
brew "jless"                # pager for JSON: fold, search, navigate
brew "glow"                 # markdown in the terminal
brew "html2markdown"        # used by the html2md alias
brew "pandoc"
brew "gum"                  # pretty shell scripts

# ============================================================
#  DEVELOPMENT
# ============================================================
brew "git"                  # newer than Apple's; .zshenv puts it first on PATH
brew "gh"
brew "lazygit"              # used by the lg alias
brew "git-delta"            # syntax-highlighted git diffs; set as core.pager
brew "just"                 # task runner: a justfile per repo
brew "watchexec"            # rerun a command when files change
brew "hyperfine"            # benchmark a command over N runs
brew "node"
brew "bun"
brew "deno"
brew "rust"
brew "oxlint"
brew "perl"
brew "shc"                  # shell script compiler
brew "openjdk@21"           # JAVA_HOME in .zshrc points here
brew "php"
brew "uv"                   # fast Python package installer
brew "cmake"
brew "gnupg"
brew "curl"                 # newer than the system one; .zshrc aliases to it

# ============================================================
#  MEDIA
# ============================================================
brew "homebrew-ffmpeg/ffmpeg/ffmpeg"
brew "mpv"
brew "sox"
brew "yt-dlp"
brew "imagemagick"
brew "tesseract"            # OCR
brew "tesseract-lang"

# ============================================================
#  SYSTEM & MONITORING
# ============================================================
brew "btop"
brew "bluetoothconnector"   # used by the bt alias
brew "z"
brew "switchaudio-osx"      # used by the audio alias
brew "macrowhisper"
brew "merve"
brew "nbytes"
brew "duti"                 # set the default app per file type, from the CLI
brew "pngpaste"             # write the clipboard image to a file
brew "croc"                 # send files between machines over a code phrase
# terminal-notifier is deliberately absent: unmaintained, and its
# notifications no longer behave on current macOS.

# ============================================================
#  WINDOW MANAGEMENT
# ============================================================
# yabai is installed manually (not brew-managed); its binary hash is
# pinned in /etc/sudoers.d/yabai — see suyabai/yabai-rehash in .zshrc.
brew "skhd"                 # hotkey daemon; formula lives in asmvik/formulae

# ============================================================
#  AI
# ============================================================
brew "llm"                  # replaced the archived mods; used by the ai alias
brew "ddgr"                 # DuckDuckGo search from the terminal

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
cask "keyboard-maestro"
cask "mist"                 # download macOS installers
cask "pika"                 # colour picker
cask "ant"
cask "portkiller"
cask "startupfolder"
cask "gcloud-cli"

# ============================================================
#  QUICK LOOK
# ============================================================
# These are apps, not .qlgenerator plug-ins. Apple dropped that mechanism in
# macOS 12, so the ones every old blog post recommends — QLColorCode,
# QLStephen, QuickLookJSON — no longer work. Both of these ship a CLI too.
#
# After installing: open each app once so macOS registers the extension, then
# tick it under System Settings > General > Login Items & Extensions >
# Quick Look. They are unsigned open source, so the first launch needs an
# allow under Privacy & Security.
cask "syntax-highlight"     # source code with syntax highlighting, ~180 languages
cask "qlmarkdown"           # Markdown incl. front matter, tables, Mermaid
cask "quicklook-video"      # mkv/avi/flv: thumbnails and preview in Finder
cask "suspicious-package"   # look inside a .pkg, incl. the scripts it would run
# mediainfo is the GUI app only — it ships no Quick Look extension, despite
# what its description suggests. Kept for the app itself, not for Quick Look.
cask "mediainfo"            # codecs, bitrate, audio and subtitle tracks

# ============================================================
#  OPTIONAL — uncomment what you want back
# ============================================================

# --- Shell & files ---
# brew "ripgrep"            # faster grep
# brew "procs"              # ps replacement
# brew "bottom"             # system monitor
# brew "htop"
# brew "glances"
# brew "gdu"                # disk usage
# brew "lf"
# brew "nnn"
# brew "nushell"
# brew "mmv"
# brew "parallel"
# brew "sevenzip"
# brew "yank"

# --- Text & data ---
# brew "hq"                 # jq for HTML
# brew "htmlq"
# brew "jtbl"               # JSON to tables
# brew "multimarkdown"
# brew "html2text"
# brew "prettier"
# brew "tailspin"           # log highlighter
# brew "lnav"               # log viewer

# --- Media ---
# brew "ffmpeg-full"        # drop-in ffmpeg with more codecs
# brew "exiftool"
# brew "ocrmypdf"
# brew "gifsicle"
# brew "oxipng"
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
# brew "pipx"
# brew "watchman"
# brew "entr"               # run a command when files change
# brew "fswatch"
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
# brew "tag"                # file tags
# brew "cliclick"           # emulate mouse and keyboard
# brew "displayplacer"      # arrange displays
# brew "m1ddc"              # external monitor brightness, built for Apple Silicon
# brew "ddcctl"             # older alternative to m1ddc, unmaintained since 2022
# brew "blueutil"
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
brew "cowsay"               # delivers the startup joke in .zshrc
brew "figlet"
brew "fortune"
brew "lolcat"
brew "imgcat"               # inline images in the terminal, used by the i alias
# brew "cmatrix"
# brew "sl"
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
#     (brew copies are installed but never sourced; kept, not declared)
#   yabai                           -> installed manually, see WINDOW MANAGEMENT

# Folio: PDF page counts and text extraction
brew "poppler"
brew "cpdf"
