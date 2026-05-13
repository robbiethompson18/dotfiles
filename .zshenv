# Homebrew (needed before fnm)
export PATH="/opt/homebrew/bin:$PATH"

# fnm (Fast Node Manager) - works in non-interactive shells unlike nvm
eval "$(fnm env)"

# Local machine secrets and overrides. Keep this file out of git.
[ -f ~/.zshenv.local ] && source ~/.zshenv.local

# Do not unconditionally export secrets in .zshenv.local. zsh reads .zshenv
# for every shell, including `direnv exec . zsh -lc ...`, so global exports can
# override repo-local .envrc.local values. Use guarded fallbacks instead:
# if [[ -z "${SOME_API_KEY:-}" ]]; then export SOME_API_KEY=...; fi
