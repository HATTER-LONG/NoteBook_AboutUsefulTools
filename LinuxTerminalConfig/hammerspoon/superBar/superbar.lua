---@diagnostic disable: undefined-global
local obj = {}
local canvas = require("hs.canvas")
local yabai = require("superBar.yabai")
local u = require("superBar.util")
obj.table = {}

local ui = {
	barHeight = 30,
	backgroundColor = { 0.2, 0.2, 0.8, 0.5 },
}
local item = { background = 1, space = 2 }
local watcher = nil
local function getColor(t)
	if t.red then
		return t
	else
		return { red = t[1] or 0, green = t[2] or 0, blue = t[3] or 0, alpha = t[4] or 1 }
	end
end

local function drawSuperBar()
	local screens = hs.screen.allScreens()
	for i, screen in ipairs(screens) do
		local frame = screen:fullFrame()
		obj.table[i] = canvas.new({ x = frame.x, y = frame.y, h = ui.barHeight, w = frame.w })
		obj.table[i][item["background"]] = {
			action = "fill",
			fillColor = getColor(ui.backgroundColor),
			type = "rectangle",
		}
		yabai("-m query --displays --display " .. i, function(res)
			u.p(res)
			if type(res) ~= "table" then
				u.p(res)
			end
			if type(res["spaces"]) == "table" and res["spaces"] ~= nil then
				local spaceCount = 0
				for _, value in pairs(res["spaces"]) do
					-- obj.table[i][item["space"] + spaceCount] = {
					--                         frame = {h = 0, w= 50, x = 0, y =}
					--                     }
					spaceCount = spaceCount + 1
				end
			end
		end)
		-- 设置菜单栏显示层级
		-- obj.table[i]:level(hs.canvas.windowLevels.desktopIcon + 1000)
		obj.table[i]:level(hs.canvas.windowLevels.dragging)
		-- 设置关联窗口的行为
		obj.table[i]:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
		obj.table[i]:show(0.3)
	end
end

local eventNames = {
	[hs.caffeinate.watcher.screensaverDidStart] = "Screensaver started",
	[hs.caffeinate.watcher.screensaverDidStop] = "Screensaver stopped",
	[hs.caffeinate.watcher.screensaverWillStop] = "Screensaver will stop",
	[hs.caffeinate.watcher.screensDidLock] = "Screen locked",
	[hs.caffeinate.watcher.screensDidSleep] = "Screen slept",
	[hs.caffeinate.watcher.screensDidUnlock] = "Screen unlocked",
	[hs.caffeinate.watcher.screensDidWake] = "Screen woke",
	[hs.caffeinate.watcher.sessionDidBecomeActive] = "Session actived",
	[hs.caffeinate.watcher.sessionDidResignActive] = "Session deactivated",
	[hs.caffeinate.watcher.systemDidWake] = "System woke",
	[hs.caffeinate.watcher.systemWillPowerOff] = "System will power off",
	[hs.caffeinate.watcher.systemWillSleep] = "System will sleep",
}

function obj.refresh()
	for index, table in pairs(obj.table) do
		print("refresh index = ", index)
		table:delete()
	end
	drawSuperBar()
end
local watcherFunction = function(event)
	if event == hs.caffeinate.watcher.systemDidWake then
		print("watcher() called. Event = %s", eventNames[event])
		hs.timer.doAfter(3, obj.refresh)
	end -- systemDidWake
end

function obj.init()
	drawSuperBar()
	watcher = hs.caffeinate.watcher.new(watcherFunction)
	watcher:start()
end

return obj
