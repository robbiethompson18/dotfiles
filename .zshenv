# fnm (Fast Node Manager) - works in non-interactive shells unlike nvm
eval "$(fnm env)"

# Do not unconditionally export secrets here. zsh reads .zshenv for every
# shell, including `direnv exec . zsh -lc ...`, so global exports can override
# repo-local .envrc.local values. Use guarded fallbacks instead:
# if [[ -z "${SOME_API_KEY:-}" ]]; then export SOME_API_KEY=...; fi
