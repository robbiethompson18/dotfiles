-- Hammerspoon Configuration
-- Hyper Mode: Press Shift+F9 (right space) to enter, Escape or Shift+F9 to exit

--------------------------------------------------------------------------------
-- SETTINGS
--------------------------------------------------------------------------------

hs.window.animationDuration = 0

--------------------------------------------------------------------------------
-- HYPER MODE (Modal)
--------------------------------------------------------------------------------

local hyperMode = hs.hotkey.modal.new({"shift"}, "F9")

function hyperMode:entered()
  hs.alert.show("Hyper Mode ON", 0.5)
end

function hyperMode:exited()
  hs.alert.show("Hyper Mode OFF", 0.5)
end

-- Exit with Escape or Shift+F9 again
hyperMode:bind("", "escape", function() hyperMode:exit() end)
hyperMode:bind({"shift"}, "F9", function() hyperMode:exit() end)

--------------------------------------------------------------------------------
-- RELOAD CONFIG
--------------------------------------------------------------------------------

hyperMode:bind("", "R", function()
  hyperMode:exit()
  hs.reload()
end)

hs.alert.show("Hammerspoon loaded")

--------------------------------------------------------------------------------
-- WINDOW MANAGEMENT (using Rectangle for positioning)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- WINDOW CYCLING (Vim-style J/K)
--------------------------------------------------------------------------------

local function cycleAppWindows(direction)
  local win = hs.window.focusedWindow()
  if not win then return end

  local app = win:application()
  if not app then return end

  local windows = app:allWindows()
  local visibleWindows = {}
  for _, w in ipairs(windows) do
    if w:isStandard() and w:isVisible() then
      table.insert(visibleWindows, w)
    end
  end

  if #visibleWindows < 2 then return end

  local currentIndex = 1
  for i, w in ipairs(visibleWindows) do
    if w:id() == win:id() then
      currentIndex = i
      break
    end
  end

  local nextIndex
  if direction == "next" then
    nextIndex = currentIndex % #visibleWindows + 1
  else
    nextIndex = (currentIndex - 2) % #visibleWindows + 1
  end

  visibleWindows[nextIndex]:focus()
end

hyperMode:bind("", "J", function()
  cycleAppWindows("next")
  hyperMode:exit()
end)

hyperMode:bind("", "K", function()
  cycleAppWindows("prev")
  hyperMode:exit()
end)

-- Arrow keys for moving window between monitors
hyperMode:bind("", "Right", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToScreen(win:screen():previous())
end)

hyperMode:bind("", "Left", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToScreen(win:screen():next())
end)

--------------------------------------------------------------------------------
-- APP LAUNCHERS
--------------------------------------------------------------------------------

local appBindings = {
  I = "iTerm",
  G = "Google Chrome",
  C = "Cursor",
  S = "Slack",
  M = "Messages",
  N = "Notes",
  W = "WhatsApp",
}

for key, app in pairs(appBindings) do
  hyperMode:bind("", key, function()
    hs.application.launchOrFocus(app)
    hyperMode:exit()
  end)
end

--------------------------------------------------------------------------------
-- MONITOR FOCUS (move mouse to monitor)
--------------------------------------------------------------------------------

local function getScreensSortedLeftToRight()
  local screens = hs.screen.allScreens()
  table.sort(screens, function(a, b)
    return a:frame().x < b:frame().x
  end)
  return screens
end

local function focusScreen(screenIndex)
  local screens = getScreensSortedLeftToRight()
  if screenIndex > #screens then return end

  local screen = screens[screenIndex]
  local frame = screen:frame()
  local center = {
    x = frame.x + frame.w / 2,
    y = frame.y + frame.h / 2
  }

  hs.mouse.absolutePosition(center)
  hs.alert.show("Monitor " .. screenIndex .. ": " .. screen:name(), 0.5)
end

-- 1, 2, 3, 4 to focus monitors
hyperMode:bind("", "1", function() focusScreen(1) end)
hyperMode:bind("", "2", function() focusScreen(2) end)
hyperMode:bind("", "3", function() focusScreen(3) end)
hyperMode:bind("", "4", function() focusScreen(4) end)
