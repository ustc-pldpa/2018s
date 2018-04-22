local t = {1, 2, 3}

local function sum_list(t)
  local sum = 0
  for _, x in ipairs(t) do
    sum = sum + x
  end
  return sum
end

local function incr_list(t)
  local new_t = {}
  for _, x in ipairs(t) do
    table.insert(new_t, x + 1)
  end
  return new_t
end

local function even_list(t)
  local new_t = {}
  for _, x in ipairs(t) do
    if x % 2 == 0 then
      table.insert(new_t, x)
    end
  end
  return new_t
end
