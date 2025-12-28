#!/bin/bash

# Configure macOS to enable key repeat (disable press-and-hold for accented characters)
echo "⚙️  Configuring macOS settings..."
defaults write -g ApplePressAndHoldEnabled -bool false
echo "✅ Key repeat enabled (press-and-hold disabled)"
echo "   Note: Restart your applications for this to take effect"
