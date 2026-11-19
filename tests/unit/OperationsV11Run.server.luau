--!strict
local mode = game.ReplicatedStorage:GetAttribute("OperationsV11Run")
if mode ~= "Baseline" and mode ~= "Candidate" then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Test only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests") ~= true and game.ReplicatedStorage:GetAttribute("RunOperationsTests") ~= true, "One runner")
require(script.Parent["OperationsProfile.spec"])(mode)
if mode == "Candidate" then
	require(script.Parent["OperationsEncoding.spec"])()
	for _, run in {require(script.Parent["OperationsAtomic.spec"]), require(script.Parent["OperationsScenario.spec"]),
		require(script.Parent["OperationsSecurity.spec"]), require(script.Parent["OperationsFleetLifecycle.spec"]),
		require(script.Parent["FleetSolver.spec"]), require(script.Parent["FleetYieldOracle.spec"]),
		require(script.Parent["FleetScheduler.spec"]), require(script.Parent["OperationsSchedule.spec"])} do run() end
end
print("[Operations V11 Stage A] COMPLETE " .. mode)
