-- util.lua
--
-- Define the functions set_color and set_pos so that they cache the strings
-- returned from tput in order to reduce the number of tput calls.


-- Local functions won't be globally visible after this script completes.

local cached_strs = {}  -- Maps cmd -> str.

local function cached_cmd(cmd)
  if not cached_strs[cmd] then
    -- XXX
    io.stderr:write('Starting the call ' .. cmd .. '\n')
    io.stderr:flush()
    local p = io.popen(cmd)
    io.stderr:write('{{1}}; p = ' .. tostring(p) .. '\n')
    io.stderr:flush()
    cached_strs[cmd] = p:read()
    io.stderr:write('{{2}}\n')
    io.stderr:flush()
    p:close()
    io.stderr:write('Finished the call ' .. cmd .. '\n')
    io.stderr:flush()
  end
  -- XXX
  if not cached_strs[cmd] then
    os.execute('stty cooked')
    os.execute('tput reset')
    print('Error! I ran "' .. cmd .. '" but I got nothing out of it!')
    os.exit()
  end
  io.write(cached_strs[cmd])
end


-- Global functions will remain visible after this script completes.

function set_color(b_or_f, color)
  assert(b_or_f == 'b' or b_or_f == 'f')
  cached_cmd('tput seta' .. b_or_f .. ' ' .. color)
end

function set_pos(x, y)
  cached_cmd('tput cup ' .. y .. ' ' .. x)
end

function clr()
  cached_cmd('tput clear')
end

function scrsize()
  local p
  p = io.popen('tput cols')
  local w = tonumber(p:read())
  p:close()

  p = io.popen('tput lines')
  local h = tonumber(p:read())
  p:close()

  return w, h
end
