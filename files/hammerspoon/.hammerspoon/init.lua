-- hs.loadSpoon("WindowHalfsAndThirds")
-- spoon.WindowHalfsAndThirds:bindHotkeys(spoon.WindowHalfsAndThirds.defaultHotkeys)

todoistWidth = 5/24
fantasticalWidth = 19/40
messagesWidth = fantasticalWidth - todoistWidth

units = {
  fullscreen  = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },

  left33     = { x = 0.00, y = 0.00, w = 1/3, h = 1.00 },
  left50     = { x = 0.00, y = 0.00, w = 1/2, h = 1.00 },
  left66     = { x = 0.00, y = 0.00, w = 2/3, h = 1.00 },
  left75     = { x = 0.00, y = 0.00, w = 3/4, h = 1.00 },
  right33      = { x = 2/3, y = 0.00, w = 1/3, h = 1.00 },
  right50      = { x = 1/2, y = 0.00, w = 1/2, h = 1.00 },
  right66      = { x = 1/3, y = 0.00, w = 2/3, h = 1.00 },
  right75      = { x = 1/4, y = 0.00, w = 3/4, h = 1.00 },

  upright2  = { x = 1/2, y = 0.00, w = 1/2, h = 1/2 },
  botright2 = { x = 1/2, y = 1/2, w = 1/2, h = 1/2 },
  upleft2   = { x = 0.00, y = 0.00, w = 1/2, h = 1/2 },
  botleft2  = { x = 0.00, y = 1/2, w = 1/2, h = 1/2 },

  upright3  = { x = 2/3, y = 0.00, w = 1/3, h = 1/2 },
  botright3 = { x = 2/3, y = 1/2, w = 1/3, h = 1/2 },
  upmid3    = { x = 1/3, y = 0.00, w = 1/3, h = 1/2 },
  botmid3   = { x = 1/3, y = 1/2, w = 1/3, h = 1/2 },
  upleft3   = { x = 0.00, y = 0.00, w = 1/3, h = 1/2 },
  botleft3  = { x = 0.00, y = 1/2, w = 1/3, h = 1/2 },

  todoist  = { x = 1/2, y = 1/2+0.1, w = todoistWidth, h = 1/2 },
  fantastical  = { x = 1/2, y = 0.0, w = fantasticalWidth, h = 1/2 },
  messages  = { x = 1/2+todoistWidth, y = 1/2, w = messagesWidth, h = 1/2 },
}

rightCycle = {
  units.right33,
  units.right50,
  units.right66,
  units.right75
}

leftCycle = {
  units.left33,
  units.left50,
  units.left66,
  units.left75
}

function cycleRight(window) 
  current = window_rect(window)
  for index in pairs(rightCycle) do  
    possible = hs.geometry.new(rightCycle[index])
    if match(current, possible) then
      next = rightCycle[index+1]
      if next == nil then
        next = rightCycle[1]
      end
      window:move(next, nil, true)
      return
    end
  end
  window:move(rightCycle[1], nil, true)
end

function cycleLeft(window) 
  current = window_rect(window)
  for index in pairs(leftCycle) do  
    possible = hs.geometry.new(leftCycle[index])
    if match(current, possible) then
      next = leftCycle[index+1]
      if next == nil then
        next = leftCycle[1]
      end
      window:move(next, nil, true)
      return
    end
  end
  window:move(leftCycle[1], nil, true)
end

function match(first, second) 
  return round(first.x, 2) == round(second.x, 2) and
    round(first.y, 2) == round(second.y, 2) and
    round(first.w, 2) == round(second.w, 2) and
    round(first.h, 2) == round(second.h, 2) 
end

shiftIt = { 'ctrl', 'alt', 'cmd' }

hs.hotkey.bind(shiftIt, "Right", function() cycleRight(hs.window.focusedWindow()) end)
hs.hotkey.bind(shiftIt, "Left", function() cycleLeft(hs.window.focusedWindow()) end)

hs.hotkey.bind(shiftIt, "Up", function() hs.window.focusedWindow():move(units.fullscreen,    nil, true) end)
hs.hotkey.bind(shiftIt, '1', function() hs.window.focusedWindow():move(units.upleft2,    nil, true) end)
hs.hotkey.bind(shiftIt, '2', function() hs.window.focusedWindow():move(units.upright2,    nil, true) end)
hs.hotkey.bind(shiftIt, '3', function() hs.window.focusedWindow():move(units.botleft2,     nil, true) end)
hs.hotkey.bind(shiftIt, '4', function() hs.window.focusedWindow():move(units.botright2,     nil, true) end)

hs.hotkey.bind(shiftIt, '5', function() hs.window.focusedWindow():move(units.upleft3,    nil, true) end)
hs.hotkey.bind(shiftIt, '6', function() hs.window.focusedWindow():move(units.botleft3,     nil, true) end)
hs.hotkey.bind(shiftIt, '7', function() hs.window.focusedWindow():move(units.upmid3,    nil, true) end)
hs.hotkey.bind(shiftIt, '8', function() hs.window.focusedWindow():move(units.botmid3,     nil, true) end)
hs.hotkey.bind(shiftIt, '9', function() hs.window.focusedWindow():move(units.upright3,    nil, true) end)
hs.hotkey.bind(shiftIt, '0', function() hs.window.focusedWindow():move(units.botright3,     nil, true) end)
hs.hotkey.bind(shiftIt, 't', function() hs.window.focusedWindow():move(units.todoist,     nil, true) end)
hs.hotkey.bind(shiftIt, 'f', function() hs.window.focusedWindow():move(units.fantastical,     nil, true) end)
hs.hotkey.bind(shiftIt, 'm', function() hs.window.focusedWindow():move(units.messages,     nil, true) end)

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- require('keyboard') -- Load Hammerspoon bits from https://github.com/jasonrudolph/keyboard

-- stolen from WindowHalfsAndThirds spoon that might resolve me comparision
function window_rect(win)
  local size = win:screen():toUnitRect(win:frame())
   -- return {round(size.x,2), round(size.y,2), round(size.w,2), round(size.h,2)} -- an hs.geometry.unitrect table
  return size
end

function round(num)
  return math.floor(num*10 + 1/2)
end
