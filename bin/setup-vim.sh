#!/bin/bash

set -e

echo "🔧 Setting up Vim configuration..."

# 1. Install vim-plug
echo "📦 Installing vim-plug..."
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "✅ vim-plug installed"
else
    echo "✅ vim-plug already installed"
fi

# Note: .vimrc symlink is handled by setup-symlinks.sh

# 2. Check for Node.js (required for coc.nvim)
echo "🔍 Checking for Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js found: $NODE_VERSION"
else
    echo "⚠️  Node.js not found - it's required for coc.nvim"
    echo "   Install it with: brew install node"
fi

# 3. Install vim plugins
echo "📥 Installing Vim plugins..."
vim +PlugInstall +qall

echo ""
echo "✨ Vim setup complete!"
echo ""
echo "Next steps:"
echo "  - Open vim and the plugins should be ready to use"
echo "  - coc.nvim extensions will auto-install on first use"
echo "  - Run :CocInfo in vim to check coc.nvim status"
