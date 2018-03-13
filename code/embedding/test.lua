local counter = require("counter")
for k, v in pairs(counter) do
  print(k, v)
end

local c = counter.new()
counter.incr(c)
print(counter.get(c))
