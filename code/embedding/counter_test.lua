local counter = require "counter"
local c = counter.new()
counter.incr(c)
counter.incr(c)
print(counter.get(c))

local counter = {}
function counter.new()
    return {c = 0}
end

function counter.incr(c)
  c.c = c.c + 1
end

function counter.get(c)
  return c.c
end
