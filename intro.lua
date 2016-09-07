-- intro.lua
--
-- Code to draw an intro animation
-- for the snake game.
--

local intro = {}


-- Internal globals.

local w, h
local s = '-----------------------------==============#'

-- XXX
local function dbg_pr(s)
  io.stderr:write(s .. '\n')
  io.stderr:flush()
end


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

local function draw_streak(opts)

  if w == nil then
    w, h = scrsize()
  end

  -- Parse out opts.
  local x_right  = opts.x_right
  local y_offset = opts.y_offset
  local prefix   = opts.prefix or 0

  local is_pos_set = false

  -- We'll draw a string with a certain grayscale curve.
  -- The grayscale colors have codes 232-255; that's 24 values.
  -- We'll let the value 25 indicate full white, which is 231.
  set_color('b', 0)
  for i = 1 - prefix, #s do
    local x = x_right - #s + i
    if 0 <= x and x < w then
      if not is_pos_set then
        local y_mid = math.floor(h / 2)
        set_pos(x, y_mid + y_offset)
        is_pos_set = true
        set_color('b', 0)
      end
      if i < 1 then
        io.write(' ')
      else
        local perc  = i / #s
        local color = math.floor(24 * perc)  -- Values [0, 24].
        if color == 24 then
          --set_color('b', 231)  -- Full white background (for the space).
          set_color('f', 231)  -- Full white.
        else
          set_color('f', 232 + color)
        end
        io.write(s:sub(i, i))
      end
    end
  end
  io.flush()
end

local function intro1()
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
end

-- Draw the string s, centered, but omit any suffix with
-- x coordinates >= x_max.
local function draw_mid_str_till(str, x_max, y_offset, shader)
  dbg_pr('[[5]]')
  str = spaceout(str)
  local x_left = math.floor((w - #str) / 2)
  local y_mid  = math.floor(h / 2)
  local y      = y_mid + y_offset
  dbg_pr('[[6]]')
  set_pos(x_left, y)
  for x = x_left, x_max do
    set_color('f', shader(x, y))
    io.write(str:sub(x - x_left + 1, x - x_left + 1))
  end
  dbg_pr('[[7]]')
  --io.write(str:sub(1, x_max - x_left + 1))
end


-- Public functions.

function intro.go()

  w, h = scrsize()

  local x_right
  local function shader(x, y)
    x = x / w
    y = y / h
    local z = math.abs(x - y)
    z = math.min(10 * z, 1)
    return math.ceil(255 - z * 23)
  end

  -- This is temporary work on a new introduction animation.
  clr()
  local dx  =   3
  local lag = 200  -- Lag of the second streaker.
  dbg_pr('[[0]]')
  for x_right = 0, w + #s + lag + dx, dx do
    dbg_pr('[[1]]')
    draw_streak{x_right = x_right,       y_offset = -1, prefix = dx}
    draw_streak{x_right = x_right - lag, y_offset =  1, prefix = dx}
    set_color('f', 254)
    dbg_pr('[[2]]')
    draw_mid_str_till('gaarlicbread', x_right - #s,      -1, shader)
    dbg_pr('[[2.25]]')
    draw_mid_str_till('presents',     x_right - #s - lag, 1, shader)
    --sleep(0.001)
    dbg_pr('[[2.5]]')
    sleep(0.1)
    dbg_pr('[[3]]')
  end
  dbg_pr('[[4]]')
  sleep(1)

  set_color('b', 0)
  clr()
end

return intro
