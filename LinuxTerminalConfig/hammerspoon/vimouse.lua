---@diagnostic disable: undefined-global
-- Save to ~/.hammerspoon
-- In ~/.hammerspoon/init.lua:
--    local vimouse = require('vimouse')
--    vimouse('cmd', 'm')
--
-- This sets cmd-m as the key that toggles Vi Mouse.
--
-- h/j/k/l moves the mouse cursor by 20 pixels.  Holding shift moves by 100
-- pixels, and holding alt moves by 5 pixels.
--
-- Pressing <space> sends left mouse down.  Releasing <space> sends left mouse
-- up.  Holding <space> and pressing h/j/k/l is mouse dragging.  Tapping
-- <space> quickly sends double and triple clicks.  Holding ctrl sends right
-- mouse events.
--
-- <c-y> and <c-e> sends the scroll wheel event.  Holding the keys will speed
-- up the scrolling.
--
-- Press <esc> or the configured toggle key to end Vi Mouse mode.

local menuFocus = require("WindowFocus")
local mousejump = require("mouseJump")
local focusColor = { ["hex"] = "#ecd452", ["alpha"] = 0.8 }
local geom = require("hs.geometry")
local drawing = require("hs.drawing")

local ui = {
	textColor = { 1, 1, 1 },
	textSize = 200,
	cellStrokeColor = { 0, 0, 0 },
	cellStrokeWidth = 5,
	cellColor = { 0, 0, 0, 0.25 },
	highlightColor = { 0.8, 0.8, 0, 0.5 },
	highlightStrokeColor = { 0.8, 0.8, 0, 1 },
	cyclingHighlightColor = { 0, 0.8, 0.8, 0.5 },
	cyclingHighlightStrokeColor = { 0, 0.8, 0.8, 1 },
	highlightStrokeWidth = 30,
	selectedColor = { 0.2, 0.7, 0, 0.4 },
	showExtraKeys = true,
	fontName = "Lucida Grande",
}
local function initGridMode()
	local window = hs.window.focusedWindow()
	local windowframe = window:frame()
	local width = windowframe.w
	local height = windowframe.h
	print("current windows h = ", height, ", w = ", width)
	local elem =
		geom.new({ x = windowframe.x, y = windowframe.y, x2 = windowframe.x + width, y2 = windowframe.y + height })
	local rect = drawing.rectangle(elem)
	rect:setFillColor({ ["hex"] = "#ecd452", ["alpha"] = 0.8 })

	rect:setFill(true)
	rect:setAlpha(0.4)
	rect:setLevel(hs.drawing.windowLevels.overlay)
	rect:setStroke(false)
	rect:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
	elem.rect = rect
