--!strict
-- Explicit fake-only suite. Normal Play never opts into diagnostics or injected delay.
if game.ReplicatedStorage:GetAttribute("RunOperationsTests") ~= true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId == 10776833313, "Operations Test only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests") ~= true, "Use one regression runner at a time")
local unit = script.Parent.unit
-- Measure steady operation only after the normal fake country has subscribed and
-- completed two intervals. Studio startup can block Heartbeat beyond 750ms;
-- that safely suspends a batch and is recorded separately, not a solver CPU cost.
local first = require(game.ServerScriptService.Server.Services.ConstructionTestService).start()
local readyAt = os.clock()
while true do
	local player = game.Players:GetPlayers()[1]
	local actor = if player then first.inspect(player) else nil
	if actor and actor.subscribed and actor.state and actor.state.step >= 2 then break end
	assert(os.clock()-readyAt < 60, "Normal fake country readiness before Operations acceptance")
	game:GetService("RunService").Heartbeat:Wait()
end
print("[Operations runner] Normal fake country subscribed and progressed; starting unchanged acceptance")
for _, run in {require(unit["OperationsAtomic.spec"]), require(unit["OperationsScenario.spec"]),
	require(unit["OperationsSecurity.spec"]), require(unit["OperationsFleetLifecycle.spec"]), require(unit["OperationsSchedule.spec"])} do
	run()
end
game.ReplicatedStorage:SetAttribute("OperationsTestsReady", true)
local host = require(game.ServerScriptService.Server.Operations.OperationsService).start()
local start = os.clock()
while os.clock() - start < 180 do
	game:GetService("RunService").Heartbeat:Wait()
	local player = game.Players:GetPlayers()[1]
	local actor = if player then host.inspect(player) else nil
	if actor and actor.state.step >= 95 and actor.job then
		game.ReplicatedStorage:SetAttribute("OperationsDelayStep", actor.state.step)
		game.ReplicatedStorage:SetAttribute("OperationsDelayBank", actor.state.ledger.balanceMinor)
		host.delay(2)
		print("[Operations journey host] Bounded two-second delay injected")
		return
	end
end
error("Operations journey host did not reach its bounded injection point")
