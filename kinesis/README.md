# Kinesis Freestyle Edge RGB

Mirror of the keyboard's v-Drive. The keyboard only sends plain keys; behavior lives in
`hammerspoon/init.lua`.

- hk1–hk4 → F16–F19, hk5 → F14, hk6 → F13, hk7 → F20, hk8 → F15 (macOS has no keycodes past F20)
- macOS binds F14/F15 to display brightness down/up, so keep anything you actually use off hk5/hk8
- hk7 (F20) is Wispr Flow push-to-talk, bound in Wispr's own settings; Hammerspoon binds F20 to a
  no-op so the key never reaches apps (iTerm would type F20's escape sequence)
- caps → esc, right space → Shift+F9 (Hammerspoon Hyper mode)

Edit, then push:

1. SmartSet+F8 mounts the v-Drive as `/Volumes/FS EDGE RGB`
2. `kinesis-push` copies this folder onto it
3. SmartSet+F8 again unmounts; the keyboard reloads the layout

Syntax in `layouts/layoutN.txt`: `[a]>[b]` remaps a key; `{a}>{s9}{x1}{h}{i}` is a macro (`s` =
speed 1–9, `x` = repeat count, `{-shift}`/`{+shift}` = press/release). `settings/kbd_settings.txt`
picks the active layout (`startup_file=layout1.txt`).
