---@diagnostic disable: undefined-global

local focusColor = { ["hex"] = "#0078d4", ["alpha"] = 0.8 }
local menuFocus = require("WindowFocus")
local mouseJump = require("mouseJump")
local yabai = require("yabai")
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
local function quit()
	spoon.ModalMgr:deactivate({ "resizeM" })
	menuFocus:deleteMenubarIndicator("resizeM")
	mouseJump:toCenterOfWindow()
end

if spoon.WinWin then
	spoon.ModalMgr:new("resizeM")
	local cmodal = spoon.ModalMgr.modal_list["resizeM"]
	cmodal:bind("", "q", "退出 ", function()
		quit()
	end)
	cmodal:bind("", "escape", "退出 ", function()
		quit()
	end)
	cmodal:bind("", "tab", "键位提示", function()
		spoon.ModalMgr:toggleCheatsheet()
	end)
	cmodal:bind("", "F", "全屏", function()
		spoon.WinWin:moveAndResize("fullscreen")
	end)
	cmodal:bind("", "C", "居中", function()
		spoon.WinWin:moveAndResize("center")
	end)
	cmodal:bind("alt", "x", "顺时针旋转", function()
		yabai({ "-m", "space", "--rotate", "270" })
	end)
	cmodal:bind({ "shift", "alt" }, "x", "逆时针旋转", function()
		yabai({ "-m", "space", "--rotate", "90" })
	end)
	cmodal:bind("", "=", "窗口放大", function()
		yabai({ "-m", "window", "--resize", "left:-50:0" })
		yabai({ "-m", "window", "--resize", "right:50:0" })
		yabai({ "-m", "window", "--resize", "top:0:-50" })
		yabai({ "-m", "window", "--resize", "buttom:0:50" })
	end)
	cmodal:bind("", "-", "窗口缩小", function()
		yabai({ "-m", "window", "--resize", "left:50:0" })
		yabai({ "-m", "window", "--resize", "right:-50:0" })
		yabai({ "-m", "window", "--resize", "top:0:50" })
		yabai({ "-m", "window", "--resize", "buttom:0:-50" })
	end)

	cmodal:bind("ctrl", "H", "向左收缩窗口", function()
		spoon.WinWin:stepResize("left")
	end)
	cmodal:bind("ctrl", "L", "向右扩展窗口", function()
		spoon.WinWin:stepResize("right")
	end)
	cmodal:bind("ctrl", "K", "向上收缩窗口", function()
		spoon.WinWin:stepResize("up")
	end)
	cmodal:bind("ctrl", "J", "向下扩镇窗口", function()
		spoon.WinWin:stepResize("down")
	end)

	cmodal:bind("", "H", "窗口移至左边屏幕", function()
		moveToScreen("left")
	end)
	cmodal:bind("", "L", "窗口移至右边屏幕", function()
		moveToScreen("right")
	end)
	cmodal:bind("", "K", "窗口移至上边屏幕", function()
		moveToScreen("up")
	end)
	cmodal:bind("", "J", "窗口移动下边屏幕", function()
		moveToScreen("down")
	end)
	cmodal:bind("", "space", "窗口移至下一个屏幕", function()
		moveToScreen("next")
	end)
	cmodal:bind("", "B", "撤销最后一个窗口操作", function()
		spoon.WinWin:undo()
	end)
	cmodal:bind("", "R", "重做最后一个窗口操作", function()
		spoon.WinWin:redo()
	end)

	cmodal:bind("", "t", "将光标移至所在窗口中心位置", function()
		spoon.WinWin:centerCursor()
	end)

	-- 定义窗口管理模式快捷键
	local hsresizeM_keys = { "alt", "o" }
	if string.len(hsresizeM_keys[2]) > 0 then
		spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "进入窗口管理模式", function()
			menuFocus:drawMenubarIndicator(focusColor, "resizeM")
			spoon.ModalMgr:deactivateAll()
			spoon.ModalMgr:activate({ "resizeM" }, "#B22222")
		end)
	end
end
