-- Rex keybindings carried over from tmux (see programs.tmux in
-- home/modules/base/default.nix). Only the bindings that need no prefix are
-- here, so Ctrl+B still reaches tmux running inside Rex.

local terminal = "com.superlogical.terminal"

-- Move focus to the nearest pane in a direction.
rex.action{
  name  = "focus_direction",
  title = "Focus Pane in Direction",
  args  = { direction = "string" },
  run   = function(ctx, args)
    local _, err = rex.session.focus_direction{ direction = args.direction }
    if err ~= nil then error(err, 0) end
  end,
}

-- Alt+arrows move between panes (tmux: bind-key -n M-<arrow> select-pane)
for _, direction in ipairs{ "left", "right", "up", "down" } do
  rex.bind("alt+" .. direction, "focus_direction", { direction = direction })
end

-- Shift+Left/Right switch windows (tmux: previous-window / next-window)
rex.bind("shift+left", "client.tab.previous")
rex.bind("shift+right", "client.tab.next")

-- Ctrl+h/j/k/l, as vim-tmux-navigator does in tmux: when Vim or Neovim is in
-- the foreground the key goes to the editor, otherwise focus moves to the
-- neighbouring pane. The editor can't yet hand focus back to Rex at the edge
-- of its splits; see crdant/dotfiles#353.
local function editor_in_foreground(ctx)
  local info = rex.block.call(terminal, "process", { block_id = ctx.block_id })
  local fg = info and info.foreground
  if fg == nil then return false end
  -- Nix wraps editors, so also accept names like .nvim-wrapped
  local name = (fg.name or ""):gsub("^%.", ""):gsub("%-wrapped$", "")
  return name == "vim" or name == "nvim" or name == "vi"
      or name == "view" or name == "vimdiff" or name == "nvimdiff"
end

local navigation = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(navigation) do
  rex.bind("ctrl+" .. key, function(ctx, ev)
    if editor_in_foreground(ctx) then
      return false -- let the editor have the key
    end
    rex.session.focus_direction{ direction = direction }
    return true
  end)
end
