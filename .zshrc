# ============================================
# OHMYZSH
# =============================================
export ZSH="$HOME/repos/oh-my-zsh"

ZSH_THEME="bira"
zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 14
plugins=(zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Shift+Tab to accept autosuggestions
bindkey '^[[Z' autosuggest-accept

# ============================================
# CUSTOM ALIASES
# ============================================

# CLI shortcuts
alias cl="claude"
alias src="source"

# Directory navigation
alias cd1="cd .."
alias cd2="cd ../.."
alias cd3="cd ../../.."
alias cd4="cd ../../../.."
alias cd5="cd ../../../../.."
alias ..="cd .."
alias .="pwd"
cdr() { cd ~/repos/"$1"; }
alias cdrp="cd ~/repos/platform"
alias cdrd="cd ~/repos/dotfiles"

# Git aliases
alias gs="git status"
alias ga="git add ."
gc() {
  git commit -am "${1:-[No commit message]}"
}
alias gp="git push"
gtr() {
  git add . && git commit "${1:-[No commit message]}" && git push
}
alias gd="git diff"
alias gl="git log"
alias gm="git merge"
alias gpl="git pull"
alias gf="git fetch"
alias gco="git checkout"
alias gcm="git checkout main"
alias gnb="git checkout -b"
alias g="git"

# Convert HTTPS GitHub URL to SSH and clone
gclonessh() {
  if [[ -z "$1" ]]; then
    echo "Usage: gclonessh <github-url>"
    return 1
  fi

  local url="$1"

  # Convert https://github.com/user/repo to git@github.com:user/repo.git
  local ssh_url=$(echo "$url" | sed -E 's#https://github\.com/([^/]+)/([^/]+)(\.git)?#git@github.com:\1/\2.git#')

  echo "Cloning: $ssh_url"
  git clone "$ssh_url"
}

# Development
alias prd="rm -f /tmp/dev-output.log && pnpm run dev 2>&1 | tee /tmp/dev-output.log"

# CLI tools
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --sandbox danger-full-access --ask-for-approval never --search"
alias c="claude --dangerously-skip-permissions"

# use nice new versions of python tools:
alias pip="pip3"
alias python="python3"

# File finding
fexact() { find . -type f -iname "$1"; }
ffuzzy() { find . -type f -iname "*$1*"; }

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
