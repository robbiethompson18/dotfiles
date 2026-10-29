# dotfiles

@~/.claude/personal-repo-rules.md

Robbie's dotfiles, synced across machines. macOS first, Linux supported. `cd bin && sh install.sh`
sets up a new machine; `new_laptop_setup.md` has the manual steps after that. `claude/CLAUDE.md` is
the global Claude Code config (symlinked to `~/.claude/CLAUDE.md` by `bin/setup-symlinks.sh`);
`claude/personal-repo-rules.md` holds the conventions that only apply in his personal repos.

## Docs

- [Claude settings — read before editing anything under claude/, or when a symlink into ~/.claude looks wrong](docs/claude-settings.md)
  — public-repo rule, the 2026-09-07 history purge, what setup-symlinks.sh links where
- [Kinesis keyboard — read before changing macro keys or the keyboard layout](kinesis/README.md)
  — hk→F-key map, v-Drive push workflow, layout file syntax

## Tests

Don't write tests in this repo. It's too small for them to pay off; verify changes by running them.
