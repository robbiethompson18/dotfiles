# Global Variables
export PATH="$HOME/repos/dotfiles/bin:$PATH"

# OHMYZSH
export ZSH="$HOME/repos/oh-my-zsh"
ZSH_THEME="bira"
zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 14
plugins=(zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Shared Bash/zsh aliases, functions, and environment.
source "$HOME/repos/dotfiles/shell/common.sh"

# Keep the zsh-specific untracked-file diff behavior on this machine.
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

#Claude with chrome
alias claude="claude --dangerously-skip-permissions --chrome"

# Shift+Tab to accept autosuggestions
bindkey '^[[Z' autosuggest-accept

# Directory navigation for this machine only
cdr() { cd ~/repos/"$1"; }
_cdr() { _files -W ~/repos -/; }
compdef _cdr cdr
alias cdrp="cd ~/repos/personal-website"
alias cdrd="cd ~/repos/dotfiles"
alias cdrv="cd ~/repos/vf-exercises"

# One alias per extra checkout: cdrb -> bloomy-light-mode, cdrb2 -> bloomy-light-mode-2, etc.
# cdrb1 and cdrb both point at the main checkout. Generated from what's on disk, so new
# checkouts get aliases on next shell start with no edit here.
_checkout_aliases() {
  local prefix=$1 repo=$2 dir
  alias "$prefix"="cd ~/repos/$repo"
  alias "${prefix}1"="cd ~/repos/$repo"
  for dir in ~/repos/$repo-<2->(N/); do
    alias "${prefix}${dir##*-}"="cd $dir"
  done
}
_checkout_aliases cdrb bloomy-light-mode
_checkout_aliases cdrs sapient
unset -f _checkout_aliases

# use nice new versions of python tools:
alias pip="pip3"
alias python="python3"

# Source fzf directly from Homebrew installation
source <(fzf --zsh)

# Don't save commands starting with a space to history
setopt HIST_IGNORE_SPACE

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun completions
[ -s "/Users/robbie/.bun/_bun" ] && source "/Users/robbie/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
