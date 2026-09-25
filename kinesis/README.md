# Kinesis Freestyle Edge RGB

Mirror of the keyboard's v-Drive. The keyboard only sends plain keys; behavior lives in
`hammerspoon/init.lua`.

- hk1–hk5 → F16–F20, hk6–hk8 → F13–F15 (macOS has no keycodes past F20)
- caps → esc, right space → Shift+F9 (Hammerspoon Hyper mode)

Edit, then push:

1. SmartSet+F8 mounts the v-Drive as `/Volumes/FS EDGE RGB`
2. `kinesis-push` copies this folder onto it
3. SmartSet+F8 again unmounts; the keyboard reloads the layout

Syntax in `layouts/layoutN.txt`: `[a]>[b]` remaps a key; `{a}>{s9}{x1}{h}{i}` is a macro (`s` =
speed 1–9, `x` = repeat count, `{-shift}`/`{+shift}` = press/release). `settings/kbd_settings.txt`
picks the active layout (`startup_file=layout1.txt`).
