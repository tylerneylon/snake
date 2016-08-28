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

local function pr_text()
  pr_center(spaceout('gaarlicbread'), -1)
  pr_center(spaceout('presents'), 1)
end


-- Public functions.

function intro.go()

  local timestep = 0.05

  for color = 232, 255 do
    set_color('f', color)
    pr_text()
    io.flush()
    sleep(timestep)
  end
  for color = 254, 232, -1 do
    set_color('f', color)
    pr_text()
    io.flush()
    sleep(timestep)
  end
  clr()
end

return intro
