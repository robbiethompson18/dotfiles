# Applications to download:
* Chrome
* Rectangle (launch on login)
* Homerow (empirically I haven't been using this)
* Iterm2 
   - settings -> keys -> navigation shortcuts: option to select a tab, command to select a split pane.
* Cursor
   - settings -> autosave -> on (once a second or something)
* Claude

# Mac Settings: 
* increase typing speed to max 
* mouse speed to fourth from max
* Caps lock mapped to escape
* Holding down keys works:defaults write -g ApplePressAndHoldEnabled -bool false
          @ Claude please make syntax nice on the above, ie put in code block.
# Have doc disappear, move between monitors, make it small 

# Run install.sh

Just run `./install.sh` from the root of this repo. 

## What happens in install.sh? 
* Install Homebrew
* Install fzf
* Install ohmyzsh and add-ons (ie autocomplete suggestions)
    - this gives nice things like a terminal that has git status and current repo, fuzzy finding old bash commands, etc. 
* Make .zshrc a symlink to the one in this repo
    - So that to update zshrc you can just pull from this repo.
* Make Claude global settings and plugins symlinks to this repo
    - Likewise about just pulling to update. Not sure if this works perfectly yet.
