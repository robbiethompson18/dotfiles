#!/bin/bash

# Dotfiles Installation Script
# This script sets up Oh My Zsh, plugins, fzf, and symlinks your dotfiles

set -e  # Exit on error

echo "🚀 Starting dotfiles installation..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Install Oh My Zsh to ~/repos/oh-my-zsh
if [ ! -d "$HOME/repos/oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh to ~/repos/oh-my-zsh..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/repos/oh-my-zsh"
else
    echo "✅ Oh My Zsh already installed"
fi

# Install zsh-autosuggestions plugin
if [ ! -d "$HOME/repos/oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "📦 Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/repos/oh-my-zsh/custom/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting plugin
if [ ! -d "$HOME/repos/oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    echo "📦 Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/repos/oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
else
    echo "✅ zsh-syntax-highlighting already installed"
fi

# Install fzf via Homebrew
if ! brew list fzf &> /dev/null; then
    echo "📦 Installing fzf via Homebrew..."
    brew install fzf
else
    echo "✅ fzf already installed"
fi

# Create symlink for .zshrc
if [ -L "$HOME/.zshrc" ]; then
    echo "✅ .zshrc symlink already exists"
elif [ -f "$HOME/.zshrc" ]; then
    echo "⚠️  Backing up existing .zshrc to .zshrc.backup"
    mv "$HOME/.zshrc" "$HOME/repos/dotfiles/.zshrc.backup"
    ln -s "$HOME/repos/dotfiles/.zshrc" "$HOME/.zshrc"
    echo "✅ Created .zshrc symlink"
else
    ln -s "$HOME/repos/dotfiles/.zshrc" "$HOME/.zshrc"
    echo "✅ Created .zshrc symlink"
fi

# Create ~/.claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

# Create symlink for Claude settings.json
if [ -L "$HOME/.claude/settings.json" ]; then
    echo "✅ Claude settings.json symlink already exists"
elif [ -f "$HOME/.claude/settings.json" ]; then
    echo "⚠️  Backing up existing Claude settings.json"
    mv "$HOME/.claude/settings.json" "$HOME/.claude/settings.json.backup"
    ln -s "$HOME/repos/dotfiles/claude-settings.json" "$HOME/.claude/settings.json"
    echo "✅ Created Claude settings.json symlink"
else
    ln -s "$HOME/repos/dotfiles/claude-settings.json" "$HOME/.claude/settings.json"
    echo "✅ Created Claude settings.json symlink"
fi

# Create symlink for Claude plugins directory
if [ -L "$HOME/.claude/plugins" ]; then
    echo "✅ Claude plugins symlink already exists"
elif [ -d "$HOME/.claude/plugins" ]; then
    echo "⚠️  Backing up existing Claude plugins directory"
    mv "$HOME/.claude/plugins" "$HOME/.claude/plugins.backup"
    ln -s "$HOME/repos/dotfiles/claude-plugins" "$HOME/.claude/plugins"
    echo "✅ Created Claude plugins symlink"
else
    ln -s "$HOME/repos/dotfiles/claude-plugins" "$HOME/.claude/plugins"
    echo "✅ Created Claude plugins symlink"
fi

echo ""
echo "✨ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. If you see weird symbols in your prompt, install a powerline font"
echo "     or change the theme in .zshrc (line 11) to 'robbyrussell' or 'bira'"
echo ""
echo "Features enabled:"
echo "  • Oh My Zsh with random theme"
echo "  • zsh-autosuggestions (press → to accept)"
echo "  • zsh-syntax-highlighting (green=valid, red=invalid)"
echo "  • fzf fuzzy search (Ctrl+R for history)"
echo "  • Claude Code settings synced from dotfiles"
echo ""
echo "Note: See CLAUDE_SETTINGS_README.md for info about Claude settings."
echo ""
