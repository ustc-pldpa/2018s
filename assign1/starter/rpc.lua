local util = require("common.util")
local posix = require("posix")
local Pipe = util.Pipe
local mod = {}

function mod.serialize(t)
    -- Your code here
	return nil
end


-- split by the first occurance
function mod.split2(str, pat) 
	local words = {}
	idx = string.find(str, pat)
	if idx == nil then
		return words
	end
	table.insert(words, string.sub(str, 1, idx - 1))
	table.insert(words, string.sub(str, idx + 1))
	return words
end


function mod.deserialize(s)
    -- Your code here
	return nil
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end


function mod.rpcify(class)
	local MyClassRPC = {}
    -- Your code here
	return MyClassRPC 
end


return mod
