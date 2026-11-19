--!strict
-- Explicit continuation after an already-recorded successful R3.7 suite.
if game.ReplicatedStorage:GetAttribute("RunIllustratedEnduranceTail")~=true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests")~=true,"One client regression runner")
game.ReplicatedStorage:SetAttribute("IllustratedWorldProof",false)
local gui=game.Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
gui:WaitForChild("PowerStateShell");task.wait(1)
local construction=require(script.Parent.Parent.Client.Simulation.ConstructionClient)
if construction.active() then construction.active().destroy() end
local p2bOnly=game.ReplicatedStorage:GetAttribute("IllustratedEnduranceP2bOnly")==true
if not p2bOnly then
	require(script.Parent["R34.spec"])(gui)
	require(script.Parent["Soak.spec"])(gui)
end
require(script.Parent["P2bSoak.spec"])(gui)
print(if p2bOnly then "[IW11 endurance tail] COMPLETE: full-duration P2b continuation" else "[IW11 endurance tail] COMPLETE: all three full-duration suites")
