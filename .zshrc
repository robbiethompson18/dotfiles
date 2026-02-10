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
alias cdrpd="cd ~/repos/platform-debugging-only"
alias cdrpp="cd ~/repos/platform-2"
alias cdrp2="cd ~/repos/platform-2"
alias cdrpf="cd ~/repos/platform-frontend"
alias cdrd="cd ~/repos/dotfiles"
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
alias pt="pnpm i & pnpm build"

# help with puppeteer / playwright:
alias chromeDebuggable='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug'

# CLI tools
alias claude="claude --dangerously-skip-permissions --chrome"
alias codex="codex --yolo --search"
alias c="claude --dangerously-skip-permissions --chrome"
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

# Fly.io
alias f="fly"
export FLY_APP="robbies-openclaw"  # default app

# fssh "command" [-a app] - run command on fly machine
fssh() {
  local cmd="$1"
  shift
  local app="${FLY_APP}"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a) app="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  fly ssh console -a "$app" -C "$cmd"
}

# frestart [-a app] - restart fly machine
frestart() {
  local app="${FLY_APP}"
  [[ "$1" == "-a" ]] && app="$2"
  fly machines restart -a "$app"
}

# flog [-a app] - tail fly logs
flog() {
  local app="${FLY_APP}"
  [[ "$1" == "-a" ]] && app="$2"
  fly logs -a "$app"
}

# fstatus [-a app] - fly app status
fstatus() {
  local app="${FLY_APP}"
  [[ "$1" == "-a" ]] && app="$2"
  fly status -a "$app"
}
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
export PATH="$HOME/.local/bin:$PATH"

# Don't save commands starting with a space to history
setopt HIST_IGNORE_SPACE

# OpenClaw Completion (cached, skipped if openclaw not installed)
if command -v openclaw &> /dev/null; then
  [[ -f ~/.openclaw-completion.zsh ]] || openclaw completion --shell zsh > ~/.openclaw-completion.zsh
  source ~/.openclaw-completion.zsh
fi

# ============================================
# CLAUDE LOCAL MD SYNC
# ============================================
# Syncs CLAUDE.local.md files to dotfiles for cross-machine sync
claude-local-init() {
  local remote=$(git remote get-url origin 2>/dev/null)
  if [[ -z "$remote" ]]; then
    echo "Not a git repo or no origin remote"
    return 1
  fi

  # Normalize: git@github.com:user/repo.git → github.com/user/repo
  local path=$(echo "$remote" | sed -E 's#^(git@|https://)##; s#:#/#; s#\.git$##')

  local target=~/repos/dotfiles/claude/local-mds/$path/CLAUDE.local.md
  mkdir -p "$(dirname "$target")"
  mkdir -p .claude

  if [[ -f .claude/CLAUDE.local.md && ! -L .claude/CLAUDE.local.md ]]; then
    # Move existing file to dotfiles
    mv .claude/CLAUDE.local.md "$target"
    echo "Moved existing CLAUDE.local.md to $target"
  elif [[ ! -f "$target" ]]; then
    touch "$target"
  fi

  ln -sf "$target" .claude/CLAUDE.local.md
  echo "Linked .claude/CLAUDE.local.md → $target"
}
