---@diagnostic disable: undefined-global
local obj = {}
obj.__index = obj

--[ Menubar Focus ]----------------------------------------------------
obj.menubarIndicators = {}

function obj:drawMenubarIndicator(icolor, name)
	if icolor == nil then
		print("error nil")
	end
	local screens = hs.screen.allScreens()
	for i, screen in ipairs(screens) do
		if obj.menubarIndicators[name .. i] == nil then
			local screeng = screen:fullFrame()
			local width = screeng.w
			local height = 32
			if screen:frame().y ~= screeng.y then
				height = (screen:frame().y - screeng.y)
			end
			local menubarIndicator = hs.drawing.rectangle(hs.geometry.rect(screeng.x, screeng.y, width, height))
			menubarIndicator:setFillColor(icolor)

			menubarIndicator:setFill(true)
			menubarIndicator:setAlpha(0.4)
			menubarIndicator:setLevel(hs.drawing.windowLevels.overlay)
			menubarIndicator:setStroke(false)
			menubarIndicator:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
			menubarIndicator:show()
			obj.menubarIndicators[name .. i] = menubarIndicator
		end
	end
end

function obj:deleteMenubarIndicator(name)
	local screens = hs.screen.allScreens()
	for i, _ in ipairs(screens) do
		if obj.menubarIndicators[name .. i] ~= nil then
			print("show false menu border in " .. name .. i)
			obj.menubarIndicators[name .. i]:delete()
			obj.menubarIndicators[name .. i] = nil
		end
	end
end

--[ END Menubar Focus ]----------------------------------------------------

--[ Windows Focus ]----------------------------------------------------
local borderColor = { ["hex"] = "#3271ae" }
local cache = { borderDrawings = {}, borderDrawingFadeOuts = {} }
obj.drawBorder = function()
	local focusedWindow = hs.window.focusedWindow()

	if not focusedWindow or focusedWindow:role() ~= "AXWindow" then
		if cache.borderCanvas then
			cache.borderCanvas:hide(0.5)
		end

		return
	end

	local alpha = 0.8
	local borderWidth = 6
	local distance = 6
	local roundRadius = 12

	local isFullScreen = focusedWindow:isFullScreen()
	local frame = focusedWindow:frame()

	if not cache.borderCanvas then
		cache.borderCanvas = hs.canvas
			.new({ x = 0, y = 0, w = 0, h = 0 })
			:level(hs.canvas.windowLevels.overlay)
			:behavior({ hs.canvas.windowBehaviors.transient, hs.canvas.windowBehaviors.moveToActiveSpace })
			:alpha(alpha)
	end

	if isFullScreen then
		cache.borderCanvas:frame(frame)
	else
		cache.borderCanvas:frame({
			x = frame.x - distance / 2,
			y = frame.y - distance / 2,
			w = frame.w + distance,
			h = frame.h + distance,
		})
	end

	cache.borderCanvas[1] = {
		type = "rectangle",
		action = "stroke",
		strokeColor = borderColor,
		strokeWidth = borderWidth,
		roundedRectRadii = { xRadius = roundRadius, yRadius = roundRadius },
	}

	cache.borderCanvas:show()
end

obj.highlightWindow = function(win)
	if config.window.highlightBorder then
		obj.drawBorder()
	end

	if config.window.highlightMouse then
		local focusedWindow = win or hs.window.focusedWindow()
		if not focusedWindow or focusedWindow:role() ~= "AXWindow" then
			return
		end

		local frameCenter = hs.geometry.getcenter(focusedWindow:frame())

		hs.mouse.setAbsolutePosition(frameCenter)
	end
end

function obj:cleanBorder()
	cache.borderCanvas:delete()
	cache.borderCanvas = nil
end

local allwindows = nil
function obj:startDrawBorder()
	if allwindows ~= nil then
		print("allwindows alread create")
		return
	end
	obj:drawBorder()
	allwindows = hs.window.filter.new(nil)
	allwindows:subscribe({
		hs.window.filter.windowCreated,
		hs.window.filter.windowFocused,
		hs.window.filter.windowMoved,
		hs.window.filter.windowUnfocused,
	}, obj.drawBorder)
end

function obj:stopDrawBorder()
	obj:cleanBorder()
	if allwindows == nil then
		return
	end
	allwindows:delete()
	allwindows = nil
end
--
--[ END Windows Focus ]----------------------------------------------------

return obj
