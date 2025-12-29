# ============================================
# OHMYZSH
# =============================================
export ZSH="$HOME/repos/oh-my-zsh"

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
alias gpl="git pull"
alias gf="git fetch"
alias gco="git checkout"
alias gcm="git checkout main"
alias gnb="git checkout -b"
alias g="git"

# Development
alias prd="rm -f /tmp/dev-output.log && pnpm run dev 2>&1 | tee /tmp/dev-output.log"

# CLI tools
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --sandbox danger-full-access --ask-for-approval never --search"

# use nice new versions of python tools:
alias pip="pip3"
alias python="python3"

# tmux
alias ta="tmux attach -t"
alias td="tmux detach"
alias tn="tmux new-session"
alias tl="tmux list-sessions"
# ============================================
# Global Variables
# ============================================

export EDITOR='vim'

# ============================================
# FZF INTEGRATION (Fuzzy command history)
# ============================================
# Source fzf directly from Homebrew installation
source <(fzf --zsh)
