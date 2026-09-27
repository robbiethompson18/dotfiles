#!/bin/bash

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

# fzf + direnv. Linux gets them from install-linux.sh instead (apt's fzf is too old).
if [[ "$OSTYPE" == darwin* ]]; then
    for pkg in fzf direnv; do
        if ! brew list $pkg &> /dev/null; then
            echo "📦 Installing $pkg via Homebrew..."
            brew install $pkg
        else
            echo "✅ $pkg already installed"
        fi
    done
fi