# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions)
source "$ZSH/oh-my-zsh.sh"

# --- Editor ---
export EDITOR="nvim"

# --- Aliases ---
alias vim="nvim"
alias vi="nvim"
alias be="bundle exec"

# --- PATH ---
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

# --- Machine-specific config ---
# Source local overrides (version managers, credentials, machine-specific paths)
# This file is NOT tracked in git
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
