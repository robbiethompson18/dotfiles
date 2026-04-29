#!/bin/bash
# Set VS Code as the default app for code/text files (so clicking
# file:// links from Claude Code, etc., opens VS Code instead of Cursor).

set -e

echo "📝 Setting VS Code as default editor for code/text files..."

command -v duti >/dev/null || brew install duti

EXTS=(ts tsx js jsx mjs cjs json jsonl md mdx py rb go rs sh bats yml yaml \
      toml css scss sql csv txt astro prisma log xml)

for ext in "${EXTS[@]}"; do
  duti -s com.microsoft.VSCode ".$ext" all 2>/dev/null || echo "   skipped .$ext"
done

echo "   Done. (.html is gated by macOS — change manually via Get Info if you want it.)"
