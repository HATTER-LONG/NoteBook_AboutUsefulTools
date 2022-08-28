---@diagnostic disable: undefined-global
local function windowInScreen(screen, win) -- Check if a window belongs to a screen
	return win:screen() == screen
end

local function focusNextScreen()
	-- Get next screen (and its center point) using current mouse position
	-- local next_screen = hs.window.focusedWindow():screen():next()
	local next_screen = hs.mouse.getCurrentScreen():next()
	local center = hs.geometry.rectMidPoint(next_screen:fullFrame())

	-- Find windows within this next screen, ordered from front to back.
	local windows = hs.fnutils.filter(hs.window.orderedWindows(), hs.fnutils.partial(windowInScreen, next_screen))

	-- Move the mouse to the center of the other screen
	hs.mouse.setAbsolutePosition(center)

	--  Set focus on front-most application window or bring focus to desktop if
	--  no windows exists
	if #windows > 0 then
		windows[1]:focus()
	else
		hs.window.desktop():focus()
		-- In this case also do a click to activate menu bar
		hs.eventtap.leftClick(hs.mouse.getAbsolutePosition())
	end
end

hs.hotkey.bind({ "alt" }, "`", focusNextScreen)
