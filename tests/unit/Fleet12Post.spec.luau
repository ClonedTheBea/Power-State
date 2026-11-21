--!strict
-- Explicit post-journey fake host verification; never starts a real adapter.
return function(player:Player)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local host=require(S.Services.ConstructionTestService).start()
 assert(host.fleet and host.storage.mode=="Fake"and host.storage.inspectStored,"Compact fake host required")
 local a=host.inspect(player);assert(a.state.fleet.windReceipt.definitionVersion==2,"Finish trial-price journey")
 require(script.Parent["FirstPlayableLifecycle.spec"])(player)
 a=host.inspect(player)
 local raw=host.storage.inspectStored(a.entry.key)
 assert(raw.storageFormat=="PowerStateHistoryPairs"and raw.storageVersion==1,"Actual saved compact envelope")
 local canonical=require(S.Domain.FleetStorageFormat).read(raw,player.UserId,function(v:any):string return H:JSONEncode(v)end)
 assert(canonical.country.fleet.windReceipt.priceMinor==200000 and canonical.country.bank.windConstructionSpentMinor==200000,"Exact restored trial capital")
 print("FLEET12_COMPACT_RECONNECT_PASS",H:JSONEncode({storageVersion=raw.storageVersion,storedBytes=#H:JSONEncode(raw),
  canonicalBytes=#H:JSONEncode(canonical),step=canonical.country.simulation.step,bankMinor=canonical.country.bank.balanceMinor,
  definitionVersion=canonical.country.fleet.windReceipt.definitionVersion,priceMinor=canonical.country.fleet.windReceipt.priceMinor}))
 require(script.Parent["OwnedFleetHostSoak.spec"])(player,200000)
 print("FLEET12_ENDURANCE_PASS")
end
