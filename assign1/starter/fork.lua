local util = require("common.util")
local posix = require("posix")
local Pipe = util.Pipe

local pipe = Pipe.new()
local pid = posix.fork()

if pid == 0 then
   -- Child process
   Pipe.write(pipe, "I am the child!")
else
   -- Parent process
   print("Child says: " .. Pipe.read(pipe))
   posix.wait(pid)
end
