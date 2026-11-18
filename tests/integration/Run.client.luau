--!strict
-- Isolated test mapping only. Restart Play after Rojo sync to reload all modules.
if not game:GetService("RunService"):IsStudio() then return end
if game.GameId ~= 10776833313 then warn("Isolated runner requires approved Test universe"); return end
local player=game:GetService("Players").LocalPlayer
local playerGui=player:WaitForChild("PlayerGui") :: PlayerGui
playerGui:WaitForChild("PowerStateShell")
task.wait(1)
-- Explicit Studio investigation only; production excludes this entire runner.
if game:GetService("ReplicatedStorage"):GetAttribute("R35FocusOnly")==true then
	for _=1,3 do require(script.Parent["R35.spec"])(playerGui) end
	return
end
require(script.Parent["P2a.spec"])(playerGui)
require(script.Parent["P2b.spec"])(playerGui)
require(script.Parent["P2aRemote.spec"])()
require(script.Parent["P2aRemote.spec"])("P2b")
require(script.Parent["P3c.spec"])(playerGui)
local total=0
for _,run in {require(script.Parent["Gui.spec"]),require(script.Parent["R1.spec"]),require(script.Parent["R2.spec"]),
	require(script.Parent["R3.spec"]),require(script.Parent["R31.spec"]),require(script.Parent["R33.spec"])} do
	total+=run(playerGui)
end
print(string.format("[Power State isolated client] PASS: %d assertions; server suites report separately",total))
for _=1,3 do require(script.Parent["R35.spec"])(playerGui) end
require(script.Parent["R37.spec"])(playerGui)
require(script.Parent["R34.spec"])(playerGui)
print("[Power State isolated client] Starting existing ten-minute native Soak.spec")
require(script.Parent["Soak.spec"])(playerGui)
require(script.Parent["P2bSoak.spec"])(playerGui)
local shell=playerGui:FindFirstChild("PowerStateShell"); if shell then shell:Destroy() end
require(script.Parent.Parent.Client.Simulation.SimulationClient).mount(playerGui, "P2b")
