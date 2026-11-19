--!strict
-- Explicit runtime context for retained Test-server-only fake suites.
if game.ReplicatedStorage:GetAttribute("RunIllustratedServerTests")~=true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313,"Test only")
assert(game.ReplicatedStorage:GetAttribute("RunRegressionTests")~=true and game.ReplicatedStorage:GetAttribute("RunIllustratedTests")~=true,"Measure server suites separately")
local host=require(game.ServerScriptService.Server.Services.ConstructionTestService).start()
local deadline=os.clock()+60
while true do
	local player=game.Players:GetPlayers()[1]
	local actor=if player then host.inspect(player) else nil
	if actor and actor.subscribed and actor.state and actor.state.step>=2 then break end
	assert(os.clock()<deadline,"Fake gameplay startup")
	game:GetService("RunService").Heartbeat:Wait()
end
local suites: {{name: string, run: any}} = {
 {name="OperationsAtomic",run=require(script.Parent["OperationsAtomic.spec"])},
 {name="OperationsSecurity",run=require(script.Parent["OperationsSecurity.spec"])},
 {name="OperationsScenario",run=require(script.Parent["OperationsScenario.spec"])},
 {name="OperationsFleetLifecycle",run=require(script.Parent["OperationsFleetLifecycle.spec"])},
 {name="ReinforcementModel",run=require(script.Parent["ReinforcementModel.spec"])},
 {name="ReinforcementTransaction",run=require(script.Parent["ReinforcementTransaction.spec"])},
 {name="ReinforcementEconomy",run=require(script.Parent["ReinforcementEconomy.spec"])},
 {name="ReinforcementResources",run=require(script.Parent["ReinforcementResources.spec"])},
 {name="OperationsSchedule",run=require(script.Parent["OperationsSchedule.spec"])},
}
for _,entry in suites do
 print("[Illustrated retained server]",entry.name);entry.run()
end
print("[Illustrated retained server] COMPLETE; fake storage only")
