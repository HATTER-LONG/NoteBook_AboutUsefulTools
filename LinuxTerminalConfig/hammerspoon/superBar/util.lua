---@diagnostic disable: undefined-global
-- === utils module ===
local u = {}

function u.isnum(x) -- {{{
	return type(x) == "number"
end -- }}}

function u.istable(x) -- {{{
	return type(x) == "table"
end -- }}}

function u.isstring(x) -- {{{
	return type(x) == "string"
end -- }}}

function u.isbool(x) -- {{{
	return type(x) == "boolean"
end -- }}}

function u.isfunc(x) -- {{{
	return type(x) == "function"
end -- }}}

function u.isarray(x) -- {{{
	return u.istable(x) and x[1] ~= nil and x[u.length(x)] ~= nil
end -- }}}

function u.isjson(x) -- {{{
	return u.isstring(x) and x:find("{") and x:find("}")
end -- }}}

function u.task_cb(fn)
	return function(...)
		local out = { ... }

		local is_hstask = function(x)
			return #x == 3 and tonumber(x[1]) and u.isstring(x[2])
		end

		if is_hstask(out) then
			local stdout = out[2]

			if u.isjson(stdout) then
				-- NOTE: hs.json.decode cannot parse "inf" values
				-- yabai response may have "inf" values: e.g., frame":{"x":inf,"y":inf,"w":0.0000,"h":0.0000}
				-- So, we must replace ":inf," with ":0,"
				local clean = stdout:gsub(":inf,", ":0,")
				stdout = hs.json.decode(clean)
			end

			return fn(stdout)
		end

		-- fallback if 'out' is not from hs.task
		return fn(out)
	end
end

function u.p(data, howDeep) -- {{{
	-- local logger = hs.logger.new('inspect', 'debug')
	local depth = howDeep or 3
	if type(data) == "table" then
		print(hs.inspect(data, { depth = depth }))
		-- logger.df(hs.inspect(data, {depth = depth}))
	else
		print(hs.inspect(data, { depth = depth }))
		-- logger.df(hs.inspect(data, {depth = depth}))
	end
end -- }}}

function string:split(p) -- {{{
	-- Splits the string [s] into substrings wherever pattern [p] occurs.
	-- Returns: a table of substrings or, a table with the string as the only element
	p = p or "%s" -- split on space by default
	local temp = {}
	local index = 0
	local last_index = self:len()

	while true do
		local i, e = self:find(p, index)

		if i and e then
			local next_index = e + 1
			local word_bound = i - 1
			table.insert(temp, self:sub(index, word_bound))
			index = next_index
		else
			if index > 0 and index <= last_index then
				table.insert(temp, self:sub(index, last_index))
			elseif index == 0 then
				temp = { self }
			end
			break
		end
	end

	return temp
end -- }}}

return u
