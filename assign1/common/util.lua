local unistd = require("posix.unistd")

local mod = {}

function mod.print_table(t)
  function pr(t, i)
    local spacing = " "
    spacing = spacing:rep(i*2)
    for k, v in pairs(t) do
      if type(v) == "table" then
        print(spacing .. k .. " = {")
        pr(v, i + 1)
        print(spacing .. "}")
      else
        print(spacing .. k .. " = " .. v)
      end
    end
  end
  pr(t, 0)
end


-- mod.parens("(a)(bc)(d)") == {"a", "bc", "d"}
function mod.parens(s)
  local idx = 1
  local parts = {}
  while true do
    local start_idx = idx
    local ctr = 0
    repeat
      if idx > s:len() then
        return parts
      end
      if s:sub(idx, idx) == "(" then
        ctr = ctr + 1
      elseif s:sub(idx, idx) == ")" then
        ctr = ctr - 1
      end
      idx = idx + 1
    until ctr == 0
    table.insert(parts, s:sub(start_idx+1, idx-2))
  end
end


local Pipe = {}
function Pipe.new()
  local read, write = unistd.pipe()
  return {read_fd = read, write_fd = write}
end

-- Non-blocking write.
function Pipe.write(p, s)
  return unistd.write(p.write_fd, s)
end

-- Blocking read.
function Pipe.read(p, size)
  return unistd.read(p.read_fd, size or 1024)
end

mod.Pipe = Pipe

return mod
