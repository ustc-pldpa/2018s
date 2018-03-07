------- CLOSURES AS OBJECTS ------
-- Let's say we didn't have tables in our language. We could use closures
-- to associate data with control as well as encapsulate an interface.

local function slot(value, incr)
  return function(k, v)
    if k == "get" then
      return value
    elseif k == "set" then
      value = v
    elseif k == "incr" then
      value = value + incr
    end
  end
end

local x = slot(0, 5)
print(x("get"))
x("set", 3)
print(x("get"))
x("incr")
print(x("get"))

------- TABLES AS OBJECTS -------
-- One problem is that what keys are valid is implicit in the code of the
-- function. This limits our ability for reuse, since we often need to know
-- which keys are defined for an object in order to reason about which
-- function to call. Let's make these keys explicit by using tables.

Account = {}

Account["balance"] = 0

Account["withdraw"] = function(v)
   Account["balance"] = Account["balance"] - v
end

Account["withdraw"](100.0)


-- This is pretty verbose, so we can add in syntactic sugar to make it look
-- prettier. Use symbols instead of strings and function expansion syntax.
Account = {balance = 0}
function Account.withdraw(v)
   Account.balance = Account.balance - v
end

Account.withdraw(100.0)


-- The issue here is that we have a basically a "singleton" class. There's
-- only one instance of it in the whole system, so if we nuke it, then
-- we're SOL.

a = Account
a.withdraw(100.0)
Account = nil
a.withdraw(100.0)


-- We can work around this by not using a global alias for the account, instead
-- asking people to give us a reference to the account.

Account = {balance = 0}
function Account.withdraw(self, v)
   self.balance = self.balance - v
end

a1 = Account
Account = nil
a1.withdraw(a1, 100.0)

a2 = {balance = 0, withdraw = Account.withdraw}
a2.withdraw(a2, 260.0)


-- We can simplify this kind of syntax by using colon syntactic sugar to
-- auto-add "self" to our function definitions, just like C++ and Java.

function Account:withdraw(v)
   self.balance = self.balance - v
end
a:withdraw(100.0)


-- Now we want to get rid of the singleton issue. Multiple accounts, of course!
-- So we need a way of making instances.

function Account.new(balance)
  return {balance = balance}
end

-- Note we can still use our old functions with the dot syntax! Colon
-- is just syntactic sugar
a = Account.new()
Account.withdraw(a, 5)


-- Now let's try to do inheritance. We can just copy pointers to methods!
function Account:print()
  print(self.balance)
end

LimitAccount = {}
for k, v in pairs(Account) do
  LimitAccount[k] = v
end

function LimitAccount.new()
  local acc = Account.new()
  acc.limit = 100
  return acc
end

function LimitAccount:withdraw(v)
  if v - self.balance >= self.limit then
    error "Insufficient funds"
  end

  self.balance = self.balance - v
end

local acc = LimitAccount.new()
LimitAccount.withdraw(acc, 5)
LimitAccount.print(acc)


-- Let's make this inheritance generic, basically a table copy.
function inherit(t)
  local new_t = {}
  for k, v in pairs(t) do
    new_t[k] = v
  end
end

LimitAccount = inherit(Account)

-- I think the only trade off here is that you if you inject new methods
-- to account after the time of inheritance, changes won't be reflected?


-------- "NORMAL" OOP -------
-- We want to associate methods directly with objects instead of indirectly through class tables. How do?

Account = {}
function Account.new(balance)
  local acc = {balance = balance}
  for k,v in pairs(Account) do
    acc[k] = v
  end
  return acc
end

function Account:withdraw(n)
  self.balance = self.balance - n
end

function Account:print()
  print(self.balance)
end

local acc = Account.new(500)
acc:withdraw(5)
acc:print()

-- Inheritance? Easy!
LimitAccount = {}
function LimitAccount.new(balance, limit)
  local acc = Account.new(balance)
  acc.limit = limit
  for k,v in pairs(LimitAccount) do
    acc[k] = v
  end
  return acc
end

function LimitAccount:withdraw(v)
  if v - self.balance >= self.limit then
    error "Insufficient funds"
  end
  self.balance = self.balance - v
end

local acc = LimitAccount.new(500, 100)
acc:withdraw(5)
acc:print()


-- What's the problem here? Every INSTANCE of an account contains an entry for every function. That's a
-- lot of pointers, and a lot of overhead. Imagine you have a Point class with methods for add, subtract,
-- distance, ... you could imagine 30-40 methods. Then every time you make a Point, you have to allocate
-- 30 strings and store them all in a table. That's huge!

-- Instead, let's add a layer of indirection. What we want is to say, whenever someone requests a key on our
-- table, let's do a **dynamic lookup** into our class. And keep going if we're doing inheritance.
-- That seems weird--tables just map keys to values. How can we perform a lookup though on a table? Metatables!


local t = {a = 1}
print(t.a)
print(t.b)

function __index(t, k)
   print('__index', t, k)
   return 0
end
setmetatable(t, {__index = __index})

print(t.a)
print(t.b)


-- Exercise: write a fibonacci table with __index metamethod
local fib = {}
function fib_index(t, k)
  if k == 0 or k == 1 then
    return k
  else
    return t[k-1] + t[k-2]
  end
end
setmetatable(fib, {__index = fib_index})

print(fib[30])


------ PROTOTYPE-BASED OBJECTS -----
-- The idea here is that a class is itself an _example_ of an object. For example,
-- Account starts with a default balance of 0. We use metatables to provide lookup
-- pointers from instances to their class, and from child classes to parent classes.

Account = {balance = 0}
function Account:new(t)
  t = t or {}
  setmetatable(t, {__index = self})
  return t
end

function Account:withdraw(n)
  self.balance = self.balance - n
end

function Account:print()
  print(self.balance)
end


-- Inheritance with metamethods is trivial, LimitAccount is just an instance of Account.
-- This is actually pretty subtle, so make sure you understand how the inheritance is occuring.

LimitAccount = Account:new({limit = 10})
function LimitAccount:withdraw(v)
  if v - self.balance >= self.limit then
    error "Insufficient funds"
  end

  Account.withdraw(self, v)
end

a = LimitAccount:new({balance = 100, limit = 10})
a:withdraw(30)
a:print()
a:withdraw(100) -- should error
