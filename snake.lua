-- snake.lua

local snake = {}

-- Globals.

local grid                = nil       -- grid[x][y] = 'open', or falsy = a wall.
local grid_w, grid_h      = nil, nil
local player
local game_state          = 'playing'  -- or 'game over'

local bg_color            = 234
local border_color        = 244
local player_color        =  33

-- Internal functions.

local function is_in_bounds(x, y)
  return (1 <= x and x <= grid_w and
          1 <= y and y <= grid_h)
end

-- Check if a character can move in a given direction.
-- Return can_move, new_pos.
local function can_move_in_dir(character, dir)
  local p = character.head
  local x, y = p[1] + dir[1], p[2] + dir[2]
  if not is_in_bounds(x, y) or (grid[x] and grid[x][y]) then
    return false
  end
  --return (grid[gx] and grid[gx][gy]), {gx, gy}
  -- TEMP TODO
  return true, {x, y}
end

local move_delta     = 0.1  -- seconds
local next_move_time = nil

local function update(state)

  -- Update the direction if an arrow key was pressed.
  local dir_of_key = {left = {-1, 0}, right = {1, 0},
                      up   = {0, -1}, down  = {0, 1}}
  local new_dir = dir_of_key[state.key]
  if new_dir then player.dir = new_dir end

  -- Only move every move_delta seconds.
  if next_move_time == nil then
    next_move_time = state.clock + move_delta
  end
  if state.clock < next_move_time then return end
  next_move_time = next_move_time + move_delta

  -- Move in direction player.dir if possible.
  local can_move, new_pos = can_move_in_dir(player, player.dir)
  if not can_move then
    game_state = 'game over'
  else
    player.head = new_pos
    table.insert(player.body, new_pos)
    grid[new_pos[1]][new_pos[2]] = true
    if player.num_drawn == player.len then
      local old = table.remove(player.body, 1)
      grid[old[1]][old[2]] = nil
      player.to_erase = old
    else
      player.num_drawn = player.num_drawn + 1
    end
  end
end

-- Accepts grid coordinates and draws a single
-- dot of the given color at that point.
local function draw_dot(pos, color)
  set_color('b', color)
  set_pos(2 * pos[1], pos[2])
  io.write('  ')
end

local function draw(clock)

  -- Draw the player's head.
  draw_dot(player.head, player_color)

  -- Erase the player's tail if appropriate.
  if player.to_erase then
    draw_dot(player.to_erase, bg_color)
    player.to_erase = nil
  end
end

-- Public functions.

function snake.init()

  -- Set up random number generation.
  math.randomseed(os.time())

  -- Set up the grid.
  grid_w, grid_h = 39, 23
  grid = {}
  for x = 1, grid_w do grid[x] = {} end
  
  -- Set up the player.
  local px, py = math.floor(grid_w / 2) + 1, math.floor(grid_h / 2) + 1
  player = {head      =  {px, py},
            body      = {{px, py}},  -- Index 1 is the tail here.
            dir       = { 1,  0},
            len       = 4,
            num_drawn = 1}

  -- Draw the initial borders.
  for y = 0, grid_h + 1 do
    for x = 0, grid_w + 1 do
      if (x == 0 or x == grid_w + 1 or
          y == 0 or y == grid_h + 1) then
        set_color('b', border_color)
      else
        set_color('b', bg_color)
      end
      io.write('  ')
    end
    io.write('\r\n')
  end
end

function snake.loop(state)
  update(state)
  draw(state.clock)
  return game_state
end

return snake
