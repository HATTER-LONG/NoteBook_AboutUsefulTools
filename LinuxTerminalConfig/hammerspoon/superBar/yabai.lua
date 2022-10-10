---@diagnostic disable: undefined-global
local u = require("superBar.util")

local function yabai(command, callback)
	callback = callback or function(x)
		return x
	end

	hs.task
		.new(
			"/opt/homebrew/bin/yabai",
			u.task_cb(callback), -- wrap callback in json decoder
			command:split(" ")
		)
		:start()
end

return yabai
