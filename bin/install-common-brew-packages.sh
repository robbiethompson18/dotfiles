#!/bin/bash

echo "Installing common brew packages..."
echo "  • claude"
brew install claude
echo "  • codex"
brew install codex
echo "  • fnm (node version manager)"
brew install fnm
echo "  • bun (via bun.sh installer)"
curl -fsSL https://bun.sh/install | bash
echo "  • pnpm"
brew install pnpm
echo "  • python"
brew install python
echo "  • ripgrep"
brew install ripgrep
echo "  • postgresql"
brew install postgresql
echo "  • pulumi"
brew install pulumi
echo "  • awscli"
brew install awscli
echo "  • visual-studio-code"
brew install --cask visual-studio-code