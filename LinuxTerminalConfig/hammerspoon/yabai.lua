---@diagnostic disable: undefined-global
local yabai = function(args, completion, streamout)
	local yabai_output = ""
	local yabai_error = ""
	-- Runs in background very fast
	local yabai_task = hs.task.new("/opt/homebrew/bin/yabai", function(err, stdout, stderr)
		print("err" .. err, "stdout:" .. stdout, "stderr:" .. stderr)
	end, function(_, stdout, stderr) -- _ is task
		print("stdout:" .. stdout, "stderr:" .. stderr)
		if stdout ~= nil then
			yabai_output = yabai_output .. stdout
		end
		if stderr ~= nil then
			yabai_error = yabai_error .. stderr
		end
		if type(streamout) == "function" then
			streamout(stdout)
		end
		return true
	end, args)

	if type(completion) == "function" then
		yabai_task:setCallback(function()
			completion(yabai_output, yabai_error)
		end)
	end
	yabai_task:start()
end

return yabai
