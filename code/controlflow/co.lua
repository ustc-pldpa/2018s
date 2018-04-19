-------- COROUTINES: motivating example --------

local t = {1, 2, 3, 4, 5, 6}

-- Simple for loop getting even-numbered indices
for i = 1, #t, 2 do
  print(t[i])
end

-- We want to convert that loop into an iterator. If we just naively copy it
-- into a function, this would be the result:
local function even(t)
  return function()
    for i = 1, #t, 2 do
      return t[i]
    end
  end
end

-- Prints 1 infinitely :(
for x in even(t) do
  print(x)
end

-- We can fix the iterator by changing the structure of the computation. Can't
-- use a for loop anymore.
local function even(t)
  local i = 1
  return function()
    local x = t[i]
    i = i + 2
    return x
  end
end

-- But... what if we could keep using our for loop? The code would be clearer.
-- Luckily, we can with coroutines!
local function even(t)
  return coroutine.wrap(function()
    for i = 1, #t, 2 do
      coroutine.yield(t[i])
    end
  end)
end

-------- COROUTINES: introduction --------

-- Coroutines wrap a function and turn it into a Lua "thread".
local co = coroutine.create(function()
    print("hi")
end)

print(co) -- thread
print(coroutine.status(co)) -- suspended
coroutine.resume(co) -- prints "hi"
print(coroutine.status(co)) -- dead

-- Coroutines are *resumable computations*. When a coroutine yields, it
-- halts the function, and waits to be resumed.
local t = {1, 2, 3, 4, 5, 6}
local co = coroutine.create(function()
    for i = 1, #t do
      print(t[i])
      coroutine.yield()
    end
end)

coroutine.resume(co)
coroutine.resume(co)

-- The yield function can return a value back to whoever called resume.
local co = coroutine.create(function()
    for i = 1, #t do
      coroutine.yield(t[i])
    end
end)

print(coroutine.resume(co))
print(coroutine.resume(co))

-- We can use coroutines to implement the even iterator.
local function even(t)
  local co = coroutine.create(function()
      for i = 1, #t do
        coroutine.yield(t[i])
      end
  end)
  return function()
    local status, value = coroutine.resume(co)
    return value
  end
end

for x in even(t) do
  print(x)
end

-- The code is a little verbose--the Lua library offers a function
-- coroutine.wrap that turns a coroutined function into an iterator.
local function even(t)
  return coroutine.wrap(function()
      for i = 1, #t do
        coroutine.yield(t[i])
      end
  end)
end


-------- COROUTINES: producer/consumer --------

-- Another good example of coroutines is the producer/consumer pattern.
-- Imagine two independent threads of control, one producing things (like
-- reading lines from stdin) and the other consuming the things (like echoing
-- the lines). Logically, these are both "while loop" functions in that they
-- run independently forever. However, if we just do this...

local function producer()
  while true do
    local x = io.read()
    -- pass x to consumer?
  end
end

local function consumer()
  while true do
    local x -- get from the producer?
    print(x)
  end
end

-- Which function do we call? producer()? consumer()? In either case, we'd
-- only end up running one actor, not both. Instead, we can use coroutines to
-- maintain the same program structure while passing control between the
-- functions.

local producer = coroutine.create(function()
    while true do
      local x = io.read()
      coroutine.yield(x)
    end
end)

local map = coroutine.create(function()
    local line = 1
    while true do
      local _, x = coroutine.resume(producer)
      x = string.format("%5d %s", line, x)
      coroutine.yield(x)
      line = line + 1
    end
end)

local function consumer()
  while true do
    local _, x = coroutine.resume(map)
    print(x)
  end
end

consumer()
