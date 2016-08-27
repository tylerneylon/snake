-- intro.lua
--
-- Code to draw an intro animation
-- for the snake game.
--

local intro = {}


-- Internal globals.

local w, h


-- Internal functions.

-- Add spaces between every letter of the given string.
local function spaceout(s)
  return s:gsub('.', '%1 '):sub(1, -2)
end

-- Print a string in the middle of the screen.
local function pr_center(s, y_offset)

  y_offset = y_offset or 0

  if w == nil then
    w, h = scrsize()
  end

  local margin = math.floor((w - #s) / 2)
  local y_mid  = math.floor(h / 2)
  set_pos(margin, y_mid + y_offset)
  io.write(s)
end


-- Public functions.

function intro.go()
  pr_center(spaceout('gaarlicbread'), -1)
  pr_center(spaceout('presents'), 1)
  io.flush()
  sleep(1)
  clr()
end

return intro
