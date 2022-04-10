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
	}
end

for _, v in pairs(HspoonList) do
	hs.loadSpoon(v)
end

require("VimModeConfig")
require("WinWinConfig")
require("WindowsConfig")
require("InputSwitchConfig")

-- Finally we initialize ModalMgr supervisor
spoon.ModalMgr.supervisor:enter()
