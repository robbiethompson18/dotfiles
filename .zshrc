# ============================================
# OHMYZSH
# ============================================

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# Path to your Oh My Zsh installation.
# (you might want to check this if you have a different laptop setup from me)
export ZSH="$HOME/repos/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="random"
ZSH_THEME="bira"
zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 14
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh


# ============================================
# CUSTOM ALIASES
# ============================================

# CLI shortcuts
alias cl="claude"

# Directory navigation
alias cd1="cd .."
alias cd2="cd ../.."
alias cd3="cd ../../.."
alias cd4="cd ../../../.."
alias cd5="cd ../../../../.."
alias ..="cd .."
alias .="pwd"

# Git aliases (extending Oh My Zsh git plugin)
alias gs="git status"
alias ga="git add ."
alias gc="git commit -am \"[No commit message]\" "
alias gd="git diff"
alias gl="git log"
alias gp="git push"
alias gm="git merge"
alias gco="git checkout"
alias gcm="git checkout main"
alias gnb="git checkout -b"
alias g="git"

# Development
alias prd="rm -f /tmp/dev-output.log && pnpm run dev 2>&1 | tee /tmp/dev-output.log"

# CLI tools
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --sandbox danger-full-access --ask-for-approval never --search"

# ============================================
# Global Variables
# ============================================

export EDITOR='vim'

# ============================================
# FZF INTEGRATION (Fuzzy command history)
# ============================================
# Source fzf directly from Homebrew installation
source <(fzf --zsh)
