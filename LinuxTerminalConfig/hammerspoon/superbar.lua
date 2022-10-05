---@diagnostic disable: undefined-global
local obj = {}
local canvas = require("hs.canvas")
obj.table = nil
local function drawSuperBar()
	table = canvas.new({ x = windowframe.x, y = windowframe.y, h = windowframe.h, w = windowframe.w })
end

function obj.init()
	drawSuperBar()
end

return obj
