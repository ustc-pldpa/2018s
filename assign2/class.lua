local Object
Object = {
  isinstance = function(cls) return cls == Object end,
  constructor = function() end,
  methods = {},
  data = {},
  metamethods = {}
}

-- This is a utility function you will find useful during the metamethods section.
function table.merge(src, dst)
  for k,v in pairs(src) do
    if not dst[k] then dst[k] = v end
  end
end

local function class(parent, child)

  -- The "child.methods or {}" syntax can be read as:
  -- "if child.methods is nil then this expression is {}, otherwise it is child.methods"
  -- Generally, "a or b" reduces to b if a is nil or false, evaluating to a otherwise.
  local methods = child.methods or {}
  local data = child.data or {}
  local constructor = child.constructor or parent.constructor
  local metamethods = child.metamethods or {}

  local Class = {}

  -- Your code here.
  
  return Class
end

return {class = class, Object = Object} 
