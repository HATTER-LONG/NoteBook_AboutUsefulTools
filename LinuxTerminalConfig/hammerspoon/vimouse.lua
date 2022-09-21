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
local canvas = require("hs.canvas")

local ui = {
	textColor = { 1, 0, 0 },
	textSize = 20,
	cellStrokeColor = { 0, 0, 0 },
	cellStrokeWidth = 3,
	cellBackGroundColor = { 0.1, 0.1, 0.5, 0.4 },
	cellWidth = 80,
	cellHeight = 80,
	selectedColor = { 0.2, 0.2, 0.8 },
	fontName = "Lucida Grande",
	hideFadeOut = 0.3,
}

local function getColor(t)
	if t.red then
		return t
	else
		return { red = t[1] or 0, green = t[2] or 0, blue = t[3] or 0, alpha = t[4] or 1 }
	end
end

local uiObj = {}
local easyMotion = false
local lastCode = nil
local canvasTable = nil
local deleteUI = function()
	if canvasTable ~= nil then
		canvasTable:delete(ui.hideFadeOut)
		canvasTable = nil
	end
	uiObj = {}
	lastCode = nil
	easyMotion = false
end

local strArray = {}
local function initStrArray()
	local key = "abcdefghijklmnopqrstuvwxyz;,."
	local len = string.len(key)
	for i = 1, len, 1 do
		for k = 1, len, 1 do
			strArray[(i - 1) * len + k] = string.sub(key, i, i) .. string.sub(key, k, k)
		end
	end
end
initStrArray()

local function initGridMode()
	local window = hs.window.focusedWindow()
	local windowframe = window:frame()
	local canvasframe = nil
	local canvasObjNum = 1
	if canvasTable ~= nil then
		canvasframe = canvasTable:frame()
	end
	if canvasframe ~= windowframe then
		canvasTable = canvas.new({ x = windowframe.x, y = windowframe.y, h = windowframe.h, w = windowframe.w })
		local width = windowframe.w
		local height = windowframe.h
		local colSize = math.floor(width / ui.cellWidth)
		for col = 0, colSize, 1 do
			canvasTable[canvasObjNum] = {
				type = "segments",
				closed = true,
				strokeColor = getColor(ui.cellStrokeColor),
				action = "stroke",
				strokeWidth = ui.cellStrokeWidth,
			}
			local z = {}
			table.insert(z, { x = col * ui.cellWidth, y = 0 })
			table.insert(z, { x = col * ui.cellWidth, y = height })
			canvasTable[col + 1].coordinates = z
			canvasObjNum = canvasObjNum + 1
		end
		local rowSize = math.floor(height / ui.cellHeight)
		for row = 0, rowSize, 1 do
			canvasTable[canvasObjNum] = {
				type = "segments",
				closed = true,
				strokeColor = getColor(ui.cellStrokeColor),
				action = "stroke",
				strokeWidth = ui.cellStrokeWidth,
			}
			local z = {}
			table.insert(z, { x = 0, y = row * ui.cellHeight })
			table.insert(z, { x = width, y = row * ui.cellHeight + ui.cellStrokeWidth })
			canvasTable[canvasObjNum].coordinates = z
			canvasObjNum = canvasObjNum + 1
		end
		for row = 0, rowSize, 1 do
			for col = 0, colSize, 1 do
				local str = strArray[row * (colSize + 1) + col + 1]
				if str == nil then
					str = "N"
				end
				local offset = 10
				local textFrame = {
					x = col * ui.cellWidth + math.floor(ui.cellWidth / 2) - offset,
					y = row * ui.cellHeight + math.floor(ui.cellWidth / 2) - offset,
					h = ui.textSize + 10,
					w = ui.textSize * 2,
				}
				local textst = hs.styledtext.new(str, {
					font = { name = ui.fontName, size = ui.textSize },
					color = getColor(ui.textColor),
					paragraphStyle = { alignment = "left" },
				})
				--textst = textst:setStyle({ color = { blue = 1 } }, 1, 1)
				canvasTable[canvasObjNum] = {
					frame = textFrame,
					type = "text",
					text = textst,
				}
				uiObj[str] = {
					x = textFrame.x + offset + windowframe.x,
					y = textFrame.y + offset + windowframe.y,
					objnum = canvasObjNum,
				}
				--print("str = ", str, " x = ", uiObj[str].x, ", y = ", uiObj[str].y, ", frame x = ", textFrame.x)
				canvasObjNum = canvasObjNum + 1
			end
		end
		canvasTable[canvasObjNum] = {
			action = "fill",
			fillColor = getColor(ui.cellBackGroundColor),
			frame = windowframe,
			type = "rectangle",
		}
	end
	if canvasTable ~= nil then
		canvasTable:show()
		easyMotion = true
	else
		print("error canvas table is nil!!!")
	end
end
local function updateTextColor(text, clear)
	for str, obj in pairs(uiObj) do
		if string.sub(str, 1, 1) == text then
			local textobj = canvasTable[obj.objnum]
			local color = nil
			if clear == false then
				color = getColor(ui.selectedColor)
			else
				color = getColor(ui.textColor)
			end
			textobj.text = textobj.text:setStyle({ color = color }, 1, 1)
		end
	end
end

return function(tmod, tkey)
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

			if is_tapkey or code == keycodes["escape"] or (code == keycodes["q"] and easyMotion == false) then
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
				deleteUI()
				return true
			elseif easyMotion == true then
				print("input code = ", keycodes[code])
				if lastCode == nil then
					lastCode = keycodes[code]
					updateTextColor(lastCode, false)
				else
					local lable = lastCode .. keycodes[code]

					if uiObj[lable] ~= nil then
						local textRect = uiObj[lable]
						coords.x = textRect.x
						coords.y = textRect.y
						hs.mouse.absolutePosition(coords)
						canvasTable:hide()
						easyMotion = false
					end
					updateTextColor(lastCode, true)
					lastCode = nil
				end
			elseif code == keycodes["e"] then
				initGridMode()
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
