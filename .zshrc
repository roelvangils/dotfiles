# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# clear
# echo "\r"
# /opt/homebrew/bin/fortune
# echo "\r"

# Alias for ChatGPT
alias ai=aichat
alias hue=hueadm

# Hide Brew Analytics
export HOMEBREW_NO_ANALYTICS=1

# Raycast
alias center="open -g raycast://extensions/raycast/window-management/center"
alias left="open -g raycast://extensions/raycast/window-management/left-half"
alias right="open -g raycast://extensions/raycast/window-management/right-half"
alias top="open -g raycast://extensions/raycast/window-management/top-half"
alias bottom="open -g raycast://extensions/raycast/window-management/bottom-half"
alias upcoming="open -g raycast://extensions/raycast/calendar/upcoming"
alias emoji="open -g raycast://extensions/raycast/emoji/search-emoji"

# Proxyman
alias proxyman="/Applications/Setapp/Proxyman.app/Contents/MacOS/proxyman-cli"

# Set BAT Theme
export BAT_THEME="Nord"

# Set Pager
export PAGER=most

# don't check for new mail
MAILCHECK=0

# Path to your oh-my-zsh installation.
export ZSH="/Users/roelvangils/.oh-my-zsh"

function md() {
  mkdir -p "$1" && cd "$1"
  echo "Created and moved into $(pwd)"
}

# Setup Spaces
function setup_space {
  local idx="$1"
  local name="$2"
  local space=
  echo "setup space $idx : $name"

  space=$(yabai -m query --spaces --space "$idx")
  if [ -z "$space" ]; then
    yabai -m space --create
  fi

  yabai -m space "$idx" --label "$name"
}

# AssistivTunnel
alias atunnel="AssistivTunnel --accessKey QWnRl0FwKQYjrpuibuwB"

vortex() {
  diskutil erasevolume HFS+ Vortex $(hdiutil attach -nomount ram://102400)
}

rmds() {
  echo "Removing .DS_Store files up to 2 levels deep"
  find . -maxdepth 2 -type f -name '*.DS_Store' -print -execdir rm -f {} +
}

reload() {
  source ~/.zshrc
}

alias plb="/usr/libexec/PlistBuddy"

# Public Key to clipboard
key() {
  echo "Copied to cliboard"
  pbcopy <~/.ssh/id_rsa.pub
}

bsp() {
  yabai -m config layout bsp
}

float() {
  yabai -m config layout float
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

alias lm='lmgtfy'
alias lucky='lmgtfy'

# NVM Config (VDAB)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

f() {
  open .
}

e() {
  open-editor .
}

tab() {
  echo -e "\033];$1\007"
}

update() {
  sudo pip list --outdated | awk '{print $1}' | xargs -n1 pip install -U
  pnpm update -g pnpm
  npm update -g
  sudo npm update -g
  sudo gem update
  brew update
  brew upgrade
  brew cleanup
}

preview() {
  qlmarkdown_cli $1 >/tmp/$1.html
  echo -e "\n$(cat /tmp/$1.html)" >/tmp/$1.html
  open /tmp/$1.html
  sleep 10
  # rm /tmp/$1.html
}

vdabtunnel() {
  # Let's go
  clear
  echo "VDAB Tunnel is activated. Press CTRL+C to deactivate.\n"
  # Show VDAB Logo
  # ~/.iterm2/imgcat ~/Assets/Images/vdab.png
  # Configure Git and NPM
  git config --global http.proxy 'socks5h://127.0.0.1:1080'
  npm config set proxy socks5h://127.0.0.1:1080
  npm config set https-proxy socks5h://127.0.0.1:1080
  # Enable Proxy in macOS Network Settings
  networksetup -setsocksfirewallproxystate "Docking Station" on
  networksetup -setsocksfirewallproxystate "Dongle" on
  networksetup -setsocksfirewallproxystate "iPhone USB" on
  networksetup -setsocksfirewallproxystate "Wi-Fi" on
  # Start tunnel (and keep it running in the background until CTRL+C is pressed)
  /usr/bin/ssh -L 1080:localhost:1080 roel@kumulus.11ways.be "ssh -D 1080 imacultra -q"
  # Disable Proxy in macOS Network Settings
  networksetup -setsocksfirewallproxystate "Docking Station" off
  networksetup -setsocksfirewallproxystate "Dongle" off
  networksetup -setsocksfirewallproxystate "iPhone USB" off
  networksetup -setsocksfirewallproxystate "Wi-Fi" off
  # Reconfigure Git and NPM
  git config --global --unset http.proxy
  git config --global --unset https.proxy
  npm config rm proxy
  npm config rm https-proxy
  # … And done!
  echo "\nVDAB Tunnel is deactivated."
}

webloc2url() {
  TEMP_LIST="webloc2url-list.txt.$$.tmp"
  find . "(" -name "*.webloc" ")" >$TEMP_LIST
  while read p; do
    DIR=$(dirname "${p}")
    FILENAME=$(basename "${p}")
    FILENAME_BASE=$(basename "$FILENAME" .webloc)
    TEMP_FILE="$DIR/temp_link.url.$$.tmp"
    FILEPATH_url="${DIR}/${FILENAME_BASE}.url"
    dot_clean -m "$DIR"
    LINK=$(plutil -convert xml1 -o - "$p" | grep "string" | sed "s/<string>//" | sed "s/<\/string>//" | sed "s/	//")
    echo "[InternetShortcut]" >"${TEMP_FILE}"
    echo "URL=$LINK" >>"${TEMP_FILE}"
    mv "${TEMP_FILE}" "${FILEPATH_url}"
    rm -f FILENAME
  done <$TEMP_LIST
  rm -f $TEMP_LIST
}

# Trash rm to Trash
function rm() {
  trash $1
}

# Development website Eleven Ways
alias ewdev="ssh -t roel@kumulus.11ways.be 'clear; cd /mnt/pom/11ways/elevenways-roel/;doloop server; exec fish -l'"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  macos
  zsh-autosuggestions
)

# source $ZSH/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Edit config files with VS Code
alias hosts='sudo micro /etc/hosts'
alias vhosts='sudo micro /etc/apache2/extra/httpd-vhosts.conf'
alias httpd='sudo micro /etc/apache2/httpd.conf'

# DOS Habits
alias cls='printf "\ec"'
alias c='printf "\ec"'
alias dira='exa -alh --git --icons --time-style long-iso --sort modified --group-directories-first'

# Frequently used folders
alias b='cd ..'
alias s='cd -'
alias h='cd ~/'
alias d='cd ~/Desktop'
alias dl='cd ~/Downloads'
alias r='cd ~/Repositories'
alias s='cd ~/Servers'
alias v='cd /Volumes'
alias tr='cd ~/.Trash'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias '*'='fuck'

# Other aliases
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias opupdate="~/Repositories/opbookmarks/target/release/opbookmarks"

# cdf: cd to frontmost window of macOS Finder
cdf() {
  currFolderPath=$(
    /usr/bin/osascript <<EOT
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
  echo -e "You're here now: $currFolderPath"
  cd "$currFolderPath"
}

# Set default editor
export EDITOR='code'

# Syntax Highlighting
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Auto Suggestions
eval $(thefuck --alias)

export BUN_INSTALL="$HOME/.bun"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/Scripts:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
export HOMEBREW_NO_ENV_HINTS=0cl

# pnpm
export PNPM_HOME="/Users/roelvangils/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# starship
eval "$(starship init zsh)"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
