units = {
  upright    = { x = 0.70, y = 0.00, w = 0.33, h = 0.50 },
  botright    = { x = 0.70, y = 0.50, w = 0.33, h = 0.50 },
}
shiftIt = { 'ctrl', 'alt', 'cmd' }
hs.hotkey.bind(shiftIt, '5', function() hs.window.focusedWindow():move(units.upright,    nil, true) end)
hs.hotkey.bind(shiftIt, '6', function() hs.window.focusedWindow():move(units.botright,     nil, true) end)

require('keyboard') -- Load Hammerspoon bits from https://github.com/jasonrudolph/keyboard
