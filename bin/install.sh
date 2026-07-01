#!/bin/bash
# Dotfiles Installation Script
# This script sets up Oh My Zsh, plugins, fzf, and symlinks your dotfiles

set -e  # Exit on error

echo "🚀 Starting dotfiles installation..."

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

# Setup symlinks
./setup-symlinks.sh

# setup vim
./setup-vim.sh

# Install launchd agent for weekly dotfiles pull
./install-launchd-pull

# Install launchd agent that lets Claude/Codex sessions request retirement
./install-agent-reaper

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
echo "  • Weekly dotfiles auto-pull (launchd)"
echo "  • Agent reaper for Claude/Codex session cleanup (launchd)"
echo ""
echo "Note: See CLAUDE_SETTINGS_README.md for info about Claude settings."
echo ""
