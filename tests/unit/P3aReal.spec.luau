--!strict
-- Manual only. Owner-authorized single-key normal-operation proof; no fault injection.
return function(player:Player,phase:string,expectedCountryId:string?)
 assert(phase=="CreateOff" or phase=="ReconnectOn" or phase=="VerifyOn","Unknown proof phase")
 local Server=game.ServerScriptService.Server
 local Http=game:GetService("HttpService")
 local Adapter=require(Server.Adapters.DataStoreAdapter)
 local Profiles=require(Server.Services.ProfileService)
 local Generator=require(Server.World.WorldGenerator)
 local Restore=require(Server.Domain.ProfileCountry)
 local Country=require(Server.Simulation.Country)
 local Demand=require(Server.World.DemandModel)
 local Handler=require(Server.Simulation.IntentHandler)
 local Codec=require(Server.Domain.ProfileCodec)
 local Schema=require(Server.Domain.ProfileSchema)
 local function scalar(v:any):string return Http:JSONEncode(v)end
 local function id():string return Http:GenerateGUID(false)end
 local checks=0
 local function check(ok:boolean,message:string)assert(ok,message);checks+=1 end
 local adapter=Adapter.create(player,expectedCountryId)
 local prior=adapter.preflight
 check((phase=="CreateOff")== (prior==nil),"Correct initialization/reconnect phase")
 local world=if prior then Generator.create(prior.country.recipe.seed,prior.country.recipe.countryId,1)
  else Generator.create(string.lower((string.gsub(id(),"%-",""))),id(),1)
 local profiles=Profiles.create({adapter=adapter,utcMs=function()return DateTime.now().UnixTimestampMillis end,
  mono=os.clock,id=id,scalar=scalar,spawn=task.spawn,random=function()return .5 end,jobId="StudioRealProof",placeId=game.PlaceId})
 local e=profiles.reserve(player.UserId)
 local function waitFor(predicate:()->boolean)
  local began=os.clock()
  repeat profiles.tick();assert(not e.terminal,"Persistence suspended: "..tostring(e.reason));if predicate()then return end;task.wait(.05)until os.clock()-began>35
  error("Real persistence operation timeout")
 end
 local ok,failure=pcall(function()
  profiles.prepared(e,Restore.capture(world,Country.new(player.UserId,id(),world.network)))
  waitFor(function()return e.acquired end)
  local p=profiles.profile(e)
  check(p.ownerUserId==149564436 and p.country.bank.balanceMinor==0,"Exact owner and zero Bank")
  check(p.lease.fence==p.sessionEpoch and p.lease.expiresAtUtcMs>DateTime.now().UnixTimestampMillis,"Fenced active lease")
  local state=Restore.restore(p,world,e.commandEpoch)
  if prior then
   check(Codec.encode(p.country,scalar)==Codec.encode(prior.country,scalar),"Whole country unchanged by acquisition; no offline progression")
   check(p.sessionEpoch==prior.sessionEpoch+1,"Monotonic new session fence")
   check(prior.lease==nil,"Previous session released normally")
   check(state.online==(phase=="VerifyOn"),"Saved generator Off/On restored")
  else check(p.sessionEpoch==1 and state.step==0,"One atomic initial profile")end
  check(Codec.encode(Restore.capture(world,state),scalar)==Codec.encode(p.country,scalar),"Exact seed/network/history/MWh restore")
  profiles.activate(e)
  local function toggle(online:boolean)
   local result=Handler.handle(state,player.UserId,{version=1,kind="SetGenerator",epoch=state.epoch,
    sequence=state.lastSequence+1,revision=state.controlRevision,assetId=state.network.generatorId,online=online},os.clock())
   check(result=="Accepted","Server-authorized generator control")
   profiles.stage(e,Restore.capture(world,state),state.revision)
  end
  local function steps(n:number)
   for _=1,n do
    task.wait(1);check(profiles.canMutate(e),"Live lease before simulation")
    local d=Demand.atStep(state.step,world.meanTemperatureCentiC,1000);Country.advance(state,d.demandMW)
    profiles.stage(e,Restore.capture(world,state),state.revision)
   end
  end
  if phase=="CreateOff" then steps(3);toggle(false);steps(3)
  elseif phase=="ReconnectOn" then steps(3);toggle(true);steps(3)end
  local before=profiles.profile(e).profileRevision
  profiles.checkpoint(e);waitFor(function()return profiles.profile(e).profileRevision>before end)
  local saved=adapter.read("u:149564436")
  Schema.validate(saved,player.UserId,scalar)
  check(Codec.encode(saved.country,scalar)==Codec.encode(Restore.capture(world,state),scalar),"Uncached durable checkpoint agrees exactly")
  check(saved.country.simulation.deliveredMWh<=saved.country.simulation.requestedMWh,"Energy conservation")
  local renewedBefore=saved.profileRevision
  profiles.checkpoint(e);waitFor(function()return profiles.profile(e).profileRevision>renewedBefore end)
  local renewed=profiles.profile(e)
  check(renewed.lastCommit.kind=="Renew" and renewed.countryRevision==saved.countryRevision,"Renew does not add gameplay")
  check(renewed.lease.expiresAtUtcMs>=saved.lease.expiresAtUtcMs,"Lease renewal")
  profiles.close(e);waitFor(function()return profiles.stats().profiles==0 end)
  local final=adapter.read("u:149564436")
  check(final.lease==nil and final.lastCommit.kind=="Release","Uncached atomic release confirmed")
  check(Codec.encode(final.country,scalar)==Codec.encode(saved.country,scalar),"Release preserves complete checkpoint")
  local bytes=Schema.validate(final,player.UserId,scalar)
  print("[P3a REAL RESULT] "..Http:JSONEncode({phase=phase,checks=checks,userId=player.UserId,universe=game.GameId,
   countryId=final.country.recipe.countryId,seed=final.country.recipe.seed,versions=final.country.recipe,
   profileRevision=final.profileRevision,sessionEpoch=final.sessionEpoch,bankMinor=final.country.bank.balanceMinor,
   step=final.country.simulation.step,online=final.country.simulation.online,
   requestedMWh=final.country.simulation.requestedMWh,deliveredMWh=final.country.simulation.deliveredMWh,
   historyIndex=final.country.simulation.historyIndex,encodedBytes=bytes,coordinator=profiles.stats()}))
  for i,record in adapter.stats().records do print("[P3a REAL REQUEST] "..phase.." "..i.." "..Http:JSONEncode(record))end
 end)
 if not ok then
  profiles.shutdown();local began=os.clock()
  while profiles.stats().profiles>0 and os.clock()-began<20 do profiles.tick();task.wait(.05)end
  error(failure)
 end
end
