---@diagnostic disable: undefined-global
local mouseJump = require("mouseJump")
local menuFocus = require("WindowFocus")
local toolName = "VimMouseMode"
spoon.ModalMgr:new(toolName)
local cmodal = spoon.ModalMgr.modal_list[toolName]

-- function local var tmp
local coords = hs.mouse.absolutePosition()
local borderColor = { ["hex"] = "#3271ae" }

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
local tmod = "alt"
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

cmodal:bind("", "q", "退出", function()
	spoon.ModalMgr:deactivate({ toolName })
	menuFocus:deleteMenubarIndicator(toolName)
end)

cmodal:bind("", "escape", "退出", function()
	spoon.ModalMgr:deactivate({ toolName })
	menuFocus:deleteMenubarIndicator(toolName)
end)

local startMode = function()
	mouseJump.toCenterOfWindow()
	menuFocus:drawMenubarIndicator(borderColor, toolName)
	tap:start()
	spoon.ModalMgr:deactivateAll()
	spoon.ModalMgr:activate({ toolName }, "#3271ae")
end

cmodal:bind("", "l", "", function(event)
    print(event::getType())
	hs.window.filter.focusEast()
end)

local hsresizeM_keys = { "alt", "s" }
if string.len(hsresizeM_keys[2]) > 0 then
	spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "进入 VIM MOUSE 模式", function()
		startMode()
	end)
end
