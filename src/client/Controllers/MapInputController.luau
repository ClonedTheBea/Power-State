--!strict
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Scope = require(script.Parent.Parent.Util.Scope)
local MapInputController = {}
type MapActions = { pan: (number, number) -> (), changeZoom: (number) -> (), recenter: () -> () }
function MapInputController.attach(map: MapActions, isActive: () -> boolean, leave: () -> (), assets: () -> ())
	local scope = Scope.new()
	local stick = Vector2.zero
	local function gamepadBegin(input: InputObject)
		if not isActive() or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == Enum.KeyCode.ButtonB then leave()
		elseif input.KeyCode == Enum.KeyCode.ButtonA then assets()
		elseif input.KeyCode == Enum.KeyCode.ButtonL1 then map.changeZoom(-0.15)
		elseif input.KeyCode == Enum.KeyCode.ButtonR1 then map.changeZoom(0.15) end
	end
	scope.add(UserInputService.InputChanged:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Thumbstick1 and isActive() then stick = Vector2.new(input.Position.X, -input.Position.Y) end
	end))
	scope.add(UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then stick = Vector2.zero end
	end))
	scope.add(RunService.RenderStepped:Connect(function(dt)
		if not isActive() or GuiService.MenuIsOpen then stick = Vector2.zero; return end
		if stick.Magnitude > 0.2 then map.pan(-stick.X * 400 * math.min(dt, 0.1), -stick.Y * 400 * math.min(dt, 0.1)) end
	end))
	scope.add(UserInputService.WindowFocusReleased:Connect(function() stick = Vector2.zero end))
	scope.add(UserInputService.InputBegan:Connect(function(input)
		if not isActive() or GuiService.MenuIsOpen or UserInputService:GetFocusedTextBox() then return end
		local key = input.KeyCode
		if key == Enum.KeyCode.Left then map.pan(48, 0)
		elseif key == Enum.KeyCode.Right then map.pan(-48, 0)
		elseif key == Enum.KeyCode.Up then map.pan(0, 48)
		elseif key == Enum.KeyCode.Down then map.pan(0, -48)
		elseif key == Enum.KeyCode.Equals or key == Enum.KeyCode.KeypadPlus then map.changeZoom(0.15)
		elseif key == Enum.KeyCode.Minus or key == Enum.KeyCode.KeypadMinus then map.changeZoom(-0.15)
		elseif key == Enum.KeyCode.Home then map.recenter() end
	end))
	return { gamepadBegin = gamepadBegin, destroy = function() scope.destroy() end }
end
return MapInputController
