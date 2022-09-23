---@diagnostic disable: undefined-global

-- local focusColor = { ["hex"] = "#0078d4", ["alpha"] = 0.8 }
-- local menuFocus = require("WindowFocus")
-- local mouseJump = require("mouseJump")
-- local yabai = require("yabai")
local function moveToScreen(direction)
	local cwin = hs.window.focusedWindow()
	if cwin then
		local cscreen = cwin:screen()
		if direction == "up" then
			cwin:moveOneScreenNorth(true)
		elseif direction == "down" then
			cwin:moveOneScreenSouth(true)
		elseif direction == "left" then
			cwin:moveOneScreenWest(true)
		elseif direction == "right" then
			cwin:moveOneScreenEast(true)
		elseif direction == "next" then
			cwin:moveToScreen(cscreen:next(), true)
		else
			hs.alert.show("Unknown direction: " .. direction)
		end
	else
		hs.alert.show("No focused window!")
	end
end

-- hs.hotkey.bind({ "ctrl", "alt" }, "H", function()
-- 	moveToScreen("left")
-- end)
-- hs.hotkey.bind({ "ctrl", "alt" }, "L", function()
-- 	moveToScreen("right")
-- end)
-- hs.hotkey.bind({ "ctrl", "alt" }, "K", function()
-- 	moveToScreen("up")
-- end)
-- hs.hotkey.bind({ "ctrl", "alt" }, "J", function()
-- 	moveToScreen("down")
-- end)
-- hs.hotkey.bind({ "ctrl", "alt" }, "space", function()
-- 	moveToScreen("next")
-- end)

-- 使用 shkd 进行窗口快捷选择
-- local mouseJump = require("mouseJump")
-- spoon.ModalMgr:new("windowsFocus")
-- local cmodal = spoon.ModalMgr.modal_list["windowsFocus"]
-- local menuFocus = require("WindowFocus")
--
-- cmodal:bind("", "q", "退出", function()
-- 	spoon.ModalMgr:deactivate({ "windowsFocus" })
-- 	menuFocus:deleteMenubarIndicator("windowsFocus")
-- 	mouseJump:toCenterOfWindow()
-- 	menuFocus:stopDrawBorder()
-- end)
--
-- cmodal:bind("", "j", "选择下方窗口", function()
-- 	hs.window.filter.focusSouth()
-- end)
-- cmodal:bind("", "k", "选择上方窗口", function()
-- 	hs.window.filter.focusNorth()
-- end)
-- cmodal:bind("", "h", "选择左侧窗口", function()
-- 	hs.window.filter.focusWest()
-- end)
-- cmodal:bind("", "l", "选择右侧窗口", function()
-- 	hs.window.filter.focusEast()
-- end)
--
-- local hsresizeM_keys = { "alt", "s" }
-- if string.len(hsresizeM_keys[2]) > 0 then
-- 	spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "进入窗口选择模式", function()
-- 		menuFocus:drawMenubarIndicator(borderColor, "windowsFocus")
-- 		spoon.ModalMgr:deactivateAll()
-- 		spoon.ModalMgr:activate({ "windowsFocus" }, "#3271ae")
-- 		menuFocus:startDrawBorder()
-- 	end)
-- end

