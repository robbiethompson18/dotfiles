# Shared interactive configuration for Bash and zsh.

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="vim"

# misc CLI shortcuts
alias src="source"
alias da="direnv allow"
alias ls="ls -a"

# Claude / Codex (launchers + short aliases, all in one place)
alias claude="claude --dangerously-skip-permissions" #without chrome on the portable version
alias codex="codex --yolo --search"
alias clp="claude"        # personal-account claude (~/.claude)
alias clpr="claude --resume"
# Work-account Claude. CLAUDE_CONFIG_DIR gives it its own login (Keychain entry is keyed
# to the dir), .claude.json, and session history; setup-symlinks.sh links the shared
# settings/CLAUDE.md/skills into it. `claude` here still expands to the alias above.
alias clw="CLAUDE_CONFIG_DIR=\$HOME/.claude-work claude"
alias clwr="CLAUDE_CONFIG_DIR=\$HOME/.claude-work claude --resume"
# Codex mirrors the Claude split: `co` + p/w, never a bare `co`, so the account is
# always explicit. CODEX_HOME gives the work root its own auth.json and session
# history; setup-symlinks.sh links the shared config.toml/AGENTS.md/skills into
# both. `codex` here still expands to the alias above.
alias cop="codex"        # personal-account codex (~/.codex)
alias copf="codex fork"
alias cow="CODEX_HOME=\$HOME/.codex-work codex"
alias cowf="CODEX_HOME=\$HOME/.codex-work codex fork"

# tmux
alias ta="tmux attach -t"
alias td="tmux detach"
alias tn="tmux new-session"
alias tl="tmux list-sessions"

# File finding shortcuts
fexact() { find . -type f -iname "$1"; }
ffuzzy() { find . -type f -iname "*$1*"; }

# Directory nac
alias cd1="cd .."
alias cd2="cd ../.."
alias cd3="cd ../../.."
alias cd4="cd ../../../.."
alias ..="cd .."
alias .="pwd"
alias cdrn="cd ~/repos/nd-rl"

# DIRENV (Auto-load .envrc files)
if command -v direnv >/dev/null 2>&1; then
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval "$(direnv hook zsh)"
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    eval "$(direnv hook bash)"
  fi
fi

# Git aliases
alias gs="git status"
alias ga="git add"
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
alias gc="git commit"
alias gp="git push"
gac() {
  git add "$1" && git commit -m "${2:-[No commit message]}" -- "$1"
}
gacp() {
  # renamed from gtr, which collided with GNU tr's Homebrew-coreutils name;
  # a stray `gtr --version` probe once committed and pushed a whole dirty tree
  if [[ "${1:-}" == -* ]]; then
    echo "gacp: commit message must not start with '-' (got: $1)" >&2
    return 1
  fi
  git add . && git commit -m "${1:-[No commit message]}" && git push
}
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


# pnpm Development
alias p="pnpm"
unalias prd 2>/dev/null
prd() {
  local log_dir="/tmp${PWD#$HOME}"
  mkdir -p "$log_dir"
  local log_file="$log_dir/dev-output.log"
  rm -f "$log_file"
  # A checkout can pin its dev-server port by dropping the number in .dev-port
  # (globally gitignored). Needed when a Caddy hostname maps to that port —
  # otherwise Vite drifts to the next free port and the mapping goes stale.
  local port_args=()
  if [[ -f .dev-port ]]; then
    port_args=(--port "$(tr -d '[:space:]' < .dev-port)" --strictPort)
  fi
  FORCE_COLOR=1 pnpm run dev "${port_args[@]}" "$@" 2>&1 | tee "$log_file"
}
alias pt="pnpm i && pnpm build"

# Run any long-lived command in this terminal while mirroring its output to a
# log an agent can read: /tmp${PWD#$HOME}/<slug>.log, slug from the command
# words (`lg make dev-cloud` -> make-dev-cloud.log). Same /tmp convention as
# prd. Uses script(1) rather than a pipe so the child keeps a TTY (colors,
# Ctrl-C, prompts); -F flushes per write so a tail -f sees lines live.
lg() {
  if [ $# -eq 0 ]; then
    echo "usage: lg <command> [args...]" >&2
    return 2
  fi
  local log_dir="/tmp${PWD#$HOME}"
  mkdir -p "$log_dir"
  local slug
  slug=$(printf '%s' "$*" | tr -c 'A-Za-z0-9._-' '-' | tr -s '-' | cut -c1-60)
  local log_file="$log_dir/$slug.log"
  : > "$log_file"
  echo "lg: logging to $log_file" >&2
  script -q -F "$log_file" "$@"
}
