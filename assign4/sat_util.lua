local util = {}

-- A deep copying helper function. Adapted from http://lua-users.org/wiki/CopyTable
function util.deep_copy(orig)
    if type(orig) == 'table' then
        local copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[util.deep_copy(orig_key)] = util.deep_copy(orig_value)
        end
        setmetatable(copy, util.deep_copy(getmetatable(orig)))
        return copy
    end
    return orig
end

-- A deep equuality function. Adapted from https://github.com/mirven/underscore.lua/blob/master/lib/underscore.lua
function util.deep_equal(o1, o2, ignore_mt)
	local ty1, ty2 = type(o1), type(o2)
	if ty1 ~= ty2 then return false end

	-- non-table types can be directly compared
	if ty1 ~= 'table' then return o1 == o2 end

	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(o1)
	if not ignore_mt and mt and mt.__eq then return o1 == o2 end

	for k1,v1 in pairs(o1) do
		local v2 = o2[k1]
		if v2 == nil or not util.deep_equal(v1,v2, ignore_mt) then return false end
	end
	for k2,v2 in pairs(o2) do
		local v1 = o1[k2]
		if v1 == nil then return false end
	end

	return true
end

-- Returns true if any value in the table passes the given predicate.
function util.any_val(table, func)
  for _, v in pairs(table) do
    if func(v) then return true end
  end
  return false
end

-- Dedupe an iterator that returns a stream of values. Doesn't work if
-- the iterator returns multiple values every round.
function util.iter_dedup(iter)
  local seen = {}
  return coroutine.wrap(function()
    for val in iter do
      local has_seen = util.any_val(seen, function(v)
        return util.deep_equal(v, val)
      end)

      if not has_seen then
        table.insert(seen, val)
        coroutine.yield(val)
      end
    end
  end)
end

-- Display an assignment as a string.
function util.assignment_to_string(assignment)
  if assignment == nil then return "{no solution}" end
  local fields = {}
  for k, v in pairs(assignment) do
    table.insert(fields, k .. " = " .. (v and 'T' or 'F'))
  end
  return "{" .. table.concat(fields, ", ") .. "}"
end

-- Check if an assignment satisfies a CNF. You shouldn't call this from your code.
function util.check_assignment(assignment, cnf)
  local function check_clause(clause)
    for _, literal in ipairs(clause) do
      local atom, affinity = literal[1], literal[2]
      if assignment[atom] == affinity then return true end
    end
    return false
  end

  for _, clause in ipairs(cnf) do
    if check_clause(clause) == false then return false end
  end
  return true
end

function util.map(func, tbl)
    local newtbl = {}
    for i, v in pairs(tbl) do newtbl[i] = func(v) end
    return newtbl
end

function util.literal_to_string(literal)
  local atom, affinity = literal[1], literal[2]
  if affinity then return atom else return "~" .. atom end
end

function util.clause_to_string(clause)
  if #clause == 1 then return util.literal_to_string(clause[1])
  else
    return "(" .. table.concat(util.map(util.literal_to_string, clause), " | ") .. ")"
  end
end

function util.cnf_to_string(cnf)
  return table.concat(util.map(util.clause_to_string, cnf), " & ")
end

local c27 = string.char(27)
local reset = c27 .. "[0m"
local red = c27 .. "[0;31m"
local green = c27 .. "[0;32m"

function util.redify(str) return red .. str .. reset end
function util.greenify(str) return green .. str .. reset end

local TEST_CASES = {
  {
	atoms = {"a", "b", "c"},
	cnf = {{{"a", true}}, {{"a", false}, {"b", false}}, {{"b", true}, {"c", true}}},
	solutions = 1
  },
  {
    atoms = {"a", "b", "c"},
    cnf = {{{"a", true}, {"b", false}}, {{"c", true}}, {{"a", true}, {"a", false}}},
    solutions = 3
  },
  {
    atoms = {"a"},
    cnf = {{{"a", true}}, {{"a", false}}},
    solutions = 0
  },
  {
    atoms = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"},
    cnf = {{{"a", true}}, {{"b", true}}, {{"c", false}}, {{"d", true}}, {{"e", true}},
      {{"g", true}}, {{"h", true}}, {{"i", false}}, {{"j", true}}, {{"k", true}},
      {{"l", true}}, {{"m", true}}, {{"n", true}}, {{"o", true}}, {{"p", true}}},
    solutions = 2
  }
}

function util.run_basic_tests()
  for _, case in ipairs(TEST_CASES) do
    print("Case: " .. util.cnf_to_string(case.cnf))

    local function validity(sol)
      if util.check_assignment(sol, case.cnf) then return util.greenify("(VALID)")
      else return util.redify("(INVALID)") end
    end

    local single_sol = satisfiable(case.atoms, case.cnf)
    if single_sol ~= nil then
      print("- satisfiable(): " .. util.assignment_to_string(single_sol)
        .. " " .. validity(single_sol))
    else
      if case.solutions == 0 then
        print("- satisfiable(): " .. util.greenify("Expected no solution, got no solution."))
      else
        print("- satisfiable(): " .. util.redify("Expected a solution, got no solution."))
      end
    end


    print("- satisfiable_gen():")
    local count = 0
    for assignment in satisfiable_gen(case.atoms, case.cnf) do
      print("  - " .. util.assignment_to_string(assignment)
        .. " " .. validity(assignment))
      count = count + 1
    end

    local uncolored = "Expected " .. case.solutions .. " solutions, got " .. count
    if count == case.solutions then print("  - " .. util.greenify(uncolored))
    else print("  - " .. util.redify(uncolored)) end

    print()
  end
end

return util
