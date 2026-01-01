# 1) Mac Settings: 
* increase typing speed to max 
* mouse speed to fourth from max
* Caps lock mapped to escape
* Have doc disappear, move between monitors, make it small 

# 2) Run install.sh, Change App Settings
Just run `cd bin && sh install.sh` from the root of this repo. 

This will download:
* Chrome
* Rectangle 
   - Launch this, then in the dock, right click on the icon and select "Open at Login"
* Iterm2 
   - settings -> keys -> navigation shortcuts: option to select a tab, command to select a split pane.
   - launch on login and keep in dock
* Cursor (settings/keybindings symlinked by install.sh)
   - Install extensions: `./bin/install-cursor-extensions.sh` 
   

### What happens in install.sh? 
* Install Homebrew
* Install fzf
* Install ohmyzsh and add-ons (ie autocomplete suggestions)
    - this gives nice things like a terminal that has git status and current repo, fuzzy finding old bash commands, etc. 
* Make .zshrc a symlink to the one in this repo
    - So that to update zshrc you can just pull from this repo.
* Make Claude global settings and plugins symlinks to this repo
    - Likewise about just pulling to update. Not sure if this works perfectly yet.
* Holding down keys works as you'd think, ie actually repeats the key (ran: `defaults write -g ApplePressAndHoldEnabled -bool false`)
* Install launchd agent that auto-pulls this repo weekly (catches up after sleep/shutdown)
