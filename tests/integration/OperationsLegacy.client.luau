--!strict
if game.ReplicatedStorage:GetAttribute("OperationsV11Legacy") ~= true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Test only")
local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui") :: PlayerGui
local start = os.clock()
while game.ReplicatedStorage:GetAttribute("OperationsLegacyReady") ~= true do
	assert(os.clock() - start < 600, "Ten-thousand-seed retained server readiness"); task.wait(.1)
end
local client = script.Parent.Parent:WaitForChild("Client")
local first = require(client.Simulation.ConstructionClient)
while not first.active() do assert(os.clock() - start < 600, "Normal First Playable entry"); task.wait(.1) end
require(script.Parent["FirstPlayableRemote.spec"])(gui)
require(script.Parent["FirstPlayable.spec"])(gui)
first.active().destroy()
local bank = require(script.Parent["P3b.spec"])(gui, true)
bank.app.destroy()
local preview = require(client.Controllers.AppController).mount(gui)
for _, run in {require(script.Parent["Gui.spec"]), require(script.Parent["R1.spec"]), require(script.Parent["R2.spec"]),
	require(script.Parent["R3.spec"]), require(script.Parent["R31.spec"]), require(script.Parent["R33.spec"])} do run(gui) end
preview.destroy()
require(script.Parent["R35.spec"])(gui)
print("[Operations V11 retained client] COMPLETE; actual GUI / fake storage")
