#alias for running claude: skip all sandboxing

# aliases:
alias cl="claude"
alias cd1="cd .."
alias cd2="cd ../.."
alias cd3="cd ../../.."
alias cd4="cd ../../../.."
alias cd5="cd ../../../../.."
alias ..="cd .."
alias .="pwd"

# git aliases:
alias gs="git status"
alias ga="git add ."
alias gc="git commit -am \"[No commit message]\" "
alias gd="git diff"
alias gl="git log"
alias dbset="cd infra && ./forwardpostgres prod1"
alias g="git"

# print logs - don't love these because we lose coloring in the terminal
alias prd="rm -f /tmp/dev-output.log && pnpm run dev 2>&1 | tee /tmp/dev-output.log"
# TODO: add equivalent command for Python?

# CLIs:
alias claude="claude --dangerously-skip-permissions"
alias codex="codex --sandbox danger-full-access --ask-for-approval never --search"
