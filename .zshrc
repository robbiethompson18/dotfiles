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
alias da="direnv allow"

# Directory navigation
alias cd1="cd .."
alias cd2="cd ../.."
alias cd3="cd ../../.."
alias cd4="cd ../../../.."
alias cd5="cd ../../../../.."
alias ..="cd .."
alias .="pwd"
cdr() { cd ~/repos/"$1"; }
_cdr() { _files -W ~/repos -/; }
compdef _cdr cdr
alias cdrp="cd ~/repos/platform"
alias cdrpp="cd ~/repos/platform-2"
alias cdrp2="cd ~/repos/platform-2"
alias cdrpf="cd ~/repos/platform-frontend"
alias cdrd="cd ~/repos/dotfiles"

# Git aliases
alias gs="git status"
alias ga="git add ."
gc() {
  git commit -am "${1:-[No commit message]}"
}
alias gp="git push"
gtr() {
  git add . && git commit -m "${1:-[No commit message]}" && git push
}
alias gd="git diff"
alias gl="git log"
alias gm="git merge"
alias gpl="git pull"
alias gpnr="git pull --no-rebase"
alias gf="git fetch"
alias gco="git checkout"
alias gcm="git checkout main"
alias gnb="git checkout -b"
alias grebasemain="git fetch origin main && git rebase origin/main"
alias g="git"
alias p="pnpm"
gstashfile() {
  git stash push -m "${2:-stash}" "$1"
}
gshowdiff() {
  git show HEAD~$1
}

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
unalias prd 2>/dev/null
prd() {
  local log_dir="/tmp${PWD#$HOME}"
  mkdir -p "$log_dir"
  local log_file="$log_dir/dev-output.log"
  rm -f "$log_file"
  pnpm run dev 2>&1 | tee "$log_file"
}

# CLI tools
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --sandbox danger-full-access --ask-for-approval never --search"
alias c="claude --dangerously-skip-permissions"
alias cr="claude --resume"

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

export PATH="$HOME/repos/dotfiles/bin:$PATH"
export EDITOR='vim'

# ============================================
# FZF INTEGRATION (Fuzzy command history)
# ============================================
# Source fzf directly from Homebrew installation
source <(fzf --zsh)

# ============================================
# DIRENV (Auto-load .envrc files)
# ============================================
eval "$(direnv hook zsh)"
