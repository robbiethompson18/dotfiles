#!/bin/bash

# Create symlink for .vimrc
if [ -L "$HOME/.vimrc" ]; then
    echo "✅ .vimrc symlink already exists"
elif [ -f "$HOME/.vimrc" ]; then
    echo "⚠️  Backing up existing .vimrc to .vimrc.backup"
    mv "$HOME/.vimrc" "$HOME/.vimrc.backup"
    ln -s "$HOME/repos/dotfiles/.vimrc" "$HOME/.vimrc"
    echo "✅ Created .vimrc symlink"
else
    ln -s "$HOME/repos/dotfiles/.vimrc" "$HOME/.vimrc"
    echo "✅ Created .vimrc symlink"
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

# Check that Claude exists, if not install it:
if ! command -v claude &> /dev/null; then
    echo "❌ Claude is not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://github.com/anthropics/anthropic-sdk-cli/releases/download/v0.1.0/anthropic-cli-macos-arm64.tar.gz)\""
    echo "or install using brew: brew install claude"
    echo "or install using npm: npm install -g anthropic-sdk-cli"
    exit 1
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

# Create Cursor User directory if it doesn't exist
mkdir -p "$HOME/Library/Application Support/Cursor/User"

# Create symlink for Cursor settings.json
if [ -L "$HOME/Library/Application Support/Cursor/User/settings.json" ]; then
    echo "✅ Cursor settings.json symlink already exists"
elif [ -f "$HOME/Library/Application Support/Cursor/User/settings.json" ]; then
    echo "⚠️  Backing up existing Cursor settings.json"
    mv "$HOME/Library/Application Support/Cursor/User/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json.backup"
    ln -s "$HOME/repos/dotfiles/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
    echo "✅ Created Cursor settings.json symlink"
else
    ln -s "$HOME/repos/dotfiles/cursor/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
    echo "✅ Created Cursor settings.json symlink"
fi

# Create symlink for Cursor keybindings.json
if [ -L "$HOME/Library/Application Support/Cursor/User/keybindings.json" ]; then
    echo "✅ Cursor keybindings.json symlink already exists"
elif [ -f "$HOME/Library/Application Support/Cursor/User/keybindings.json" ]; then
    echo "⚠️  Backing up existing Cursor keybindings.json"
    mv "$HOME/Library/Application Support/Cursor/User/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json.backup"
    ln -s "$HOME/repos/dotfiles/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
    echo "✅ Created Cursor keybindings.json symlink"
else
    ln -s "$HOME/repos/dotfiles/cursor/keybindings.json" "$HOME/Library/Application Support/Cursor/User/keybindings.json"
    echo "✅ Created Cursor keybindings.json symlink"
fi