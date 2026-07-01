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

# Claude / Codex (launchers + short aliases, all in one place)
alias claude="claude --dangerously-skip-permissions --chrome"
alias codex="codex --yolo --search"
alias cl="claude"        # claude
alias cr="claude --resume"
alias c="codex"          # codex (one-key)
alias co="codex"         # codex (same as c)
alias cf="codex fork"

# CLI shortcuts
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
alias cdrpd="cd ~/repos/platform-debugging-only"
alias cdrpp="cd ~/repos/platform-2"  # redundant with cdrp2 (both → platform-2)
alias cdrp2="cd ~/repos/platform-2"
alias cdrpf="cd ~/repos/platform-frontend"
alias cdrd="cd ~/repos/dotfiles"
alias cdra="cd ~/repos/agentdrive"
alias cdrb="cd ~/repos/personal-website"
unalias cdrs 2>/dev/null
cdrs() {
  local -a roots available
  local root pick

  roots=(
    "$HOME/repos/sapient"
    "$HOME/repos/sapient-2"
    "$HOME/repos/sapient-3"
    "$HOME/repos/sapient-4"
    "$HOME/repos/sapient-5"
    "$HOME/repos/sapient-6"
    "$HOME/repos/sapient-7"
    "$HOME/repos/sapient-8"
  )

  for root in "${roots[@]}"; do
    [[ -d "$root" ]] || continue
    available+=("$root")
  done

  if (( ${#available[@]} == 0 )); then
    echo "no sapient checkout available"
    return 1
  fi

  pick="${available[$((RANDOM % ${#available[@]} + 1))]}"
  cd "$pick" || return
  echo "using $pick"
}
alias cdrs1="cd ~/repos/sapient"
alias cdrs2="cd ~/repos/sapient-2"
alias cdrs3="cd ~/repos/sapient-3"
alias cdrs4="cd ~/repos/sapient-4"
alias cdrs5="cd ~/repos/sapient-5"
alias cdrs6="cd ~/repos/sapient-6"
alias cdrs7="cd ~/repos/sapient-7"
alias cdrs8="cd ~/repos/sapient-8"
alias cdop="cd ~/.openclaw"

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
unalias gd 2>/dev/null
gd() {
  git diff "$@"
  local -a untracked
  # Collect untracked files safely (NUL-delimited to handle spaces).
  untracked=("${(@0)$(git ls-files -o --exclude-standard -z)}")
  if (( ${#untracked} )); then
    printf '\n# Untracked files\n'
    for f in "${untracked[@]}"; do
      git diff --no-index /dev/null -- "$f"
    done
  fi
}
alias gl="git log"
alias gm="git merge"
alias gpl="git pull"
alias gpnr="git pull --no-rebase"
alias gf="git fetch"
alias gco="git checkout"
alias gcm="git checkout main"
alias gnb="git checkout -b"
alias grebasemain="git fetch origin main && git rebase origin/main"
alias grb="git fetch origin main && git rebase origin/main"
alias g="git"
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
alias p="pnpm"
unalias prd 2>/dev/null
prd() {
  local log_dir="/tmp${PWD#$HOME}"
  mkdir -p "$log_dir"
  local log_file="$log_dir/dev-output.log"
  rm -f "$log_file"
  FORCE_COLOR=1 pnpm run dev 2>&1 | tee "$log_file"
}
unalias plp 2>/dev/null
plp() {
  local log_dir="/tmp${PWD#$HOME}"
  mkdir -p "$log_dir"
  local log_file="$log_dir/logs-prod.log"
  rm -f "$log_file"
  FORCE_COLOR=1 pnpm run logs-prod 2>&1 | tee "$log_file"
}
alias pt="pnpm i && pnpm build"

# help with puppeteer / playwright:
alias chromeDebuggable='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug'

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
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='vim'
export CLAUDE_CODE_NO_FLICKER=1

# ============================================
# FZF INTEGRATION (Fuzzy command history)
# ============================================
# Source fzf directly from Homebrew installation
source <(fzf --zsh)

# ============================================
# DIRENV (Auto-load .envrc files)
# ============================================
eval "$(direnv hook zsh)"

# Don't save commands starting with a space to history
setopt HIST_IGNORE_SPACE

# OpenClaw Completion (cached, skipped if openclaw not installed)
if command -v openclaw &> /dev/null; then
  [[ -f ~/.openclaw-completion.zsh ]] || openclaw completion --shell zsh > ~/.openclaw-completion.zsh
  source ~/.openclaw-completion.zsh
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/Users/robbie/.bun/_bun" ] && source "/Users/robbie/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
