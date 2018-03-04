local MyClass = {}

function MyClass.new()
	return {counter = 0}
end

function MyClass.incr(t)
	t.counter = t.counter + 1
	return counter
end

for k, v in pairs(MyClass) do
	print("key: " .. k .. " type: " .. type(k))
	print("val: " .. tostring(v) .. " type: " .. type(v))
	print("")
end

