#!/bin/bash
# Dotfiles Installation Script
# This script sets up Oh My Zsh, plugins, fzf, and symlinks your dotfiles

set -e  # Exit on error

# Claude's native installer, uv and (on Linux) fzf land here; a fresh shell may not have it yet.
export PATH="$HOME/.local/bin:$PATH"

echo "🚀 Starting dotfiles installation..."

# uname, not $OSTYPE: new_laptop_setup.md runs this with `sh`, which is dash on Ubuntu.
if [ "$(uname)" = Darwin ]; then
    # Install Homebrew
    ./install-brew.sh

    # Install CLI tools
    ./install-cli-tools.sh

    # Install common brew packages
    ./install-common-brew-packages.sh

    # Install common applications
    ./install-common-applications.sh

    # Configure macOS settings
    ./configure-macos-settings.sh

    # Set VS Code as default editor for code/text files
    ./set-default-editor.sh
else
    # apt packages, fzf, fnm, uv, zsh as login shell
    ./install-linux.sh

    # Oh My Zsh + plugins
    ./install-cli-tools.sh
fi

# Setup symlinks
./setup-symlinks.sh

# setup vim
./setup-vim.sh

# Background agents (launchd on macOS, systemd on Linux; see bin/install-launchd-agent):
# weekly dotfiles pull, agent-reaper (lets Claude/Codex sessions request retirement), oom-guard
# (kills runaway agent processes before they OOM the Mac), disk-sweep (hourly scratchpad and Docker
# image cleanup). main-checkout-pull is installed by hand on the Mac that has those checkouts.
for agent in dotfiles-pull agent-reaper oom-guard disk-sweep; do
    ./install-launchd-agent "$agent"
done

echo ""
echo "✨ Installation complete!"
echo ""
echo "Next step: Restart your terminal or run: source ~/.zshrc"
echo ""
echo "Features enabled:"
echo "  • Oh My Zsh with bira theme"
echo "  • zsh-autosuggestions (press → to accept)"
echo "  • zsh-syntax-highlighting (green=valid, red=invalid)"
echo "  • fzf fuzzy search (Ctrl+R for history)"
echo "  • Claude Code settings synced from dotfiles"
echo "  • Brew installed"
echo "  • Common brew packages installed"
echo "  • Common applications installed (Chrome, iTerm2, VS Code, Hammerspoon)"
echo "  • macOS key repeat enabled (press-and-hold disabled)"
echo "  • Background agents: weekly dotfiles pull, agent-reaper, oom-guard, disk-sweep"
echo ""
echo "Note: See docs/claude-settings.md for info about Claude settings."
echo ""
