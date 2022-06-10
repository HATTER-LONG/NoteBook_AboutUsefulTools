---@diagnostic disable: undefined-global
local obj = {}
-- Key to launch application.
local app2Ime = {
	{ "/Applications/iTerm.app", "English" },
	{ "/Applications/Microsoft Edge.app", "English" },
	{ "/Applications/WeChat.app", "Chinese" },
	{ "/Applications/System Preferences.app", "English" },
	{ "/Applications/Visual Studio Code.app", "English" },
}

obj.SourceID = { ["English"] = "com.apple.keylayout.ABC", ["Chinese"] = "com.sogou.inputmethod.sogou.pinyin" }
-- obj.SourceID = { ["English"] = "com.apple.keylayout.ABC", ["Chinese"] = "com.apple.inputmethod.SCIM.ITABC" }

local function showInputMethod(reverse)
	-- 用于保存当前输入法
	local currentSourceID = hs.keycodes.currentSourceID()
	local tag
	hs.alert.closeSpecific(showUUID)

	if currentSourceID == obj.SourceID["English"] then
		if reverse then
			tag = " 中 "
		else
			tag = "ABC"
		end
	else
		if reverse then
			tag = "ABC"
		else
			tag = " 中 "
		end
	end
	hs.alert.show(tag, hs.mouse.getCurrentScreen(), 0.5)
end

function obj.GetCurrentMethodSourceID()
	return hs.keycodes.currentSourceID()
end

function obj.Chinese()
	hs.keycodes.currentSourceID(obj.SourceID["Chinese"])
	-- showInputMethod()
end

function obj.English()
	hs.keycodes.currentSourceID(obj.SourceID["English"])
	-- showInputMethod()
end

function obj.updateFocusAppInputMethod(appName, eventType, appObject)
	local ime = "English"
	if eventType == hs.application.watcher.activated or eventType == hs.application.watcher.launched then
		if hs.window.filter.isGuiApp(appname) == false then
			print("Now select app is " .. appName .. " path = " .. appObject:path())
			hs.window.filter.ignoreAlways(appname)
		end
		for _, app in pairs(app2Ime) do
			local appPath = app[1]
			local expectedIme = app[2]

			if appObject:path() == appPath then
				ime = expectedIme
				break
			end
		end
		print("Now select app is " .. appName .. " path = " .. appObject:path() .. "ime = " .. ime)
		if ime == "English" then
			obj:English()
		else
			obj:Chinese()
		end
	end
end
-- helper hotkey to figure out the app path and name of current focused window
-- 当选中某窗口按下ctrl+command+.时会显示应用的路径等信息
hs.hotkey.bind({ "ctrl", "cmd" }, ".", function()
	hs.alert.show(
		"App path:        "
			.. hs.window.focusedWindow():application():path()
			.. "\n"
			.. "App name:      "
			.. hs.window.focusedWindow():application():name()
			.. "\n"
			.. "IM source id:  "
			.. hs.keycodes.currentSourceID(),
		hs.mouse.getCurrentScreen(),
		0.6
	)
end)

local needSwitchInput = false
Binder = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.flagsChanged }, function(event)
	-- print("keycode " .. event:getKeyCode())
	if needSwitchInput == true and event:getKeyCode() == 56 and event:getFlags().shift == nil then
		local currentSourceID = hs.keycodes.currentSourceID()
		if currentSourceID == obj.SourceID["English"] then
			obj:Chinese()
		else
			obj:English()
		end
		showInputMethod(false)
		needSwitchInput = false
	elseif event:getKeyCode() == 56 and event:getFlags().shift then
		needSwitchInput = true
	else
		needSwitchInput = false
	end
end)
--Binder:start()

return obj
