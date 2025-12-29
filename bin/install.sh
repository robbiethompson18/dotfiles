#!/bin/bash
# Dotfiles Installation Script
# This script sets up Oh My Zsh, plugins, fzf, and symlinks your dotfiles

set -e  # Exit on error

echo "🚀 Starting dotfiles installation..."

# Install Homebrew
./install_brew.sh

# Install CLI tools
./install_cli_tools.sh

# Install common brew packages
./install_common_brew_packages.sh

# Install common applications
./install_common_applications.sh

# Configure macOS settings
./configure_macos_settings.sh

# Setup symlinks
./setup_symlinks.sh

# install cursor extensions
./install_cursor_extensions.sh


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
echo "  • Common applications installed (Chrome, Rectangle, iTerm2, Cursor)"
echo "  • macOS key repeat enabled (press-and-hold disabled)"
echo ""
echo "Note: See CLAUDE_SETTINGS_README.md for info about Claude settings."
echo ""
