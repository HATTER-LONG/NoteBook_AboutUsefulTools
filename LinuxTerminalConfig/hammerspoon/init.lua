---@diagnostic disable: undefined-global
hs.hotkey.alertDuration = 0.2
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

if not HspoonList then
	HspoonList = {
		"ModalMgr",
		"SpoonInstall",
		"CircleClock",
		"WinWin",
		"WindowGrid",
		"MouseCircle",
	}
end

for _, v in pairs(HspoonList) do
	hs.loadSpoon(v)
end

require("VimModeConfig")
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

--[ TILE WINDOWS ON CURRENT SCREEN ]--------------------------------------
hs.hotkey.bind({ "cmd", "ctrl" }, "t", function()
	local wins = hs.window.filter.new():setCurrentSpace(true):getWindows()
	local screen = hs.screen.mainScreen():currentMode()
	local rect = hs.geometry(0, 0, screen["w"], screen["h"])
	hs.window.tiling.tileWindows(wins, rect)
end)
--[ END TILE WINDOWS ON CURRENT SCREEN ]-----------------------------------
--[ Main ]---------------------------------------------------------
local menuFocus = require("WindowFocus")
local mouseJump = require("mouseJump")

local mainCutFocusColor = { ["hex"] = "#3271ae", ["alpha"] = 0.8 }
local windowResizeColor = { ["hex"] = "#6b798e", ["alpha"] = 0.8 }
local windowSelectColor = { ["hex"] = "#45465e", ["alpha"] = 0.8 }
local menucolor = {
	["MainCut"] = mainCutFocusColor,
	["resizeM"] = windowResizeColor,
	["windowsFocus"] = windowSelectColor,
}
spoon.ModalMgr:new("MainCut")
local cmodal = spoon.ModalMgr.modal_list["MainCut"]
local mode = nil

local function enterMode(switchMode)
	if mode ~= "MainCut" then
		spoon.ModalMgr:deactivate({ mode })
	end
	menuFocus:deleteMenubarIndicator(mode)
	mode = switchMode
	menuFocus:drawMenubarIndicator(menucolor[mode], mode)
	spoon.ModalMgr:activate({ mode }, "#B22222")
end

local function quit()
	if mode ~= "MainCut" then
		menuFocus:deleteMenubarIndicator(mode)
		spoon.ModalMgr:deactivate({ mode })
		mode = "MainCut"
		menuFocus:drawMenubarIndicator(menucolor[mode], mode)
	else
		spoon.ModalMgr:deactivate({ mode })
		menuFocus:deleteMenubarIndicator(mode)
		--menuFocus:stopDrawBorder()
		mouseJump:toCenterOfWindow()
		mode = nil
	end
end

cmodal:bind("", "escape", "退出 ", function()
	quit()
end)

cmodal:bind("", "q", "退出 ", function()
	quit()
end)

cmodal:bind("", "r", "窗口管理模式", function()
	enterMode("resizeM")
end)

cmodal:bind("", "s", "窗口选择模式", function()
	enterMode("windowsFocus")
end)

local hsresizeM_keys = { "alt", "o" }
if string.len(hsresizeM_keys[2]) > 0 then
	spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "进入管理模式", function()
		menuFocus:drawMenubarIndicator(menucolor["MainCut"], "MainCut")
		spoon.ModalMgr:deactivateAll()
		spoon.ModalMgr:activate({ "MainCut" }, "#3271ae")
		mode = "MainCut"
		--menuFocus:startDrawBorder()
	end)
end

-- Finally we initialize ModalMgr supervisor
spoon.ModalMgr.supervisor:enter()

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
