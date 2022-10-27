---@diagnostic disable: undefined-global
hs.hotkey.alertDuration = 0.2
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

require("hs.ipc")
if not HspoonList then
	HspoonList = {
		"ModalMgr",
		"SpoonInstall",
		--		"CircleClock",
		"WinWin",
		"WindowGrid",
		"MouseCircle",
	}
end

for _, v in pairs(HspoonList) do
	hs.loadSpoon(v)
end

--require("VimModeConfig")
require("WinWinConfig")
require("WindowsConfig")

KeyUpDown = function(modifiers, key)
	hs.eventtap.keyStroke(modifiers, key, 0)
end

--[ Auto Switch input metod ]---------------------------------------------------------
local inputSwitch = require("InputSwitchConfig")
Appwatcher = hs.application.watcher.new(inputSwitch.updateFocusAppInputMethod)
Appwatcher:start()
--[ End Auto Switch input metod ]---------------------------------------------------------

--[ Spoon ]---------------------------------------------------------
local tronOrange = { ["hex"] = "#DF740C" }
spoon.MouseCircle.color = tronOrange

--[ End Spoon ]---------------------------------------------------------

--[ Vimouse ]---------------------------------------------------------
local vimouse = require("vimouse")
vimouse("alt", "m")
--require("VimMouseMode")
--[ End Vimouse ]---------------------------------------------------------

--[ WindowGrid ]---------------------------------------------------------
spoon.WindowGrid:bindHotkeys({ show_grid = { "alt", "g" } })
spoon.WindowGrid:start()
--[ End WindowGrid ]---------------------------------------------------------

--[ Switcher ]---------------------------------------------------------
local switcher = require("switcher")
local focusColor = { ["hex"] = "#6FC3DF", ["alpha"] = 0.8 }
--:setCurrentSpace(true)
Switcher_space = switcher.new(hs.window.filter.new():setDefaultFilter({}), {
	showTitles = true, -- disable text label over thumbnail
	showThumbnails = true, -- show app preview in thumbnail
	showSelectedThumbnail = false, -- disable large preview
	thumbnailSize = 128, -- double size of thumbnails (may be too big for laptop-mode?)
	highlightColor = focusColor,
})

-- Now using Witch instead, since Switch would miss newly created windows
hs.hotkey.bind({ "cmd", "ctrl" }, "j", function()
	Switcher_space:next()
end)
hs.hotkey.bind({ "cmd", "ctrl" }, "k", function()
	Switcher_space:previous()
end)
--[ End Switcher ]---------------------------------------------------------

-- Finally we initialize ModalMgr supervisor
spoon.ModalMgr.supervisor:enter()

Stackline = require("stackline")
Stackline:init()
-- Superbar = require("superbar.superbar")
-- Superbar:init()

--[ End Main ]---------------------------------------------------------
--[[local vscodeKeybinds = {
	hs.hotkey.new("", "escape", function()
		KeyUpDown("", "j")
		KeyUpDown("", "k")
	end),
}

local vscodeWatcher = hs.application.watcher.new(function(name, eventType, app)
	if eventType ~= hs.application.watcher.activated then
		return
	end
	local fnName = name == "Code" and "enable" or "disable"
	for _, keybind in ipairs(vscodeKeybinds) do
		keybind[fnName](keybind)
	end
end)
vscodeWatcher:start()
]]
local function reload_config()
	hs.reload()
end
local mash = { "ctrl", "alt", "cmd" }
hs.hotkey.bind(mash, "r", reload_config)
hs.alert.show("Hammerspoon config loaded")
