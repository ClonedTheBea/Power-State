--!strict
if game.ReplicatedStorage:GetAttribute("RunOperationsTests") ~= true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Operations Test only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests") ~= true, "Use one regression runner at a time")
local start = os.clock()
while game.ReplicatedStorage:GetAttribute("OperationsTestsReady") ~= true do
	assert(os.clock() - start < 180, "Operations server regression readiness deadline")
	task.wait(.1)
end
require(script.Parent["Operations.spec"])()
require(script.Parent["OperationsInteraction.spec"])()
require(script.Parent["OperationsRemote.spec"])()
require(script.Parent["OperationsJourney.spec"])()
print("[Operations integrated runner] PASS: complete fake-only operator journey")
