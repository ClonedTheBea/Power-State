--!strict
local Players = game:GetService("Players")
local player = Players.LocalPlayer
assert(player, "Client bootstrap requires a local player")
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui
local existing = playerGui:FindFirstChild("PowerStateShell")
if existing then existing:Destroy() end

local ok, result = xpcall(function()
	local AppController = require(script.Parent.Controllers.AppController)
	return AppController.mount(playerGui)
end, function(problem: unknown): string
	return debug.traceback(tostring(problem))
end)

if not ok then
	warn("[Power State] Shell startup failed:\n" .. tostring(result))
	local partial = playerGui:FindFirstChild("PowerStateShell")
	if partial then partial:Destroy() end
	-- Keep the fallback independent of modules that may have failed to load.
	local gui = Instance.new("ScreenGui")
	gui.Name = "PowerStateShell"
	gui.ResetOnSpawn = false
	local message = Instance.new("TextLabel")
	message.Size = UDim2.fromScale(1, 1)
	-- Emergency literals deliberately survive a broken/missing Theme module.
	message.BackgroundColor3 = Color3.fromRGB(11, 20, 32)
	message.TextColor3 = Color3.fromRGB(237, 244, 248)
	message.TextSize = 18
	message.TextWrapped = true
	message.Text = "Power State could not open the interface.\nStop and restart Play after checking Studio Output.\nNo country data was loaded or changed."
	message.Parent = gui
	gui.Parent = playerGui
end
