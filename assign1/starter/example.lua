local util = require("common.util")
local posix = require("posix")
local Pipe = util.Pipe

local in_pipe = Pipe.new()
local out_pipe = Pipe.new()

function child()
  local t = {
    counter = 0,
    incr = function(self)
      self.counter = self.counter + 1
    end,
    value = function(self)
      return self.counter
    end
  }

  -- TODO: What to do in the child? Fill this in yourself.
end

function parent(pid)
  Pipe.write(in_pipe, "incr")
  Pipe.read(out_pipe) -- return is nil, don't care

  Pipe.write(in_pipe, "value")
  print(Pipe.read(out_pipe)) -- should be 1

  Pipe.write(in_pipe, "exit") -- child should exit now
  posix.wait(pid)
end

local pid = posix.fork()
if pid == 0 then
  child()
else
  parent(pid)
end

