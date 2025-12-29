#!/bin/bash

set -e

echo "🔧 Setting up Vim configuration..."

# Get the directory where this script lives
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 1. Install vim-plug
echo "📦 Installing vim-plug..."
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "✅ vim-plug installed"
else
    echo "✅ vim-plug already installed"
fi

# 2. Create symlink to .vimrc
echo "🔗 Creating symlink to .vimrc..."
if [ -L ~/.vimrc ]; then
    echo "⚠️  Symlink already exists at ~/.vimrc"
    ls -la ~/.vimrc
elif [ -f ~/.vimrc ]; then
    echo "⚠️  Regular file exists at ~/.vimrc - backing up to ~/.vimrc.backup"
    mv ~/.vimrc ~/.vimrc.backup
    ln -s "$DOTFILES_DIR/.vimrc" ~/.vimrc
    echo "✅ Symlink created (old file backed up)"
else
    ln -s "$DOTFILES_DIR/.vimrc" ~/.vimrc
    echo "✅ Symlink created"
fi

# 3. Check for Node.js (required for coc.nvim)
echo "🔍 Checking for Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js found: $NODE_VERSION"
else
    echo "⚠️  Node.js not found - it's required for coc.nvim"
    echo "   Install it with: brew install node"
fi

# 4. Install vim plugins
echo "📥 Installing Vim plugins..."
vim +PlugInstall +qall

echo ""
echo "✨ Vim setup complete!"
echo ""
echo "Next steps:"
echo "  - Open vim and the plugins should be ready to use"
echo "  - coc.nvim extensions will auto-install on first use"
echo "  - Run :CocInfo in vim to check coc.nvim status"
