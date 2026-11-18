--!strict
return function()
 local Server=game.ServerScriptService.Server
 local Codec=require(Server.Domain.ProfileCodec)
 local Schema=require(Server.Domain.ProfileSchema)
 local Lease=require(Server.Domain.ProfileLease)
 local Restore=require(Server.Domain.ProfileCountry)
 local Migrations=require(Server.Domain.ProfileMigrations)
 local Profiles=require(Server.Services.ProfileService)
 local Fake=require(Server.Adapters.FakeDataStoreAdapter)
 local Generator=require(Server.World.WorldGenerator)
 local Queue=require(Server.World.GenerationScheduler)
 local Country=require(Server.Simulation.Country)
 local Demand=require(Server.World.DemandModel)
 local Handler=require(Server.Simulation.IntentHandler)
 local Http=game:GetService("HttpService")
 local checks=0
 local function check(value:boolean,message:string)assert(value,message);checks+=1 end
 local function scalar(v:any):string return Http:JSONEncode(v)end
 local function id():string return Http:GenerateGUID(false)end
 local owner=149564436;local seed="df307a52185f423288df5749229f0808"
 local world=Generator.create(seed,id(),1)
 local state=Country.new(owner,id(),world.network)
 local candidate=Restore.capture(world,state)
 local function op(kind:string,p:any?):any
  return {id=id(),kind=kind,owner=owner,sessionId=if p then p.lease.ownerSessionId else id(),jobId="Unit",placeId=1,
   candidate=candidate,fence=if p then p.sessionEpoch else nil,baseRevision=if p then p.profileRevision else nil}
 end
 local initial=op("Acquire",nil)
 local p=Lease.apply(nil,initial,1000000,scalar)
 check(p.country.recipe.seed==seed and p.sessionEpoch==1,"Atomic initialization")
 check(Codec.encode(p,scalar)==Codec.encode(Lease.apply(p,initial,1000100,scalar),scalar),"Duplicate acquisition idempotent")
 local other=op("Acquire",nil)
 local rejected,why=Lease.apply(p,other,1000200,scalar)
 check(rejected==nil and why=="InUse","Competing owner refused")
 local taken=Lease.apply(p,other,1180000,scalar)
 check(taken.sessionEpoch==2 and taken.country.recipe.countryId==world.countryId,"Expiry reacquires same identity with new fence")
 check(Lease.apply(taken,op("Checkpoint",p),1180001,scalar)==nil,"Stale writer fenced")
 check(Lease.apply(p,op("Renew",p),1180000,scalar)==nil,"Expired owner cannot renew")
 local release=op("Release",p);local released=Lease.apply(p,release,1001000,scalar)
 check(released.lease==nil and released.country.recipe.countryId==world.countryId,"Atomic release")
 check(Lease.apply(released,release,1001001,scalar).profileRevision==released.profileRevision,"Ambiguous release idempotent")
 check(Lease.apply(released,op("Checkpoint",p),1001002,scalar)==nil,"Write after release rejected")
 local renew=op("Renew",p);local renewed=Lease.apply(p,renew,1050000,scalar)
 check(renewed.countryRevision==p.countryRevision and renewed.lastSavedAtUtc==p.lastSavedAtUtc,"Renew is not gameplay save")
 check(renewed.lease.expiresAtUtcMs==1230000,"Renew extends lease")
 local request=op("Checkpoint",p);request.snapshot=Codec.copy(candidate);request.snapshot.recipe.seed=string.rep("a",32);request.countryRevision=1
 check(not pcall(Lease.apply,p,request,1010000,scalar),"Cannot change saved recipe")
 local restored=Restore.restore(p,world,id())
 check(restored.step==0 and restored.epoch~=world.countryId and restored.controlRevision==0,"Fresh session separates identity")
 local attack={version=1,kind="SetGenerator",epoch=state.epoch,sequence=1,revision=0,assetId=state.network.generatorId,online=false}
 check(Handler.handle(restored,owner,attack,1)=="StaleSession","Old command epoch rejected")
 local maxBytes=0;local encodeTimes={};local original=Country.new(owner,id(),world.network)
 for step=1,2881 do
  if step==1440 then original.online=false elseif step==1500 then original.online=true end
  local d=Demand.atStep(original.step,world.meanTemperatureCentiC,1000);Country.advance(original,d.demandMW)
  if table.find({1,719,720,1439,1440,1441,1500,2880,2881},step)then
   local copy=Codec.copy(p);copy.country=Restore.capture(world,original);copy.countryRevision=original.revision;copy.lastCommit.countryRevision=copy.countryRevision
   local began=os.clock();local encoded=Codec.encode(copy,scalar);table.insert(encodeTimes,(os.clock()-began)*1000);maxBytes=math.max(maxBytes,#encoded)
   local roundtrip=Http:JSONDecode(encoded);Schema.validate(roundtrip,owner,scalar)
   check(Codec.encode(roundtrip,scalar)==encoded,"Canonical round trip")
   local resumed=Restore.restore(roundtrip,world,id())
   check(resumed.online==original.online and resumed.step==original.step,"Operational/clock restore")
   check(resumed.requestedMWh==original.requestedMWh and resumed.deliveredMWh==original.deliveredMWh,"Exact energy round trip")
   check(resumed.historyIndex==original.historyIndex and resumed.windowDelivered==original.windowDelivered,"Reliability ring restore")
   local uninterrupted=Codec.copy(original);local nextDemand=Demand.atStep(original.step,world.meanTemperatureCentiC,1000)
   Country.advance(uninterrupted,nextDemand.demandMW);Country.advance(resumed,nextDemand.demandMW)
   check(resumed.requestedMWh==uninterrupted.requestedMWh and resumed.deliveredMWh==uninterrupted.deliveredMWh and resumed.windowRequested==uninterrupted.windowRequested,"Replay across midnight/ring wrap")
  end
 end
 local off=Codec.copy(p);local offState=Restore.restore(p,world,id())
 check(Handler.handle(offState,owner,{version=1,kind="SetGenerator",epoch=offState.epoch,sequence=1,revision=0,assetId=offState.network.generatorId,online=false},1)=="Accepted","Off between steps")
 off.country=Restore.capture(world,offState);off.countryRevision=offState.revision;off.lastCommit.countryRevision=offState.revision
 local resumedOff=Restore.restore(off,world,id())
 check(not resumedOff.online and resumedOff.report.deliveredMW==0 and resumedOff.step==0 and resumedOff.deliveredMWh==0,"Off restoration does not add a step")
 local corruptions:{(any)->()}={
  function(v)v.schemaVersion=2 end,function(v)v.ownerUserId=1 end,function(v)v.country.bank.balanceMinor=1 end,
  function(v)v.country.recipe.generationVersion=2 end,function(v)v.country.recipe.candidate=9 end,
  function(v)v.country.network.lines[1].to="foreign"end,function(v)v.country.network.nodes[1].x=-1 end,
  function(v)v.country.simulation.requestedMWh=0/0 end,function(v)v.country.simulation.deliveredMWh=math.huge end,
  function(v)v.country.simulation.windowRequested=-1 end,function(v)v.country.simulation.historyIndex=1 end,
  function(v)v.country.settlement.name="Renamed"end,function(v)v.country.deltas.builtNodes={{}}end,
  function(v)v.extra=true end,function(v)v.lease.fence=99 end,function(v)v.country.recipe.seed="bad"end,
  function(v)v.lastCommit.committedProfileRevision=999 end,function(v)v.country=nil end,
  function(v)v.country.simulation.requestedMWh=1e300;v.country.simulation.windowRequested=1e300 end,
 }
 for _,corrupt in corruptions do local bad=Codec.copy(p);corrupt(bad);check(not pcall(Schema.validate,bad,owner,scalar),"Corrupt/unsupported profile refused")end
 check(Codec.encode(Migrations.read(p,owner,scalar),scalar)==Codec.encode(p,scalar),"V1 migration is identity")
 local oversized={};for i=1,2000 do oversized[i]=string.rep("x",200)end
 check(not pcall(Codec.encode,oversized,scalar),"Encoded hard limit")
 local deep:any={};local cursor=deep;for _=1,14 do cursor.child={};cursor=cursor.child end
 check(not pcall(Codec.encode,deep,scalar),"Depth bound")
 local cycle:any={};cycle.self=cycle;check(not pcall(Codec.encode,cycle,scalar),"Cycle refused")
 check(not pcall(Codec.encode,{[1]=true,[3]=true},scalar),"Sparse array refused")
 check(not pcall(require(Server.Adapters.DataStoreAdapter).create,nil :: any),"Real adapter refuses missing authenticated Player before service access")
 local clock=1000;local tasks:{thread}={}
 local function make(store:any,async:boolean?):any
  return Profiles.create({adapter=store,utcMs=function()return math.floor(clock*1000)end,mono=function()return clock end,
   id=id,scalar=scalar,jobId="Fake",placeId=1,random=function()return .5 end,
   spawn=function(work:()->())if async then table.insert(tasks,coroutine.create(work))else work()end end})
 end
 local function pump(service:any,n:number?)for _=1,n or 4 do service.tick()end end
 local store=Fake.create();local service=make(store)
 local e=service.reserve(owner);service.prepared(e,candidate);store.inject("CallbackReplay");pump(service)
 service.activate(e);check(e.status=="Live" and store.stats().writes==1,"Callback replay creates one profile")
 check(service.reserve(owner)==nil,"Same-user overlap blocked")
 local competitor=make(store);local rival=competitor.reserve(owner);competitor.prepared(rival,candidate);pump(competitor)
 check(not rival.acquired,"Actual fake-store competing session blocked")
 local current=service.profile(e);local live=Restore.restore(current,world,e.commandEpoch)
 live.online=false;live.revision+=1;service.stage(e,Restore.capture(world,live),live.revision)
 store.inject("AfterWrite");service.checkpoint(e);pump(service);clock+=1;pump(service)
 check(e.profile.country.simulation.online==false and e.profile.countryRevision==1,"Ambiguous write reconciled without duplicate")
 check(store.stats().writes==2,"One checkpoint after lost response")
 service.close(e);store.inject("AfterWrite");pump(service);clock+=1;pump(service)
 check(service.stats().profiles==0 and store.inspect("u:"..owner).lease==nil,"Ambiguous release resolves")
 local again=service.reserve(owner);service.prepared(again,candidate);pump(service);service.activate(again)
 check(again.profile.country.recipe.countryId==world.countryId and again.commandEpoch~=e.commandEpoch and not again.profile.country.simulation.online,"Same-user fake reconnect preserves state/fresh epoch")
 check(again.profile.country.simulation.deliveredMWh==0,"No offline progress")
 clock+=150;service.tick();check(not service.canMutate(again),"Safety deadline suspends")
 local expired=service.profile(again);clock+=31
 local nextService=make(store);local nextHandle=nextService.reserve(owner);nextService.prepared(nextHandle,candidate);pump(nextService)
 check(nextHandle.acquired and nextHandle.fence>again.fence,"Crash expiry reacquisition")
 check(Lease.apply(store.inspect("u:"..owner),op("Checkpoint",expired),math.floor(clock*1000),scalar)==nil,"Old shutdown cannot overwrite new owner")
 local unavailableStore=Fake.create();local failing=make(unavailableStore);local failed=failing.reserve(owner)
 failing.prepared(failed,candidate);unavailableStore.inject("Unavailable")
 for _=1,20 do pump(failing);clock+=1 end
 check(failed.terminal and unavailableStore.stats().calls<=5 and unavailableStore.stats().profiles==0,"Failures bounded; never default on read error")
 local noBudget=Fake.create();noBudget.setBudget(false);local budgetService=make(noBudget);local budgetHandle=budgetService.reserve(owner)
 budgetService.prepared(budgetHandle,candidate);clock+=31;pump(budgetService)
 check(budgetHandle.terminal and noBudget.stats().calls==0,"Budget starvation no requests")
 local heldStore=Fake.create();local held=make(heldStore,true);tasks={}
 local handles={}
 for user=1,8 do handles[user]=held.reserve(user);held.prepared(handles[user],candidate)end
 check(held.reserve(9)==nil,"Eight admitted/closing sessions cap")
 pump(held);check(#tasks==4 and held.stats().inFlight==4,"Four actual in-flight slots")
 clock+=31;pump(held);check(#tasks==4 and held.stats().inFlight==4,"Timeout cannot reuse hung slots")
 held.shutdown();clock+=21;pump(held)
 for _,thread in tasks do local ok,problem=coroutine.resume(thread);assert(ok,problem)end
 pump(held);check(held.stats().profiles==0 and held.stats().inFlight==0,"Late cancelled acquire cleans up, no resurrection")
 local pendingService=make(Fake.create());local pending=pendingService.reserve(owner)
 local scheduler=Queue.create(function()return clock end)
 local job=scheduler.add(function()clock+=.003;coroutine.yield();error("Cancelled generation resumed")end)
 scheduler.step();pendingService.close(pending);scheduler.cancel(job);pump(pendingService)
 pendingService.prepared(pending,candidate)
 check(pendingService.stats().profiles==0 and job.status=="cancelled","Disconnect during pending generation")
 local skewStore=Fake.create();local skew=make(skewStore);local skewHandle=skew.reserve(owner);skew.prepared(skewHandle,candidate);pump(skew);skew.activate(skewHandle)
 clock-=2;skew.tick();check(not skew.canMutate(skewHandle),"Clock reversal suspends")
 local badStore=Fake.create({["u:"..owner]={schemaVersion=999}});local badService=make(badStore);local badHandle=badService.reserve(owner)
 badService.prepared(badHandle,candidate);pump(badService)
 check(badHandle.terminal and badStore.stats().writes==0,"Invalid saved data never overwritten")
 local raceStore=Fake.create();local raced=false
 raceStore.update("u:"..owner,function(value:any)
  if not raced then raced=true;raceStore.update("u:"..owner,function(v:any)return Lease.apply(v,other,1000000,scalar)end)end
  return Lease.apply(value,initial,1000000,scalar)
 end)
 check(raceStore.inspect("u:"..owner).lease.ownerSessionId==other.sessionId and raceStore.stats().writes==1,"CAS replays callback after competing initialization")
 local delayedStore=Fake.create();local delayedService=make(delayedStore,true);tasks={}
 local delayed=delayedService.reserve(owner);delayedService.prepared(delayed,candidate);pump(delayedService)
 assert(coroutine.resume(tasks[1]));tasks={};pump(delayedService);delayedService.activate(delayed)
 local delayedState=Restore.restore(delayedService.profile(delayed),world,delayed.commandEpoch)
 delayedState.online=false;delayedState.revision=1;delayedService.stage(delayed,Restore.capture(world,delayedState),1)
 delayedService.checkpoint(delayed);pump(delayedService)
 delayedState.online=true;delayedState.revision=2;delayedService.stage(delayed,Restore.capture(world,delayedState),2)
 check(#tasks==1,"Mutation during save does not add a writer")
 assert(coroutine.resume(tasks[1]));tasks={};pump(delayedService)
 check(delayed.profile.countryRevision==1 and not delayed.profile.country.simulation.online and delayed.latest.revision==2,"Immutable save and coalesced latest snapshot")
 delayedService.checkpoint(delayed);pump(delayedService);assert(coroutine.resume(tasks[1]));tasks={};pump(delayedService)
 check(delayed.profile.countryRevision==2 and delayed.profile.country.simulation.online and delayed.latest==nil,"Newer snapshot saved after old completion")
 delayedStore.setHook(function(kind:string,_key:string)if kind=="Update" then coroutine.yield()end end)
 delayedState.online=false;delayedState.revision=3;delayedService.stage(delayed,Restore.capture(world,delayedState),3)
 delayedService.checkpoint(delayed);pump(delayedService);assert(coroutine.resume(tasks[1]))
 clock+=181;local winner=make(delayedStore);delayedStore.setHook(nil)
 local winnerHandle=winner.reserve(owner);winner.prepared(winnerHandle,candidate);pump(winner)
 assert(coroutine.resume(tasks[1]));tasks={};pump(delayedService)
 check(winnerHandle.acquired and delayed.terminal and delayedStore.inspect("u:"..owner).countryRevision==2,"Delayed old callback cannot overwrite new fence")
 local reconnectStore=Fake.create();local reconnect=make(reconnectStore);local mem=gcinfo()
 for _=1,32 do
  local h=reconnect.reserve(owner);reconnect.prepared(h,candidate);pump(reconnect);reconnect.activate(h)
  check(h.profile.country.recipe.countryId==world.countryId,"Repeated reconnect identity")
  reconnect.close(h);pump(reconnect);check(reconnect.stats().profiles==0,"Repeated close releases resources")
 end
 check(reconnectStore.stats().profiles==1 and reconnectStore.stats().calls==64,"Repeated reconnect storage/request bounds")
 local afterCommitStore=Fake.create();local afterCommit=make(afterCommitStore,true);tasks={}
 local leaving=afterCommit.reserve(owner);afterCommit.prepared(leaving,candidate);pump(afterCommit)
 assert(coroutine.resume(tasks[1]));tasks={};afterCommit.close(leaving);pump(afterCommit)
 check(not leaving.active and #tasks==1,"Late acquisition after disconnect schedules release only")
 assert(coroutine.resume(tasks[1]));tasks={};pump(afterCommit)
 check(afterCommit.stats().profiles==0 and afterCommitStore.inspect("u:"..owner).lease==nil,"Late acquire releases without activation")
 print(string.format("[P3a resources] 32 fake reconnects, %d calls, %d retained key; Lua memory delta %.1f KiB (GC-sensitive)",reconnectStore.stats().calls,reconnectStore.stats().profiles,gcinfo()-mem))
 table.sort(encodeTimes)
 print(string.format("[P3a fake] PASS %d assertions; max checkpoint %d bytes; canonical encode p95 %.3f ms; no real DataStore calls",checks,maxBytes,encodeTimes[#encodeTimes]))
end
