--!strict
if game.ReplicatedStorage:GetAttribute("RunFleet12Tests")~=true then return end
assert(game:GetService("RunService"):IsStudio() and game.GameId==10776833313 and game.CreatorId==149564436,"Fleet12 fake Test only")
task.wait(3)
local f=require(script.Parent["FleetSchemaSize.spec"])()
require(script.Parent["Fleet12Price.spec"])(f)
require(script.Parent["Fleet12Storage.spec"])(f)
task.wait()
require(script.Parent["Fleet12Recovery.spec"])(f)
local scalar=function(v:any):string return game.HttpService:JSONEncode(v)end
require(script.Parent["FleetStagingProfile.spec"])(f,"v12-after-legacy")
require(script.Parent["FleetStagingProfile.spec"])(f,"v12-after-compact",function(seed:any)
 return require(game.ServerScriptService.Server.Adapters.FakeFleetStorageAdapter).create(seed,scalar)
end)
require(script.Parent["Fleet12Phases.spec"])(f)
require(script.Parent["OwnedFleetPerformance.spec"])(f,5)
require(script.Parent["OwnedFleetPerformance.spec"])(f,5,function(seed:any)
 return require(game.ServerScriptService.Server.Adapters.FakeFleetStorageAdapter).create(seed,scalar)
end)
require(script.Parent["OwnedFleetProgression.spec"])(nil,2)
if game.ReplicatedStorage:GetAttribute("RunFleet12Regression")==true then
 local suites:{any}={require(script.Parent["FleetCodec.spec"]),require(script.Parent["FleetFrozenCodec.spec"]),
  require(script.Parent["OwnedFleetAccounting.spec"]),require(script.Parent["OwnedFleetSecurity.spec"]),
  require(script.Parent["OwnedFleetCancellation.spec"]),require(script.Parent["OwnedFleetBalance.spec"])}
 for _,run in suites do task.wait();run(f)end
 local retained:{any}={require(script.Parent["P2a.spec"]),require(script.Parent["P2bAccounting.spec"]),
  require(script.Parent["P3c.spec"]),require(script.Parent["P3cSafety.spec"]),require(script.Parent["P3cRegression.spec"]),
  require(script.Parent["WindSite.spec"]),require(script.Parent["OperationsEncoding.spec"]),require(script.Parent["OperationsAtomic.spec"]),
  require(script.Parent["OperationsScenario.spec"]),require(script.Parent["OperationsSecurity.spec"]),require(script.Parent["FleetSolver.spec"]),
  require(script.Parent["FleetYieldOracle.spec"]),require(script.Parent["FleetScheduler.spec"]),require(script.Parent["OperationsFleetLifecycle.spec"]),
  require(script.Parent["OperationsSchedule.spec"])}
 for _,run in retained do task.wait();run()end
 print("FLEET12_RETAINED_REGRESSIONS_PASS")
end
print("FLEET12_LOCAL_GATES_PASS")
