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

# Install Zoom
if [ ! -d "/Applications/zoom.us.app" ]; then
    echo "📦 Installing Zoom..."
    brew install --cask zoom
else
    echo "✅ Zoom already installed"
fi

# Install Claude Desktop
if [ ! -d "/Applications/Claude.app" ]; then
    echo "📦 Installing Claude Desktop..."
    brew install --cask claude
else
    echo "✅ Claude Desktop already installed"
fi

# Install Maccy (clipboard manager)
if [ ! -d "/Applications/Maccy.app" ]; then
    echo "📦 Installing Maccy..."
    brew install --cask maccy
else
    echo "✅ Maccy already installed"
fi

# Install Hammerspoon (automation/hotkeys)
if [ ! -d "/Applications/Hammerspoon.app" ]; then
    echo "📦 Installing Hammerspoon..."
    brew install --cask hammerspoon
else
    echo "✅ Hammerspoon already installed"
fi

# Install Ghostty (terminal)
if [ ! -d "/Applications/Ghostty.app" ]; then
    echo "📦 Installing Ghostty..."
    brew install --cask ghostty
else
    echo "✅ Ghostty already installed"
fi
