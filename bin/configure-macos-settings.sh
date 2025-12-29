#!/bin/bash

# Configure macOS to enable key repeat (disable press-and-hold for accented characters)
echo "⚙️  Configuring macOS settings..."
# enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false
echo "   Note: Restart your applications for this to take effect"
