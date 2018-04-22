local util = require "sat_util"

-- print a table
function print_table(tbl)
	if tbl == nil then
		print("nil")
	else
		for k, v in pairs(tbl) do
			print(tostring(k)..": "..tostring(v))
		end
	end
end

-- return the size of a table
function size(tbl) 
	if tbl == nil then
		print("size nil")
		return 0
	end
	local cnt = 0
	for k, v in pairs(tbl) do
		cnt = cnt + 1
	end
	return cnt
end

--[[ This function takes in a list of atoms (variables) and a boolean expression
in conjunctive normal form. It should return a mapping from atom to booleans that
represents an assignment which satisfies the expression. If no assignments exist,
return nil. ]]--
function satisfiable(atoms, cnf)
  local function helper(assignment, clauses)
    -- Your code goes here.
    -- You may find util.deep_copy useful.
    return assignment
  end
  return helper({}, cnf)
end


--[[ The function above only returns one solution. This function should return
an iterator which calculates, on demand, all of the solutions. ]]--
function satisfiable_gen(atoms, cnf)
	local function helper (assignment, clauses)
	  -- Your code goes here.
	  -- You may find util.deep_copy useful.
	end

	local solutions = coroutine.wrap(function ()
		helper({}, cnf)
	end)

	--[[ We've provided a wrapper which removes duplicate solutions so that
	your solver doesn't need to check for duplicates before emitting a result. ]]--
	return util.iter_dedup(solutions)
end

-- self test here
test_atom = {"a", "b", "c"}
test_cnf = {{{"a", true}, {"b", false}, {"c", true}}}
res = satisfiable(test_atom, test_cnf)

-- official test
util.run_basic_tests()
