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
-- WINDOW MANAGEMENT
--------------------------------------------------------------------------------

local function getWindowAndScreen()
  local win = hs.window.focusedWindow()
  if not win then return nil, nil end
  local screen = win:screen()
  local frame = screen:frame()
  return win, frame
end

-- Left half
hyperMode:bind("", "Left", function()
  local win, frame = getWindowAndScreen()
  if not win then return end
  win:setFrame({
    x = frame.x,
    y = frame.y,
    w = frame.w / 2,
    h = frame.h
  })
end)

-- Right half
hyperMode:bind("", "Right", function()
  local win, frame = getWindowAndScreen()
  if not win then return end
  win:setFrame({
    x = frame.x + frame.w / 2,
    y = frame.y,
    w = frame.w / 2,
    h = frame.h
  })
end)

-- Top half
hyperMode:bind("", "Up", function()
  local win, frame = getWindowAndScreen()
  if not win then return end
  win:setFrame({
    x = frame.x,
    y = frame.y,
    w = frame.w,
    h = frame.h / 2
  })
end)

-- Bottom half
hyperMode:bind("", "Down", function()
  local win, frame = getWindowAndScreen()
  if not win then return end
  win:setFrame({
    x = frame.x,
    y = frame.y + frame.h / 2,
    w = frame.w,
    h = frame.h / 2
  })
end)

-- Maximize
hyperMode:bind("", "return", function()
  local win, frame = getWindowAndScreen()
  if not win then return end
  win:setFrame(frame)
end)

-- Also bind M for maximize
hyperMode:bind("", "M", function()
  local win, frame = getWindowAndScreen()
  if not win then return end
  win:setFrame(frame)
end)

-- Center window (2/3 width)
hyperMode:bind("", "C", function()
  local win, frame = getWindowAndScreen()
  if not win then return end
  local newW = frame.w * 2 / 3
  local newH = frame.h * 2 / 3
  win:setFrame({
    x = frame.x + (frame.w - newW) / 2,
    y = frame.y + (frame.h - newH) / 2,
    w = newW,
    h = newH
  })
end)

-- Move to next screen
hyperMode:bind("", "N", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  win:moveToScreen(win:screen():next())
end)

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
end)

hyperMode:bind("", "K", function()
  cycleAppWindows("prev")
end)

--------------------------------------------------------------------------------
-- APP LAUNCHERS
--------------------------------------------------------------------------------

local appBindings = {
  I = "iTerm",
  C = "Google Chrome",
  U = "Cursor",
  S = "Slack",
}

for key, app in pairs(appBindings) do
  hyperMode:bind("", key, function()
    hs.application.launchOrFocus(app)
    hyperMode:exit()
  end)
end

-- P for previous window (same as K)
hyperMode:bind("", "P", function()
  cycleAppWindows("prev")
end)

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
