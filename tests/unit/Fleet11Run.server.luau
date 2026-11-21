--!strict
if game.ReplicatedStorage:GetAttribute("RunFleet11Tests")~=true then return end
assert(game:GetService("RunService"):IsStudio()and game.GameId==10776833313 and game.CreatorId==149564436,"Fake Test only")
task.wait(10)
local f=require(script.Parent["FleetSchemaSize.spec"])()
require(script.Parent["FleetStagingProfile.spec"])(f,game.ReplicatedStorage:GetAttribute("Fleet11Measurement")or "unspecified")
require(script.Parent["OwnedFleetPerformance.spec"])(f,5)
if game.ReplicatedStorage:GetAttribute("Fleet11Measurement")=="after"then
 require(script.Parent["FleetCodec.spec"])(f)
 require(script.Parent["FleetFrozenCodec.spec"])(f)
 require(script.Parent["OwnedFleetAccounting.spec"])(f)
 require(script.Parent["FleetTransactions.spec"])(f)
 require(script.Parent["OwnedFleetSecurity.spec"])(f)
 require(script.Parent["OwnedFleetCancellation.spec"])(f)
 require(script.Parent["OwnedFleetBalance.spec"])(f)
 require(script.Parent["FleetPriceStudy.spec"])()
end
print("FLEET11_PROFILE_COMPLETE")
if game.ReplicatedStorage:GetAttribute("RunFleet11Regression")==true then
 local suites:{any}={require(script.Parent["P2a.spec"]),require(script.Parent["P2bAccounting.spec"]),
  require(script.Parent["P3c.spec"]),require(script.Parent["P3cSafety.spec"]),require(script.Parent["P3cRegression.spec"]),
  require(script.Parent["WindSite.spec"]),require(script.Parent["OperationsEncoding.spec"]),require(script.Parent["OperationsAtomic.spec"]),
  require(script.Parent["OperationsScenario.spec"]),require(script.Parent["OperationsSecurity.spec"]),require(script.Parent["FleetSolver.spec"]),
  require(script.Parent["FleetYieldOracle.spec"]),require(script.Parent["FleetScheduler.spec"]),require(script.Parent["OperationsFleetLifecycle.spec"]),
  require(script.Parent["OperationsSchedule.spec"])}
 for _,run in suites do
  run()
 end
 print("FLEET11_RETAINED_SERVER_PASS")
end
game.ReplicatedStorage:SetAttribute("Fleet11PureComplete",true)
if game.ReplicatedStorage:GetAttribute("RunFleet11Journey")==true then
 local host=require(game.ServerScriptService.Server.Services.ConstructionTestService).start()
 assert(host.fleet and host.storage.mode=="Fake","Owned fake host required")
 local untilAt=os.clock()+240;local player=game.Players:GetPlayers()[1]
 repeat task.wait(.2)until (host.inspect(player)and host.inspect(player).state and host.inspect(player).state.construction.receipt)or os.clock()>untilAt
 assert(host.inspect(player).state.construction.receipt,"Normal district journey prerequisite")
 task.wait(12)
 require(script.Parent.OwnedFleetFundJourney)(player)
end
