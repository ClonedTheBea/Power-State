--!strict
if game.ReplicatedStorage:GetAttribute("ReinforcementTests") ~= "All" then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Fake Test only")
local start=os.clock()
while game.ReplicatedStorage:GetAttribute("ReinforcementReady") ~= true do
	assert(os.clock()-start<120,"Pure gates readiness"); task.wait(.1)
end
require(script.Parent["Operations.spec"])()
require(script.Parent["OperationsInteraction.spec"])()
require(script.Parent["OperationsRemote.spec"])()
require(script.Parent["ReinforcementJourney.spec"])()
print("[Reinforcement client] COMPLETE")
