# 1) Mac Settings

- Increase key repeat speed to max
- Mouse speed to fourth from max
- Caps Lock mapped to Escape
- Dock: auto-hide, small, allowed on every monitor

# 2) Run install.sh

`cd bin && sh install.sh` from the root of this repo. It:

- Installs Homebrew, then fzf, direnv, Oh My Zsh (bira theme, autosuggestions, syntax
  highlighting; accept a suggestion with Shift+Tab, Ctrl+R for fuzzy history)
- Installs CLI tools: claude, codex, fnm, bun, pnpm, python, ripgrep, postgresql, pulumi, awscli
- Installs apps: Chrome, iTerm2, VS Code, Docker, Zoom, Claude Desktop, Maccy, Hammerspoon
- Makes VS Code the default opener for code/text files (so `file://` links from Claude open there)
- Disables macOS press-and-hold so holding a key repeats it
- Symlinks `.zshrc`, `.vimrc`, `.gitconfig`, Claude/Codex config, VS Code settings, Hammerspoon
  config and `.terraformrc` into this repo, so a `git pull` updates them
- Installs four launchd agents (`launchd/`, via `bin/install-launchd-agent`): weekly dotfiles pull,
  agent-reaper (lets Claude/Codex sessions retire themselves), oom-guard (kills runaway agent
  processes), disk-sweep (hourly scratchpad and Docker image cleanup). A fifth, main-checkout-pull,
  is installed by hand only on the Mac with the reference checkouts it keeps on origin/main

# 3) App settings after install

- Claude Code: log in once per account. `clp` then `/login` (personal, `~/.claude`), `clw`
  (work, `~/.claude-work`), `cls` (SPAR, `~/.claude-spar`).
- Hammerspoon: grant Accessibility (System Settings → Privacy & Security → Accessibility), then
  enable "Launch Hammerspoon at login" in its preferences. Does window snapping and the hotkeys.
- Maccy (clipboard history): Launch at login; popup hotkey Option+Command+C.
- iTerm2: Settings → Keys → Navigation Shortcuts: Command selects a tab, Option selects a split
  pane. Launch at login, keep in Dock. Profile settings sync via `iterm2/` (load from the plist).
- Kinesis keyboard: see `kinesis/README.md`.
