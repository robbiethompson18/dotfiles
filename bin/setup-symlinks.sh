#!/bin/bash

# Creates a symlink, handling existing files, broken symlinks, and backups
# Usage: create_symlink <source> <target> <name>
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"

    if [ -L "$target" ]; then
        if [ -e "$target" ]; then
            # Update the symlink if it points somewhere else.
            local current
            current="$(readlink "$target")"
            if [ "$current" = "$source" ]; then
                echo "✅ $name symlink already exists"
            else
                echo "⚠️  $name symlink points to $current - updating to $source"
                rm "$target"
                ln -s "$source" "$target"
                echo "✅ Updated $name symlink"
            fi
        else
            echo "⚠️  $name symlink is broken - fixing it"
            rm "$target"
            ln -s "$source" "$target"
            echo "✅ Fixed $name symlink"
        fi
    elif [ -e "$target" ]; then
        echo "⚠️  Backing up existing $name to $name.backup"
        mv "$target" "$target.backup"
        ln -s "$source" "$target"
        echo "✅ Created $name symlink"
    else
        ln -s "$source" "$target"
        echo "✅ Created $name symlink"
    fi
}

# Shell config
mkdir -p "$HOME/.config/shell"
create_symlink "$HOME/repos/dotfiles/shell/common.sh" "$HOME/.config/shell/common.sh" "shared shell config"
create_symlink "$HOME/repos/dotfiles/.vimrc" "$HOME/.vimrc" ".vimrc"
create_symlink "$HOME/repos/dotfiles/.zshenv" "$HOME/.zshenv" ".zshenv"
create_symlink "$HOME/repos/dotfiles/.zshrc" "$HOME/.zshrc" ".zshrc"
create_symlink "$HOME/repos/dotfiles/.gitconfig" "$HOME/.gitconfig" ".gitconfig"

# Check that Claude exists, if not install it:
if ! command -v claude &> /dev/null; then
    echo "❌ Claude is not installed. Please install it first:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://github.com/anthropics/anthropic-sdk-cli/releases/download/v0.1.0/anthropic-cli-macos-arm64.tar.gz)\""
    echo "or install using brew: brew install claude"
    echo "or install using npm: npm install -g anthropic-sdk-cli"
    exit 1
fi

# Claude config. Two config dirs: ~/.claude (personal login) and ~/.claude-work (work
# login, used via the clw/clwr aliases in shell/common.sh). Claude Code keys the Keychain
# credential, .claude.json and session history to CLAUDE_CONFIG_DIR, so each dir holds
# its own account; everything else is the same files symlinked into both.
#
# Private companion repo (github.com/robbiethompson18/dotfiles-private).
#
# This repo is PUBLIC. Notes that name real infrastructure — AWS account IDs, work
# hosts, billing accounts — live in dotfiles-private instead. It is a separate repo
# rather than a gitignored directory so the notes still sync between machines.
PRIVATE_DIR="$HOME/repos/dotfiles-private"
if [ ! -d "$PRIVATE_DIR/.git" ]; then
    echo "⬇️  Cloning dotfiles-private"
    git clone git@github.com:robbiethompson18/dotfiles-private.git "$PRIVATE_DIR" 2>/dev/null
fi
if [ ! -d "$PRIVATE_DIR/.git" ]; then
    echo "ℹ️  No access to dotfiles-private - skipping global notes. Everything else works."
fi

for CLAUDE_DIR in "$HOME/.claude" "$HOME/.claude-work"; do
    mkdir -p "$CLAUDE_DIR"
    create_symlink "$HOME/repos/dotfiles/claude/settings.json" "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    create_symlink "$HOME/repos/dotfiles/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    create_symlink "$HOME/repos/dotfiles/claude/personal-repo-rules.md" "$CLAUDE_DIR/personal-repo-rules.md" "$CLAUDE_DIR/personal-repo-rules.md"
    create_symlink "$HOME/repos/dotfiles/claude/skills" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/skills"

    # The global CLAUDE.md sits at $CLAUDE_DIR/CLAUDE.md and its "## Docs" index links to
    # docs/*.md, which resolves relative to that file.
    if [ -d "$PRIVATE_DIR/.git" ]; then
        create_symlink "$PRIVATE_DIR/claude-notes" "$CLAUDE_DIR/docs" "$CLAUDE_DIR/docs (private)"
    fi

    # Plugins: only the small declarative manifests are tracked.
    # cache/, marketplaces/, installed_plugins.json, known_marketplaces.json are
    # auto-managed runtime state — Claude Code regenerates them per machine.
    mkdir -p "$CLAUDE_DIR/plugins"
    create_symlink "$HOME/repos/dotfiles/claude/plugins/blocklist.json" "$CLAUDE_DIR/plugins/blocklist.json" "$CLAUDE_DIR/plugins/blocklist.json"
    create_symlink "$HOME/repos/dotfiles/claude/plugins/config.json" "$CLAUDE_DIR/plugins/config.json" "$CLAUDE_DIR/plugins/config.json"
done

# Codex config. Two roots, mirroring ~/.claude and ~/.claude-work: config.toml,
# AGENTS.md and skills are shared, while auth.json and session history stay per-root
# so the work ChatGPT seat and the personal plan never share a quota window.
# Codex resolves all of this from $CODEX_HOME and errors if that path is missing,
# so the mkdir has to happen before any `codex` invocation against the work root.
for CODEX_DIR in "$HOME/.codex" "$HOME/.codex-work"; do
    mkdir -p "$CODEX_DIR"
    create_symlink "$HOME/repos/dotfiles/claude/CLAUDE.md" "$CODEX_DIR/AGENTS.md" "$CODEX_DIR/AGENTS.md"
    create_symlink "$HOME/repos/dotfiles/codex/config.toml" "$CODEX_DIR/config.toml" "$CODEX_DIR/config.toml"
done
"$HOME/repos/dotfiles/bin/sync-codex-claude-skills"

# VS Code config (used as the default file:// opener; see set-default-editor.sh)
mkdir -p "$HOME/Library/Application Support/Code/User"
create_symlink "$HOME/repos/dotfiles/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json" "VS Code settings.json"
create_symlink "$HOME/repos/dotfiles/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json" "VS Code keybindings.json"

# Hammerspoon config
create_symlink "$HOME/repos/dotfiles/hammerspoon" "$HOME/.hammerspoon" "Hammerspoon"

# Ghostty config
mkdir -p "$HOME/.config/ghostty"
create_symlink "$HOME/repos/dotfiles/ghostty/config" "$HOME/.config/ghostty/config" "Ghostty config"
