---@diagnostic disable: undefined-global
local VimMode = hs.loadSpoon("VimMode")
local vimmode = VimMode:new()

-- Configure apps you do *not* want Vim mode enabled in
-- For example, you don't want this plugin overriding your control of Terminal
-- vim
vimmode
	:disableForApp("Code")
	:disableForApp("zoom.us")
	:disableForApp("iTerm")
	:disableForApp("iTerm2")
	:disableForApp("Terminal")

-- If you want the screen to dim (a la Flux) when you enter normal mode
-- flip this to true.
vimmode:shouldDimScreenInNormalMode(false)

-- If you want to show an on-screen alert when you enter normal mode, set
-- this to true
vimmode:shouldShowAlertInNormalMode(true)

-- You can configure your on-screen alert font
vimmode:setAlertFont("Courier New")

-- Enter normal mode by typing a key sequence
vimmode:enterWithSequence("jk")

-- if you want to bind a single key to entering vim, remove the
-- :enterWithSequence('jk') line above and uncomment the bindHotKeys line
-- below:
--
-- To customize the hot key you want, see the mods and key parameters at:
--   https://www.hammerspoon.org/docs/hs.hotkey.html#bind
--
-- vm:bindHotKeys({ enter = { {'ctrl'}, ';' } })
