-- snake.lua

local snake = {}

-- Globals.

local grid                = nil       -- grid[x][y] = 'open', or falsy = a wall.
local grid_w, grid_h      = nil, nil
local player
local game_state          = 'playing'  -- or 'game over'
local apples              = {}
local new_apple           = nil
local prob_new_apple      = 0.04  -- Max is 1.0.

-- Colors.
local bg_color            = 234
local border_color        = 244
local player_color        =  33
local apple_color         = 166

-- Update parameters.
local move_delta          = 0.10  -- seconds (0.1 default)
local next_move_time      = nil


-- Debug globals and functions.

local pr_line = nil

local function pr(s)
  if pr_line == nil then
    pr_line = grid_h + 2
  end
  set_pos(0, pr_line)
  set_color('b', 0)
  io.write(s)
  pr_line = pr_line + 1
end


-- Internal functions.

local function is_in_bounds(x, y)
  return (1 <= x and x <= grid_w and
          1 <= y and y <= grid_h)
end

-- Check if a character can move in a given direction.
-- Return can_move, new_pos.
local function can_move_in_dir(character, dir)
  assert(type(dir) == 'table')
  local p = character.head
  local x, y = p[1] + dir[1], p[2] + dir[2]
  if not is_in_bounds(x, y) or grid[x][y] == 'snake' then
    return false
  end
  return true, {x, y}
end

local function has_cur_dir_taken_effect()
  local n = player.body[#player.body - 1]  -- neck
  if n == nil then return false end
  -- Compare the current dir with the last move made.
  local dir = player.dir
  local last = {player.head[1] - n[1], player.head[2] - n[2]}
  return dir[1] == last[1] and dir[2] == last[2]
end

local function update(state)

  -- Update the direction if an arrow key was pressed.
  local dir_of_key = {left = {-1, 0}, right = {1, 0},
                      up   = {0, -1}, down  = {0, 1}}
  if dir_of_key[state.key] then
    local d = dir_of_key[state.key]          -- d = direction
    local n = player.body[#player.body - 1]  -- n = neck

    -- Ignore turns that would result in death by eating your own neck.
    -- Also, if the current direction has not yet been used, then save
    -- the new direction until after that point.
    if (n == nil or
        not (player.head[1] + d[1] == n[1] and
             player.head[2] + d[2] == n[2])
       ) and has_cur_dir_taken_effect() then
      player.dir = d
      player.next_dir = nil
    else
      player.next_dir = d
    end
  end

  -- Only move every move_delta seconds.
  if next_move_time == nil then
    next_move_time = state.clock + move_delta
  end
  if state.clock < next_move_time then return end
  next_move_time = next_move_time + move_delta

  -- If there's a next_dir and we can turn in that dir, do so.
  if player.next_dir and
     has_cur_dir_taken_effect() and
     can_move_in_dir(player, player.next_dir) then
    player.dir = player.next_dir
    player.next_dir = nil
  end

  -- Move in direction player.dir if possible.
  local can_move, new_pos = can_move_in_dir(player, player.dir)
  if not can_move then
    game_state = 'game over'
  else
    if grid[new_pos[1]][new_pos[2]] == 'apple' then
      player.len = player.len + 1
    end
    player.head = new_pos
    table.insert(player.body, new_pos)
    grid[new_pos[1]][new_pos[2]] = 'snake'
    if player.num_drawn == player.len then
      local old = table.remove(player.body, 1)
      grid[old[1]][old[2]] = nil
      player.to_erase = old
    else
      player.num_drawn = player.num_drawn + 1
    end
  end

  -- Randomly add apples.
  if math.random() < prob_new_apple then
    local a
    repeat
      a = {math.random(grid_w), math.random(grid_h)}
    until not grid[a[1]][a[2]]
    grid[a[1]][a[2]] = 'apple'
    new_apple = a
    table.insert(apples, new_apple)
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

  -- Draw the new apple if there is one.
  if new_apple then
    draw_dot(new_apple, apple_color)
    new_apple = nil
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