-- 由于 hammerspoon 对于常用的切换选中操作有时会卡顿，使用 yabai + skhd 替换常用快捷
-- local function quit()
-- 	spoon.ModalMgr:deactivate({ "resizeM" })
-- 	menuFocus:deleteMenubarIndicator("resizeM")
-- 	mouseJump:toCenterOfWindow()
-- end
--
-- if spoon.WinWin then
-- 	spoon.ModalMgr:new("resizeM")
-- 	local cmodal = spoon.ModalMgr.modal_list["resizeM"]
-- 	cmodal:bind("", "q", "退出 ", function()
-- 		quit()
-- 	end)
-- 	cmodal:bind("", "escape", "退出 ", function()
-- 		quit()
-- 	end)
-- 	cmodal:bind("", "tab", "键位提示", function()
-- 		spoon.ModalMgr:toggleCheatsheet()
-- 	end)
-- 	cmodal:bind("", "F", "全屏", function()
-- 		spoon.WinWin:moveAndResize("fullscreen")
-- 	end)
-- 	cmodal:bind("", "C", "居中", function()
-- 		spoon.WinWin:moveAndResize("center")
-- 	end)
-- 	cmodal:bind("alt", "x", "顺时针旋转", function()
-- 		yabai({ "-m", "space", "--rotate", "270" })
-- 	end)
-- 	cmodal:bind({ "shift", "alt" }, "x", "逆时针旋转", function()
-- 		yabai({ "-m", "space", "--rotate", "90" })
-- 	end)
-- 	cmodal:bind("", "=", "窗口放大", function()
-- 		yabai({ "-m", "window", "--resize", "left:-50:0" })
-- 		yabai({ "-m", "window", "--resize", "right:50:0" })
-- 		yabai({ "-m", "window", "--resize", "top:0:-50" })
-- 		yabai({ "-m", "window", "--resize", "buttom:0:50" })
-- 	end)
-- 	cmodal:bind("", "-", "窗口缩小", function()
-- 		yabai({ "-m", "window", "--resize", "left:50:0" })
-- 		yabai({ "-m", "window", "--resize", "right:-50:0" })
-- 		yabai({ "-m", "window", "--resize", "top:0:50" })
-- 		yabai({ "-m", "window", "--resize", "buttom:0:-50" })
-- 	end)
--
-- 	cmodal:bind("ctrl", "A", "向左收缩窗口", function()
-- 		spoon.WinWin:stepResize("left")
-- 	end)
-- 	cmodal:bind("ctrl", "D", "向右扩展窗口", function()
-- 		spoon.WinWin:stepResize("right")
-- 	end)
-- 	cmodal:bind("ctrl", "W", "向上收缩窗口", function()
-- 		spoon.WinWin:stepResize("up")
-- 	end)
-- 	cmodal:bind("ctrl", "S", "向下扩镇窗口", function()
-- 		spoon.WinWin:stepResize("down")
-- 	end)
-- 	cmodal:bind("", "A", "向左移动", function()
-- 		spoon.WinWin:stepMove("left")
-- 	end)
-- 	cmodal:bind("", "D", "向右移动", function()
-- 		spoon.WinWin:stepMove("right")
-- 	end)
-- 	cmodal:bind("", "W", "向上移动", function()
-- 		spoon.WinWin:stepMove("up")
-- 	end)
-- 	cmodal:bind("", "S", "向下移动", function()
-- 		spoon.WinWin:stepMove("down")
-- 	end)
--
-- 	cmodal:bind("", "H", "左半屏", function()
-- 		spoon.WinWin:moveAndResize("halfleft")
-- 	end)
-- 	cmodal:bind("", "L", "右半屏", function()
-- 		spoon.WinWin:moveAndResize("halfright")
-- 	end)
-- 	cmodal:bind("", "K", "上半屏", function()
-- 		spoon.WinWin:moveAndResize("halfup")
-- 	end)
-- 	cmodal:bind("", "J", "下半屏", function()
-- 		spoon.WinWin:moveAndResize("halfdown")
-- 	end)
-- 	cmodal:bind("", "B", "撤销最后一个窗口操作", function()
-- 		spoon.WinWin:undo()
-- 	end)
-- 	cmodal:bind("", "R", "重做最后一个窗口操作", function()
-- 		spoon.WinWin:redo()
-- 	end)
--
-- 	cmodal:bind("", "t", "将光标移至所在窗口中心位置", function()
-- 		spoon.WinWin:centerCursor()
-- 	end)
--
-- 	-- 定义窗口管理模式快捷键
-- 	local hsresizeM_keys = { "alt", "o" }
-- 	if string.len(hsresizeM_keys[2]) > 0 then
-- 		spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "进入窗口管理模式", function()
-- 			menuFocus:drawMenubarIndicator(focusColor, "resizeM")
-- 			spoon.ModalMgr:deactivateAll()
-- 			spoon.ModalMgr:activate({ "resizeM" }, "#B22222")
-- 		end)
-- 	end
-- end
