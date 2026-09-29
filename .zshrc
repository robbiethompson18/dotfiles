# Global Variables
export PATH="$HOME/repos/dotfiles/bin:$PATH"

# An interactive shell is never inside a Claude session (Claude's Bash tool doesn't read .zshrc), so
# any CLAUDE_* here leaked in, e.g. iTerm2 relaunched by the cc-status hook inherits a session's env.
# Leaked CLAUDE_CODE_CHILD_SESSION turns off transcript saving and CLAUDE_CONFIG_DIR switches accounts.
unset -m 'CLAUDE*'

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

#Claude with chrome. The extension needs a real (headed) Chrome: macOS, or a Linux box with
# an X display (e.g. a VNC server that exports DISPLAY in ~/.zshenv.local).
[[ "$OSTYPE" == darwin* || -n "$DISPLAY" ]] && alias claude="claude --dangerously-skip-permissions --chrome"

# Shift+Tab to accept autosuggestions
bindkey '^[[Z' autosuggest-accept

# Directory navigation for this machine only
cdr() { cd ~/repos/"$1"; }
_cdr() { _files -W ~/repos -/; }
compdef _cdr cdr
# cdr<letter> per repo (cdrb -> bloomy-light-mode), plus cdrX2, cdrX3... for extra
# checkouts found on disk (cdrX1 = cdrX = main checkout). New checkouts get aliases on next
# shell start; new repos need one letter:repo entry here (letters must stay unique).
for spec in b:bloomy-light-mode s:sapient p:personal-website d:dotfiles v:vf-exercises a:deepresponse-core l:ai-misalignment; do
  letter=${spec%%:*} repo=${spec#*:}
  alias "cdr$letter"="cd ~/repos/$repo"
  alias "cdr${letter}1"="cd ~/repos/$repo"
  for dir in ~/repos/$repo-<2->(N/); do
    alias "cdr$letter${dir##*-}"="cd $dir"
  done
done
unset spec letter repo dir

# use nice new versions of python tools:
alias pip="pip3"
alias python="python3"

# fzf key bindings (Ctrl+R history). Needs fzf >= 0.48 for --zsh; Ubuntu's apt one is too old.
command -v fzf >/dev/null && source <(fzf --zsh)

# Don't save commands starting with a space to history
setopt HIST_IGNORE_SPACE

# pnpm
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
