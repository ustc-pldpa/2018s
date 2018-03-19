class = require "../class"
local Point = require 'point'
local NativePoint = require 'native_point'

function sanitycheck(name, func)
  local luares = func(Point)
  local nativeres = func(NativePoint)
  if luares ~= nativeres then
    print("Failed " .. name .. " sanity check.")
    print("Expected:",  luares, "Got:", nativeres)
  end
end

sanitycheck("Point Distance", function (Point)
  return Point.new(64, 59):Dist(Point.new(98, 70)) end)

sanitycheck("Point:X()", function (Point) return Point.new(64, 59):X() end)
sanitycheck("Point:Y()", function (Point) return Point.new(64, 59):Y() end)

sanitycheck("Point:SetX()", function (Point)
  local p = Point.new(64, 59):SetX(34)
  return tostring(p)
end)
sanitycheck("Point:SetY()", function (Point)
  local p = Point.new(64, 59):SetY(34)
  return tostring(p)
end)

sanitycheck("Point +", function (Point)
 return tostring(Point.new(64, 59) + Point.new(98, 70)) end)
sanitycheck("Point -", function (Point)
 return tostring(Point.new(64, 59) - Point.new(98, 70)) end)

sanitycheck("Point tostring", function (Point)
 return tostring(Point.new(64, 59)) end)

function benchmark(name, func, count)
  print("===== " .. name .. " (" .. count .. " iterations) " .. " =====")

  local a, b = Point.new(64, 59), Point.new(98, 70)
  local na, nb = NativePoint.new(64, 59), NativePoint.new(98, 70)

  local clock = os.clock

  local start = clock()
  for i=1, count do func(a, b, Point) end
  local lua_duration = clock() - start

  local start = clock()
  for i=1, count do func(na, nb, NativePoint) end
  local native_duration = clock() - start

  print("Pure Lua:", lua_duration)
  print("C Extension:", native_duration)
end

benchmark('Point Creation', function(a, b, Point)
  local res = Point.new(64, 59)
end, 500000)

benchmark('Point Property Access', function(a, b)
  local x, y = a:X(), a:Y()
  local x, y = b:X(), b:Y()
end, 500000)

benchmark('Point Arithmetic', function(a, b)
  local res = a + b
  local res = a - b
end, 200000)

benchmark('Point Distance', function(a, b)
  local res = a:Dist(b)
end, 500000)

benchmark('Point Equality', function(a, b)
  local res = a == b
  local res = a == a
  local res = b == b
end, 500000)

benchmark('Point To String (Lua)', function(a, b)
  local res = tostring(a)
  local res = tostring(b)
end, 500000)