end
return function(tmod, tkey)
	-- local overlay = nil
	local log = hs.logger.new("vimouse", "debug")
	local tap = nil
	local orig_coords = nil
	local dragging = false
	local scrolling = 0
	local mousedown_time = 0
	local mousepress_time = 0
	local mousepress = 0
	local tapmods = { ["cmd"] = false, ["ctrl"] = false, ["alt"] = false, ["shift"] = false }

	if type(tmod) == "string" then
		tapmods[tmod] = true
	else
		for _, name in ipairs(tmod) do
			tapmods[name] = true
		end
	end

	local eventTypes = hs.eventtap.event.types
	local eventPropTypes = hs.eventtap.event.properties
	local keycodes = hs.keycodes.map

	local function postEvent(et, coords, modkeys, clicks)
		local e = hs.eventtap.event.newMouseEvent(et, coords, modkeys)
		if clicks > 3 then
			clicks = 3
		end
		e:setProperty(eventPropTypes.mouseEventClickState, clicks)
		e:post()
	end

	tap = hs.eventtap.new({ eventTypes.keyDown, eventTypes.keyUp }, function(event)
		local code = event:getKeyCode()
		local flags = event:getFlags()
		local repeating = event:getProperty(eventPropTypes.keyboardEventAutorepeat)
		local coords = hs.mouse.absolutePosition()

		if (code == keycodes.tab or code == keycodes["`"]) and flags.cmd then
			-- Window cycling
			return false
		end

		if code == keycodes.space then
			-- Mouse clicking
			if repeating ~= 0 then
				return true
			end

			local btn = "left"
			if flags.ctrl then
				btn = "right"
			end

			local now = hs.timer.secondsSinceEpoch()
			if now - mousepress_time > hs.eventtap.doubleClickInterval() then
				mousepress = 1
			end

			if event:getType() == eventTypes.keyUp then
				dragging = false
				postEvent(eventTypes[btn .. "MouseUp"], coords, flags, mousepress)
			elseif event:getType() == eventTypes.keyDown then
				dragging = true
				if now - mousedown_time <= 0.3 then
					mousepress = mousepress + 1
					mousepress_time = now
				end

				mousedown_time = hs.timer.secondsSinceEpoch()
				postEvent(eventTypes[btn .. "MouseDown"], coords, flags, mousepress)
			end

			orig_coords = coords
		elseif event:getType() == eventTypes.keyDown then
			local mul = 0
			local step = 20
			local x_delta = 0
			local y_delta = 0
			local scroll_y_delta = 0
			local is_tapkey = code == keycodes[tkey]

			if is_tapkey == true then
				for name, _ in pairs(tapmods) do
					if flags[name] == nil then
						flags[name] = false
					end

					if tapmods[name] ~= flags[name] then
						is_tapkey = false
						break
					end
				end
			end

			if flags.alt then
				step = 5
			end

			if flags.shift then
				mul = 5
			else
				mul = 1
			end

			if is_tapkey or code == keycodes["escape"] or code == keycodes["q"] then
				if dragging then
					postEvent(eventTypes.leftMouseUp, coords, flags, 0)
				end
				dragging = false
				-- overlay:delete()
				-- overlay = nil
				hs.alert("Vi Mouse Off", hs.mouse.getCurrentScreen())
				menuFocus:deleteMenubarIndicator("vimouse")
				tap:stop()
				hs.mouse.absolutePosition(orig_coords)
				return true
			elseif (code == keycodes["u"] or code == keycodes["d"]) and flags.ctrl then
				if repeating ~= 0 then
					scrolling = scrolling + 1
				else
					scrolling = 10
				end

				local scroll_mul = 1 + math.log(scrolling)
				if code == keycodes["u"] then
					scroll_y_delta = math.ceil(-1 * scroll_mul)
				else
					scroll_y_delta = math.floor(1 * scroll_mul)
				end
				log.d("Scrolling", scrolling, "-", scroll_y_delta)
			elseif code == keycodes["h"] then
				x_delta = step * mul * -1
			elseif code == keycodes["l"] then
				x_delta = step * mul
			elseif code == keycodes["j"] then
				y_delta = step * mul
			elseif code == keycodes["k"] then
				y_delta = step * mul * -1
			end

			if scroll_y_delta ~= 0 then
				hs.eventtap.event.newScrollEvent({ 0, scroll_y_delta }, flags, "line"):post()
			end

			if x_delta or y_delta then
				coords.x = coords.x + x_delta
				coords.y = coords.y + y_delta

				if dragging then
					postEvent(eventTypes.leftMouseDragged, coords, flags, 0)
				else
					hs.mouse.absolutePosition(coords)
				end
			end
		end
		return true
	end)

	hs.hotkey.bind(tmod, tkey, nil, function(_)
		hs.alert("Vi Mouse On", hs.mouse.getCurrentScreen())
		mousejump:toCenterOfWindow()
		menuFocus:drawMenubarIndicator(focusColor, "vimouse")
		orig_coords = hs.mouse.absolutePosition()
		initGridMode()
		tap:start()
	end)
end
