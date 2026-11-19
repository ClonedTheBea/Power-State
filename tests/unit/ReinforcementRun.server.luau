--!strict
local stage = game.ReplicatedStorage:GetAttribute("ReinforcementTests")
if not stage then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Fake Test only")
assert(game.ReplicatedStorage:GetAttribute("RunOperationsTests") ~= true and game.ReplicatedStorage:GetAttribute("RunRegressionTests") ~= true, "One runner")
require(script.Parent["ReinforcementModel.spec"])()
print("[Reinforcement gates] Stage A COMPLETE")

if stage ~= "A" then
	require(script.Parent["ReinforcementTransaction.spec"])()
	print("[Reinforcement gates] Stage B COMPLETE")
end

if stage == "All" then
	require(script.Parent["ReinforcementEconomy.spec"])()
	print("[Reinforcement gates] Stage C COMPLETE")
	local host = require(game.ServerScriptService.Server.Operations.OperationsService).start()
	host.storage.faults.setHook(function(kind: string)
		local player=game.Players:GetPlayers()[1]
		local actor=if player then host.inspect(player) else nil
		if kind=="Update" and actor and actor.investing then
			print("[Reinforcement GUI capture] Pending fake save; three-second injected latency")
			task.wait(3)
		end
	end)
	game.ReplicatedStorage:SetAttribute("ReinforcementReady",true)
end

if stage == "Regression" then
	require(script.Parent["ReinforcementResources.spec"])()
	require(script.Parent["OperationsEncoding.spec"])()
	require(script.Parent["OperationsAtomic.spec"])()
	require(script.Parent["OperationsScenario.spec"])()
	require(script.Parent["OperationsSecurity.spec"])()
	require(script.Parent["OperationsFleetLifecycle.spec"])()
	require(script.Parent["FleetSolver.spec"])()
	require(script.Parent["FleetYieldOracle.spec"])()
	require(script.Parent["FleetScheduler.spec"])()
	require(script.Parent["OperationsSchedule.spec"])()
	print("[Reinforcement retained Operations] COMPLETE")
end

if stage == "Capture" then
	local host=require(game.ServerScriptService.Server.Operations.OperationsService).start()
	host.storage.faults.setHook(function(kind:string)
		local player=game.Players:GetPlayers()[1]
		local actor=if player then host.inspect(player) else nil
		if kind=="Update" and actor and actor.investing then
			print("[Reinforcement capture] ACTUAL PENDING;12-second injected fake response latency")
			task.wait(12)
		end
	end)
	game.ReplicatedStorage:SetAttribute("ReinforcementReady",true)
end
