local rpc = require("starter.rpc")
local util = require("common.util")
local Pipe = util.Pipe

function table.equals(t1, t2)
	for k, _ in pairs(t1) do
		local b
		if type(t1[k]) == "table" then
			b = table.equals(t1[k], t2[k])
		else
			b = t1[k] == t2[k]
		end
		if not b then return false end
	end
	return true
end

function serialize_tests()
	function check(v)
		result = rpc.deserialize(rpc.serialize(v))
		if type(v) == "table" then
			assert(table.equals(v, result))
		else
			assert(v == result)
		end
	end

	check(0)
	check("Test")
	check(true)
	check(nil)
	check({a = nil})
	check({a = 1})
	check({a = "="})
	check({a = ","})
	check({a = "=", b = "#"})
	check({a = {b = 1}, c = 2})
end

function rpc_tests()
	local MyClass = {}

	function MyClass.new()
		return {counter = 0}
	end

	function MyClass.hello(t)
		return "Hi"
	end

	function MyClass.incr(t)
		t.counter = t.counter + 1
		return t.counter
	end

	local MyClassRPC = rpc.rpcify(MyClass)

	local inst = MyClassRPC.new()

	assert(MyClassRPC.hello(inst) == "Hi")

	local future = MyClassRPC.hello_async(inst)
	assert(future() == "Hi")

	assert(1 == MyClassRPC.incr(inst))
	assert(2 == MyClassRPC.incr(inst))

	MyClassRPC.exit(inst)
end

function rpc_tests_2()
	local MyClass = {}

	function MyClass.new()
		return {counter = 0}
	end

	function MyClass.hello(t, name)
		local ans = "Hi " .. name
		return ans 
	end

	function MyClass.incr(t, val)
		t.counter = t.counter + val
		return t.counter
	end

	local MyClassRPC = rpc.rpcify(MyClass)

	local inst = MyClassRPC.new()

	assert(MyClassRPC.hello(inst, "zr") == "Hi zr")

	local future = MyClassRPC.hello_async(inst, "zr")
	assert(future() == "Hi zr")

	assert(2 == MyClassRPC.incr(inst, 2))
	assert(5 == MyClassRPC.incr(inst, 3))

	MyClassRPC.exit(inst)
end

serialize_tests()
rpc_tests()
rpc_tests_2()
