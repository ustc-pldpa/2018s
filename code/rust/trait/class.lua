local function call_bar(t)
  t:bar()
end

local Class1 = {
  new = function(self)
    local t = {}
    setmetatable(t, {__index = self})
    return t
  end,

  bar = function(self)
    print("Class 1")
  end
}

local Class2 = {
  new = function(self)
    local t = {}
    setmetatable(t, {__index = self})
    return t
  end,

  bar = function(self)
    print("Class 2")
  end
}

local c1 = Class1:new()
local c2 = Class2:new()

call_bar(c1)
call_bar(c2)
