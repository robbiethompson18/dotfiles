#!/bin/bash

# Configure macOS to enable key repeat (disable press-and-hold for accented characters)
echo "⚙️  Configuring macOS settings..."
# enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false
echo "   Note: Restart your applications for this to take effect"

# Keyboard Shortcuts -> Display: stop F14/F15 changing brightness so the Kinesis hk5/hk8 keys
# (which send F14/F15, see kinesis/README.md) reach Hammerspoon instead.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 53 '{enabled = 0; value = {parameters = (65535, 107, 8388608); type = standard;};}'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 54 '{enabled = 0; value = {parameters = (65535, 113, 8388608); type = standard;};}'
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
