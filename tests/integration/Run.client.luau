--!strict
-- Isolated test mapping only. Restart Play after Rojo sync to reload all modules.
if not game:GetService("RunService"):IsStudio() then return end
local player=game:GetService("Players").LocalPlayer
local playerGui=player:WaitForChild("PlayerGui") :: PlayerGui
playerGui:WaitForChild("PowerStateShell")
task.wait(1)
local total=0
for _,name in {"Gui.spec","R1.spec","R2.spec","R3.spec","R31.spec","R33.spec"} do
	local module=script.Parent:WaitForChild(name) :: ModuleScript
	local run=require(module)
	total+=run(playerGui)
end
print(string.format("[Power State isolated client] PASS: %d assertions; server suites report separately",total))
print("[Power State isolated client] Starting existing ten-minute native Soak.spec")
require(script.Parent:WaitForChild("Soak.spec") :: ModuleScript)(playerGui)
