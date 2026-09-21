# ~/.zprofile — login-shell PATH additions. Interactive config lives in .zshrc.

# OrbStack command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Codex installer puts its binary in ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
