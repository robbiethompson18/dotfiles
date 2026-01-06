#!/bin/bash

# Install Google Chrome
if [ ! -d "/Applications/Google Chrome.app" ]; then
    echo "📦 Installing Google Chrome..."
    brew install google-chrome
else
    echo "✅ Google Chrome already installed"
fi

# Install Rectangle
if [ ! -d "/Applications/Rectangle.app" ]; then
    echo "📦 Installing Rectangle..."
    brew install rectangle
else
    echo "✅ Rectangle already installed"
fi

# Install iTerm2
if [ ! -d "/Applications/iTerm.app" ]; then
    echo "📦 Installing iTerm2..."
    brew install iterm2
else
    echo "✅ iTerm2 already installed"
fi

# Install Cursor
if [ ! -d "/Applications/Cursor.app" ]; then
    echo "📦 Installing Cursor..."
    brew install cursor
else
    echo "✅ Cursor already installed"
fi

# Install Docker
if [ ! -d "/Applications/Docker.app" ]; then
    echo "📦 Installing Docker..."
    brew install --cask docker
else
    echo "✅ Docker already installed"
fi
