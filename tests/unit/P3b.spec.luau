--!strict
return function()
 local S=game.ServerScriptService.Server
 local E=require(S.Domain.Economy)
 local C=require(S.Domain.ProfileCodec)
 local V1=require(S.Domain.ProfileSchema)
 local V2=require(S.Domain.ProfileSchema2)
 local L1=require(S.Domain.ProfileLease)
 local L2=require(S.Domain.ProfileLease2)
 local M=require(S.Domain.ProfileMigrations2)
 local EC=require(S.Domain.EconomicCountry)
 local PC=require(S.Domain.ProfileCountry)
 local Country=require(S.Simulation.Country)
 local Demand=require(S.World.DemandModel)
 local Generator=require(S.World.WorldGenerator)
 local Http=game:GetService("HttpService")
 local count=0
 local function check(ok:boolean,msg:string)assert(ok,msg);count+=1 end
 local function scalar(v:any):string return Http:JSONEncode(v)end
 local function id():string return Http:GenerateGUID(false)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local owner=149564436
 local w=Generator.create("df307a52185f423288df5749229f0808",id(),1)
 local original=Country.new(owner,id(),w.network)
 local candidate=PC.capture(w,original)
 local function op(kind:string,p:any?):any
  return {id=id(),kind=kind,owner=owner,sessionId=if p and p.lease then p.lease.ownerSessionId else id(),jobId="P3bFake",placeId=1,
   candidate=candidate,fence=if p then p.sessionEpoch else nil,baseRevision=if p then p.profileRevision else nil}
 end
 local acquire=op("Acquire",nil)
 local p=L2.apply(nil,acquire,1000000,scalar)
 check(p.schemaVersion==2 and p.country.bank.balanceMinor==100000,"Fresh opening grant")
 check(equal(p,(L2.apply(p,acquire,1000001,scalar))),"Repeated acquisition grant once")
 check(not pcall(V1.validate,p,owner,scalar),"V1 refuses V2")
 local state=EC.restore(p,w,id())
 for _=1,3 do state=EC.advance(state,3)end
 check(state.bank.balanceMinor==100550 and state.economy.fixedExpenseMinor==50,"Three-step 5.50 net")
 local before=C.copy(state)
 check(not pcall(E.settle,state.bank,state.economy,state.step-1,state.report,true),"Duplicate interval")
 check(not pcall(E.settle,state.bank,state.economy,state.step+1,state.report,true),"Gapped interval")
 check(equal(before,state),"Rejected billing atomic")
 state=EC.restore(p,w,id());local samples={}
 for _=1,1440 do
  local d=Demand.atStep(state.step,w.meanTemperatureCentiC,1000)
  local begin=os.clock();state=EC.advance(state,d.demandMW);table.insert(samples,(os.clock()-begin)*1000)
 end
 check(state.bank.balanceMinor==377832,"Full-day Bank")
 check(state.economy.baseSalesMinor==905495 and state.economy.variableExpenseMinor==603663 and state.economy.fixedExpenseMinor==24000,"Full-day categories")
 check(state.economy.baseSalesRemainder==48000 and state.economy.variableExpenseRemainder==52000 and state.economy.fixedExpenseRemainder==0,"Full-day carries")
 check(#state.economy.statements==24,"Completed statement retention")
 local snapshot=EC.capture(w,state);local save=op("Checkpoint",p);save.snapshot=snapshot;save.countryRevision=state.revision
 local saved=L2.apply(p,save,1002000,scalar)
 check(equal(saved,(L2.apply(saved,save,1002001,scalar))),"Checkpoint replay assigns once")
 local restored=EC.restore(saved,w,id())
 check(equal(restored.economy,state.economy) and equal(restored.bank,state.bank),"Money and carry restore")
 check(restored.deliveredMWh==state.deliveredMWh and equal(restored.history,state.history),"Energy restoration")
 restored=EC.advance(restored,3);state=EC.advance(state,3)
 check(equal(restored.economy,state.economy) and restored.deliveredMWh==state.deliveredMWh,"Deterministic reconnect")
 check(#state.economy.statements==25,"24 complete plus partial")
 for _=1,60 do state=EC.advance(state,3)end
 check(state.economy.statements[1].startStep==60,"Statement eviction never resets cursor")
 local bytes=V2.validate(saved,owner,scalar)
 check(bytes<196608 and #C.encode({bank=snapshot.bank,economy=snapshot.economy},scalar)<16384,"Full-history size bounds")
 local release=op("Release",saved);local released=L2.apply(saved,release,1003000,scalar)
 local newOwner=op("Acquire",nil);local reacquired=L2.apply(released,newOwner,1004000,scalar)
 check(reacquired.sessionEpoch==saved.sessionEpoch+1 and equal(reacquired.country,saved.country),"Lease release/reacquisition preserves finance")
 check(L2.apply(reacquired,op("Checkpoint",saved),1004001,scalar)==nil,"Stale owner fenced")
 for _,step in {0,113,1440,1441}do
  local old=Country.new(owner,id(),w.network)
  for _=1,step do Country.advance(old,3)end
  old.online=false
  local request=op("Acquire",nil);local legacy=L1.apply(nil,request,1000000,scalar)
  local prior=op("Checkpoint",legacy);prior.snapshot=PC.capture(w,old);prior.countryRevision=step+1
  legacy=L1.apply(legacy,prior,1000050,scalar)
  local unlocked=L1.apply(legacy,op("Release",legacy),1000100,scalar)
  local migration=op("Acquire",nil)
  local migrated=L2.apply(unlocked,migration,1000200,scalar)
  check(equal(migrated.country.simulation,unlocked.country.simulation),"Migration preserves all physical history")
  check(equal(V2.legacyCountry(migrated.country),unlocked.country),"Migration changes only Bank/economy")
  check(migrated.country.economy.activationStep==step and migrated.country.economy.baseSalesMinor==0,"No retroactive billing")
  check(migrated.lastCommit.kind=="MigrateAcquire" and migrated.countryRevision==unlocked.countryRevision+1,"Atomic migration receipt/revision")
  check(equal(migrated,(L2.apply(migrated,migration,1000300,scalar))),"Migration retry grant once")
  check(equal(migrated,M.read(migrated,owner,id(),scalar)),"Migration identity on V2 reload")
 end
 local off=EC.restore(p,w,id());off.online=false
 local nextOff=EC.advance(off,3)
 check(nextOff.bank.balanceMinor==100000 and nextOff.economy.onlineSteps==0 and nextOff.deliveredMWh==0,"Off no cost or sale")
 local disconnected=EC.restore(p,w,id());disconnected.network.lines={}
 disconnected=EC.advance(disconnected,3)
 check(disconnected.economy.baseSalesMinor==0 and disconnected.economy.variableExpenseMinor==0 and disconnected.economy.fixedExpenseMinor==16,"Disconnected On only fixed expense")
 local limited=EC.restore(p,w,id());limited.network.lines[1].capacity=1
 limited=EC.advance(limited,3)
 check(limited.report.deliveredMW==1 and limited.economy.baseSalesMinor==200 and limited.economy.variableExpenseMinor==133,"Capacity-limited actual billing")
 for _,vr in {0,59999}do for _,fr in {0,59999}do
  local e=C.copy(p.country.economy);e.variableExpenseRemainder=vr;e.fixedExpenseRemainder=fr
  local reserve=E.reservation(e,5000)
  check(reserve<=684,"Worst-case funded reserve bound")
  for _,delta in {-1,0,1}do
   local b=C.copy(p.country.bank);b.balanceMinor=reserve+delta
   check(pcall(E.settle,b,e,0,{deliveredMW=5,outputMW=5},true)==(delta>=0),"Reservation boundary")
  end
 end end
 local malformed:{(any)->()}={
  function(v)v.country.bank.balanceMinor=-1 end,
  function(v)v.country.bank.balanceMinor=E.CAP+1 end,
  function(v)v.country.economy.lastSettledStep+=1 end,
  function(v)v.country.economy.baseSalesRemainder=60000 end,
  function(v)v.country.economy.bonusSalesMinor=1 end,
  function(v)v.country.economy.generatedKwMinutes=0/0 end,
  function(v)v.country.economy.activationStep=-1 end,
  function(v)v.country.economy.statements[1].baseSalesMinor+=1 end,
  function(v)v.country.economy.injectedPrice=1 end,
 }
 for _,mutate in malformed do local bad=C.copy(saved);mutate(bad);check(not pcall(V2.validate,bad,owner,scalar),"Malformed financial profile")end
 local fake=require(S.Adapters.FakeDataStoreAdapter).create()
 fake.update("u:149564436",function()return p end)
 fake.inject("AfterWrite")
 local ok=pcall(fake.update,"u:149564436",function(cur:any)return L2.apply(cur,save,1002000,scalar)end)
 check(not ok,"Lost-response fake injection")
 local read=fake.read("u:149564436")
 check(equal(read,saved),"Ambiguous checkpoint reconciles exact snapshot")
 check(equal(L2.apply(read,save,1002001,scalar),saved),"Ambiguous checkpoint retry no credit")
 local exhausted=EC.restore(p,w,id());exhausted.network.lines={}
 for i=1,6000 do exhausted=EC.advance(exhausted,3);if i%200==0 then task.wait()end end
 check(not exhausted.online and exhausted.economy.fundingReason=="InsufficientOperatingFunds","Unfunded interval forces Off")
 check(exhausted.bank.balanceMinor>=0 and exhausted.bank.balanceMinor<684,"No overdraft or free fuel")
 local remaining=exhausted.bank.balanceMinor;local stopped=exhausted.step
 exhausted=EC.advance(exhausted,3)
 check(exhausted.bank.balanceMinor==remaining and not exhausted.online and exhausted.step==stopped+1,"No automatic retry/cost while Off")
 local command={version=1,kind="SetGenerator",epoch=exhausted.epoch,sequence=1,revision=exhausted.controlRevision,assetId=exhausted.network.generatorId,online=true}
 check(EC.handle(exhausted,owner,command,1)=="InsufficientOperatingFunds" and not exhausted.online,"Unfunded restart rejected")
 command.sequence=2;command.bankMinor=1000000
 check(EC.handle(exhausted,owner,command,2)=="Malformed" and exhausted.bank.balanceMinor==remaining,"Client money is not trusted")
 local frozen=C.copy(exhausted)
 check(not pcall(EC.advance,exhausted,0/0) and equal(frozen,exhausted),"Solver rejection leaves physical and financial state untouched")
 local clock=1000
 local Profiles=require(S.Services.ProfileService);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local function make(store:any):any
  return Profiles.create({adapter=store,schema=V2,lease=L2,prepareCountry=V1.country,utcMs=function()return clock*1000 end,mono=function()return clock end,
   id=id,scalar=scalar,jobId="P3bFake",placeId=1,random=function()return .5 end,spawn=function(work:()->())work()end})
 end
 local function pump(service:any)for _=1,4 do service.tick()end end
 local seedV1=L1.apply(nil,op("Acquire",nil),999000,scalar)
 seedV1=L1.apply(seedV1,op("Release",seedV1),999100,scalar)
 local store=Fake.create({["u:"..owner]=seedV1});local service=make(store)
 local h=service.reserve(owner);service.prepared(h,candidate);store.inject("AfterWrite");pump(service);clock+=1;pump(service)
 check(h.acquired and store.stats().writes==1 and h.profile.lastCommit.kind=="MigrateAcquire","Coordinator ambiguous migration grant once")
 service.activate(h)
 local living=EC.restore(service.profile(h),w,h.commandEpoch);living=EC.advance(living,3)
 service.stage(h,EC.capture(w,living),living.revision);store.inject("AfterWrite");service.checkpoint(h);pump(service);clock+=1;pump(service)
 check(equal(h.profile.country.bank,living.bank) and h.profile.country.simulation.step==1,"Coordinator reconciles complete financial checkpoint")
 check(service.status(h).savedBankMinor==living.bank.balanceMinor and service.status(h).savedStep==1,"Confirmed balance and step")
 service.close(h);store.inject("AfterWrite");pump(service);clock+=1;pump(service)
 check(service.stats().profiles==0 and store.inspect("u:"..owner).lease==nil,"Ambiguous final save/release")
 local again=service.reserve(owner);service.prepared(again,candidate);pump(service);service.activate(again)
 check(equal(again.profile.country.bank,living.bank) and again.commandEpoch~=h.commandEpoch,"Reconnect no repeated grant or income")
 local rival=make(store);local rivalHandle=rival.reserve(owner);rival.prepared(rivalHandle,candidate);pump(rival)
 check(not rivalHandle.acquired,"Competing migration/session refused")
 clock+=150;service.tick();check(not service.canMutate(again),"Lease safety suspends economy")
 local oldProfile=service.profile(again);clock+=31
 local winner=make(store);local win=winner.reserve(owner);winner.prepared(win,candidate);pump(winner)
 check(win.acquired and win.fence>again.fence,"Expired lease reacquisition preserves money")
 check(L2.apply(win.profile,op("Checkpoint",oldProfile),clock*1000,scalar)==nil,"Expired writer cannot pay/save")
 local invalid=Fake.create({["u:"..owner]={schemaVersion=999}});local invalidService=make(invalid)
 local badHandle=invalidService.reserve(owner);invalidService.prepared(badHandle,candidate);pump(invalidService)
 check(badHandle.terminal and invalid.stats().writes==0,"Unsupported stored data never overwritten")
 local cold=Fake.create();local failed=make(cold);local failHandle=failed.reserve(owner);failed.prepared(failHandle,candidate);cold.inject("Unavailable")
 for _=1,20 do pump(failed);clock+=1 end
 check(failHandle.terminal and cold.stats().calls<=5 and cold.stats().writes==0,"Bounded failures cannot create default balance")
 local timings={};local b,e=E.open(candidate,id())
 for i=1,8000 do local begin=os.clock();b,e=E.settle(b,e,i-1,{deliveredMW=3,outputMW=3},true);table.insert(timings,(os.clock()-begin)*1000);if i%200==0 then task.wait()end end
 table.sort(timings);local p95=timings[7600]
 print(string.format("[P3b economy-only] 8000 settlements p95 %.4f ms; serial workload, not concurrent players; fake only",p95))
 check(p95<=.25,"Economy-only p95 acceptance target")
 table.sort(samples)
 print(string.format("[P3b] PASS: %d assertions; full profile %d bytes; whole candidate-step p95 %.3f ms (includes physical history clone/validation, not economy-only)",count,bytes,samples[math.ceil(#samples*.95)]))
 return count
end
