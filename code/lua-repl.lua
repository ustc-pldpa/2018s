------ EXPRESSION BASICS ------
-- Most languages have a notion of expressions and statements.
-- Expressions are things that return a value, and statements are things that don't
-- Let's try to define basic expression syntax!
-- (WILL: write grammar on the board as you're going)

-- Basic variable assignment.
x = 1

-- Slots are mutable, you can reassign to them
x = x - 2

-- Printing is basic way to introspect state of things. Dynamically typed, so it can
-- take something of any type (but not necessarily print it in the nicest way).
print(x)

-- Functions are first class values! You can assign a variable to one just like a number.
add_one = function(x)
   return x + 1
end

-- Function calls work like you expect
print(add_one(x))

-- Other kinds of values
x = nil
x = true
x = "a string"

------ STATEMENT BASICS ------
-- Statements usually have side effects. They don't return a value.

-- The simplest form of statements is just sequencing. Do one thing after the other.
x = 1
x = 2

-- Otherwise, statements tend to focus on control flow.
y = 1000

-- If statements:
if y == 1000 then
   print("If branch")
else
   print("Else branch")
end

-- While loops:
y = 0
while y < 1000 do
   y = y + 1
end

-- For loops:
for y = 0, 1000 do
   print(y)
end

---- PAUSE: implement prime number sieve ----

function prime_numbers()
  local i = 2
  while true do
    local is_prime = true
    for j = 2, i / 2 do
      if i % j == 0 then
        is_prime = false
        break
      end
    end

    local j = i
    i = i + 1

    if is_prime then
      print(j)
    end
  end
end
prime_numbers()

------ SCOPING ------
-- Scoping is the notion of where a variable is visible to the program. Or another way,
-- when you write down a name, which variable does it refer to?
-- Lua has what's called "lexical" scoping, which basically means program is oriented
-- scoping blocks, and variables are only visible within their block after declaration.

-- Variable is visible here
local x = 1
print(x)

-- And not visible on the next call
print(x)

-- If statements define a new scope, as do functions
local z = 0
if true then
   local z = 1
   print(z)
   z = 2
   print(z)
end
print(z)

-- Note that new lexical bindings **shadow** existing ones, not overwrite them.
-- Within the if statement scope, z refers to a different slot in memory.
-- This is basically the right way to do scoping. The other kind is dynamic scoping,
-- which is achievable with global variables.

function foo()
  print(x)
end

x = 1
print(foo())

------ CLOSURES ------
-- One big difference between a language like C and Lua is that when variables go out
-- of scope in C, if you didn't allocate them on the heap, they're gone forever.
-- SEE: stack.c
-- However in Lua, because variables are garbage collected, which means they only go
-- away when there are no references left to them, you can keep them in scope forever,
-- which lets you do tricky things.

function make_counter()
   local counter = 0
   return function()
      counter = counter + 1
      return counter
   end
end
local ctr = make_counter()
print(ctr())
print(ctr())

-- Exercise: implement prime number generator

function prime_numbers()
  local i = 2
  return function()
    while true do
      local is_prime = true
      for j = 2, i / 2 do
        if i % j == 0 then
          is_prime = false
          break
        end
      end

      local j = i
      i = i + 1

      if is_prime then
        return j
      end
    end
  end
end

------ TABLES ------
-- Core data structure in Lua is a table. Any composite data type like a class or
-- a queue or stack or anything is made of a table. Tables are maps from keys to
-- values, also called a dictionary or associative array.

-- In the simplest case, Lua tables looks like arrays. As a dynamic language they can
-- hold any value. Keys are integers that start at 1!
x = {"c", "s", 2, 4, 2}
print(x[1])
print(x[5])


-- Alternative for loop syntax to iterate over a table
for k, v in pairs(x) do
   print(k, v)
end


-- Can assign string keys, various forms of syntactic sugar
x = {a = 1, b = 2}
print(x["a"], x.b)


-- We can use these primitives to develop a library of generic table functions,
-- for example "map" which applies a function to every pair in the table.
function map(t, f)
   for k, v in pairs(t) do
      t[k] = f(k, v)
   end
   return t
end
print(map(x, function(k, v) return v + 1; end))


------- ITERATORS -------
-- For loops don't just work for tables, they work on "iterators." Common concept in
-- many languages, expressing a (potentially infinite) stream of data. Iterator is
-- a function that takes no arguments and produces an output or nil for EOF. We can
-- reuse our prime_numbers function from before as an iterator!

for p in prime_numbers() do
  print(p)
end

-- For loops are just one of several examples in Lua of **syntactic sugar**. Let's
-- imagine Lua without for loops, how could we recreate it?
-- Exercise: write the for_loop function below

function for_loop(iter, body)
  while true do
    local x = iter()
    if x == nil then break end
    body(x)
  end
end

for_loop(prime_numbers(), function(p) print(p) end)


------- CLASSES AND MODULES -------
-- Tables are the fundamental unit of organization. We can use them to make something
-- that looks like a class in a traditional OOP language:

Matrix = {}

-- Tables can hold functions as values
Matrix.new = function(r, c)
   local t = {r = r, c = c, data = {}}
   for i = 1, r do
      t.data[i] = {}
      for j = 1, c do
         data[i][j] = 0
      end
   end
   return t
end

-- Syntactic suggar for assigning table functions
-- Core idea for classes is that we take the object as the first argument
function Matrix.get(m, i, j)
   return m.data[i][j]
end

function Matrix.add(m1, m2)
   local m3 = Matrix.new(m1.r, m2.r)
   assert(m1.r == m2.r and m1.c == m2.c)
   for i = 1, m1.r do
      for j = 1, m1.c do
         m3.data[i][j] = Matrix.get(m1, i, j) + Matrix.get(m2, i, j)
      end
   end
   return m3
end

m1 = Matrix.new(2, 3)
m2 = Matrix.new(2, 3)
m3 = Matrix.add(m1, m2)

---- METATABLES ----
-- Lastly, and very importantly, Lua has a powerful metaprogramming mechanism for
-- overriding default functionality on tables, called metatables. These contain functions
-- that implement indexing, adding, etc.

t = {}
function __index(t, k)
   print('__index', t, k)
   return 0
end

print(t.a)
setmetatable(t, {__index = __index})
print(t.a)
print(t[1])


-- We can use metatables to simulate classes.
Matrix = {}

function Matrix.new(r, c)
   local t = {r = r, c = c, data = {}}
   for i = 1, r do
      t.data[i] = {}
      for j = 1, c do
         data[i][j] = 0
      end
   end
   -- KEY IDEA: set a lookup pointer from instance to class definition
   setmetatable(t, {__index = Matrix})
   return t
end

function Matrix.get(m, i, j)
   return m.data[i][j]
end

-- How can we get around the gross m.get(m) issue? Next week!
m = Matrix.new(2, 3)
print(m.get(m, 1, 1))

-- Exercise: write a fibonacci table with __index metamethod
fib = {}
function fib_index(t, k)
  if k == 0 or k == 1 then
    return k
  else
    return t[k-1] + t[k-2]
  end
end
setmetatable(fib, {__index = fib_index})

print(fib[30])

-- Now we've learned the whole language!
