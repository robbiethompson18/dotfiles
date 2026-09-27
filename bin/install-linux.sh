#!/bin/bash
# Linux (Debian/Ubuntu) counterpart of install-brew.sh + install-common-brew-packages.sh:
# the CLI tools the shared zsh/git config expects. No desktop apps.

set -e

sudo apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q zsh git git-lfs git-delta direnv tmux vim jq ripgrep curl unzip

mkdir -p "$HOME/.local/bin"

# fzf from GitHub: apt's is older than the 0.48 that `fzf --zsh` in .zshrc needs.
if ! command -v fzf >/dev/null || ! fzf --zsh >/dev/null 2>&1; then
    version=$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r .tag_name | tr -d v)
    arch=$(dpkg --print-architecture)
    curl -fsSL "https://github.com/junegunn/fzf/releases/download/v$version/fzf-$version-linux_$arch.tar.gz" | tar xz -C "$HOME/.local/bin" fzf
fi
echo "✅ fzf $(fzf --version)"

command -v fnm >/dev/null || [ -x "$HOME/.local/share/fnm/fnm" ] || curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
command -v uv >/dev/null || [ -x "$HOME/.local/bin/uv" ] || curl -LsSf https://astral.sh/uv/install.sh | sh

# zsh as login shell, so the shared .zshrc/.zshenv apply (and Claude Code's Bash tool uses them).
[ "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v zsh)" ] || sudo chsh -s "$(command -v zsh)" "$USER"

# Lets the systemd user units (dotfiles pull, agent-reaper) run without an open login session.
sudo loginctl enable-linger "$USER"
