--!strict
-- Independent reporting keeps an obsolete legacy assertion from hiding later results.
if game.ReplicatedStorage:GetAttribute("RunIllustratedRetained")~=true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test client only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests")~=true,"One client runner")
game.ReplicatedStorage:SetAttribute("IllustratedWorldProof",false)
local gui=game.Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui
gui:WaitForChild("PowerStateShell");task.wait(1)
-- The legacy Run sequence normally mounts this placeholder after P3c finishes.
-- Restore that documented setup, rather than testing static currency against live Bank.
require(script.Parent.Parent.Client.Simulation.ConstructionClient).active().destroy()
require(script.Parent.Parent.Client.Controllers.AppController).mount(gui)
local failures=0
local suites: {{name: string, run: any}} = {
 {name="Gui",run=require(script.Parent["Gui.spec"])},{name="R1",run=require(script.Parent["R1.spec"])},
 {name="R2",run=require(script.Parent["R2.spec"])},{name="R3",run=require(script.Parent["R3.spec"])},
 {name="R31",run=require(script.Parent["R31.spec"])},{name="R33",run=require(script.Parent["R33.spec"])},
 {name="R35",run=require(script.Parent["R35.spec"])},{name="R37",run=require(script.Parent["R37.spec"])},
 {name="R34",run=require(script.Parent["R34.spec"])},
 {name="NativeSoak",run=require(script.Parent["Soak.spec"])},{name="P2bSoak",run=require(script.Parent["P2bSoak.spec"])},
}
for _,entry in suites do
 print("[Illustrated retained client] START",entry.name)
 local ok,problem=pcall(entry.run :: any,gui)
 if not ok then failures+=1;warn("[Illustrated retained client] FAILED",entry.name,problem) end
end
print("[Illustrated retained client] COMPLETE failures",failures)
