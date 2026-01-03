#!/bin/bash

# Creates a symlink, handling existing files, broken symlinks, and backups
# Usage: create_symlink <source> <target> <name>
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    if [ -L "$target" ]; then
        if [ -e "$target" ]; then
            echo "✅ $name symlink already exists"
        else
            echo "⚠️  $name symlink is broken - fixing it"
            rm "$target"
            ln -s "$source" "$target"
            echo "✅ Fixed $name symlink"
        fi
    elif [ -e "$target" ]; then
        echo "⚠️  Backing up existing $name to $name.backup"
        mv "$target" "$target.backup"
        ln -s "$source" "$target"
        echo "✅ Created $name symlink"
    else
        ln -s "$source" "$target"
        echo "✅ Created $name symlink"
    fi
}

# Shell config
create_symlink "$HOME/repos/dotfiles/.vimrc" "$HOME/.vimrc" ".vimrc"
create_symlink "$HOME/repos/dotfiles/.zshrc" "$HOME/.zshrc" ".zshrc"
create_symlink "$HOME/repos/dotfiles/.gitconfig" "$HOME/.gitconfig" ".gitconfig"

# Check that Claude exists, if not install it:
if ! command -v claude &> /dev/null; then
    echo "❌ Claude is not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://github.com/anthropics/anthropic-sdk-cli/releases/download/v0.1.0/anthropic-cli-macos-arm64.tar.gz)\""
    echo "or install using brew: brew install claude"
    echo "or install using npm: npm install -g anthropic-sdk-cli"
    exit 1
fi

# Claude config
mkdir -p "$HOME/.claude"
create_symlink "$HOME/repos/dotfiles/claude/settings.json" "$HOME/.claude/settings.json" "Claude settings.json"
create_symlink "$HOME/repos/dotfiles/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md" "Claude CLAUDE.md"
create_symlink "$HOME/repos/dotfiles/claude/plugins" "$HOME/.claude/plugins" "Claude plugins"

# Cursor config
mkdir -p "$HOME/Library/Application Support/Cursor/User"
create_symlink "$HOME/repos/dotfiles/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json" "Cursor settings.json"
create_symlink "$HOME/repos/dotfiles/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json" "Cursor keybindings.json"
