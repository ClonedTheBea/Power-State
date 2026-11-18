--!strict
return function()
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local V2=require(S.Domain.ProfileSchema2)
 local Lease=require(S.Domain.ExistingEconomyLease);local Policy=require(S.Domain.ExistingEconomyStore)
 local Fake=require(S.Adapters.FakeDataStoreAdapter);local Profiles=require(S.Services.ProfileService)
 local EC=require(S.Domain.EconomicCountry);local Demand=require(S.World.DemandModel)
 local count=0
 local function check(ok:boolean,msg:string)assert(ok,msg);count+=1 end
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function id():string return H:GenerateGUID(false)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local fixture=require(script.Parent.P3b4Fixture)();local initial=fixture.profile;local world=fixture.world
 local now=2000000;local mono=0
 local function wrap(raw:any):any return Policy.create(raw,scalar,function():number return now end)end
 local function fake(p:any):any return Fake.create({[Policy.KEY]=p})end
 check(not pcall(require(S.Adapters.Schema2GameplayAdapter).create,nil :: any),"Disabled gate before service access")
 check(not require(S.Adapters.Schema2GameplayAdapter).isApproved({mode="Real"}),"Forged real capability denied")
 check(not pcall(wrap,Fake.create()),"Missing profile cannot initialize")
 local bad=C.copy(initial);bad.schemaVersion=1;check(not pcall(wrap,fake(bad)),"No migration path")
 bad=C.copy(initial);bad.country.bank.balanceMinor+=1;check(not pcall(wrap,fake(bad)),"Corrupt balance refused")
 bad=C.copy(initial);bad.country.recipe.countryId=id();check(not pcall(wrap,fake(bad)),"Foreign country refused")
 local raw=fake(initial);local store=wrap(raw)
 check(not pcall(store.read,"u:1") and raw.stats().calls==1,"Other keys blocked before transport")
 local function service(adapter:any):any
  return Profiles.create({adapter=adapter,schema=V2,lease=Lease,prepareCountry=V2.country,
   utcMs=function():number return now end,mono=function():number return mono end,id=id,scalar=scalar,
   spawn=function(fn:()->())fn()end,random=function():number return 0 end,jobId="P3b4Fake",placeId=1})
 end
 check(not pcall(service,{mode="Real"}),"Profile coordinator rejects unsealed real adapter")
 local function pump(s:any)for _=1,8 do s.tick()end end
 local function join(s:any,p:any):any
  local e=s.reserve(Policy.OWNER);s.prepared(e,p.country);pump(s);check(e.acquired and not e.terminal,"Existing country acquired");s.activate(e);return e
 end
 local svc=service(store);raw.inject("AfterWrite")
 local entry=join(svc,initial)
 check(raw.stats().writes==1 and equal(svc.profile(entry).country,initial.country),"Lost acquire reconciles without grant or rewrite")
 check(not pcall(wrap,raw),"Active lease preflight refused")
 local state=EC.restore(svc.profile(entry),world,id());local rows={}
 for _=1,3 do
  local d=Demand.atStep(state.step,world.meanTemperatureCentiC,1000)
  state=EC.advance(state,d.demandMW)
  table.insert(rows,{step=state.step,kw=math.floor(d.demandMW*1000+.5),bank=state.bank.balanceMinor,sales=state.economy.baseSalesMinor,variable=state.economy.variableExpenseMinor,fixed=state.economy.fixedExpenseMinor,salesCarry=state.economy.baseSalesRemainder,variableCarry=state.economy.variableExpenseRemainder,fixedCarry=state.economy.fixedExpenseRemainder})
 end
 check(state.bank.balanceMinor>initial.country.bank.balanceMinor,"Delivered electricity grows Bank")
 svc.stage(entry,EC.capture(world,state),state.revision)
 check(svc.status(entry).savedBankMinor==100000 and state.bank.balanceMinor>100000,"Live versus confirmed balance")
 raw.inject("CallbackReplay");svc.checkpoint(entry);pump(svc)
 local saved=svc.profile(entry)
 check(equal(saved.country.bank,state.bank) and equal(saved.country.economy,state.economy),"Checkpoint exact carries and finance")
 check(svc.status(entry).savedBankMinor==state.bank.balanceMinor,"Confirmed Bank advances only after save")
 local before=C.copy(state);check(not pcall(EC.advance,state,0/0) and equal(before,state),"Failed solve financially atomic")
 local function toggle(online:boolean,sequence:number)
  local result=EC.handle(state,Policy.OWNER,{version=1,kind="SetGenerator",epoch=state.epoch,sequence=sequence,revision=state.controlRevision,assetId=state.network.generatorId,online=online},mono+sequence)
  check(result=="Accepted","Generator command accepted")
 end
 toggle(false,1);state=EC.advance(state,Demand.atStep(state.step,world.meanTemperatureCentiC,1000).demandMW)
 check(equal(state.bank,before.bank) and state.economy.onlineSteps==3,"Off step no billing")
 svc.stage(entry,EC.capture(world,state),state.revision);raw.inject("AfterWrite");svc.checkpoint(entry);pump(svc)
 check(equal(svc.profile(entry).country.economy,state.economy),"Lost checkpoint response reconciles exact result")
 svc.close(entry);pump(svc);check(raw.inspect(Policy.KEY).lease==nil,"Controlled release")
 now+=86400000;mono+=86400
 local reconnect=service(wrap(raw));local nextEntry=join(reconnect,raw.inspect(Policy.KEY))
 local restored=EC.restore(reconnect.profile(nextEntry),world,id())
 check(not restored.online and equal(restored.bank,state.bank) and equal(restored.economy,state.economy),"Off state and exact money restored without offline progress")
 check(equal(restored.history,state.history) and restored.requestedMWh==state.requestedMWh and restored.deliveredMWh==state.deliveredMWh,"Energy and reliability restored")
 check(restored.economy.activationStep==113 and restored.bank.openingGrantId==initial.country.bank.openingGrantId,"Opening grant remains once")
 state=restored;toggle(true,1);state=EC.advance(state,Demand.atStep(state.step,world.meanTemperatureCentiC,1000).demandMW)
 reconnect.stage(nextEntry,EC.capture(world,state),state.revision);reconnect.checkpoint(nextEntry);pump(reconnect)
 check(reconnect.profile(nextEntry).country.economy.onlineSteps==4,"On resume bills only next interval")
 local stale=reconnect.profile(nextEntry)
 now+=180001;mono+=180.001;reconnect.tick()
 check(not reconnect.canMutate(nextEntry),"Expired lease suspends gameplay")
 local newer=service(wrap(raw));local newerEntry=join(newer,raw.inspect(Policy.KEY))
 local rejected=Lease.apply(raw.inspect(Policy.KEY),{id=id(),kind="Renew",owner=Policy.OWNER,sessionId=stale.lease.ownerSessionId,fence=stale.sessionEpoch,baseRevision=stale.profileRevision},now,scalar)
 check(rejected==nil,"Expired stale owner cannot renew")
 newer.close(newerEntry);pump(newer)
 check(newer.stats().profiles==0 and newer.stats().peakInFlight<=4 and raw.stats().profiles==1,"Bounded coordinator and cleanup")
 local bytes=V2.validate(raw.inspect(Policy.KEY),Policy.OWNER,scalar);check(bytes<196608,"Profile below soft size bound")
 -- First-write race: a fresh fenced owner appears after our preflight.
 local raceRaw=fake(initial);local race=wrap(raceRaw)
 raceRaw.update(Policy.KEY,function(p:any):any return Lease.apply(p,{id=id(),kind="Acquire",owner=Policy.OWNER,sessionId=id(),jobId="Other",placeId=1},now,scalar)end)
 local calls=0;check(not pcall(race.update,Policy.KEY,function(p:any):any calls+=1;return p end) and calls==0,"Changed preflight blocked before transition")
 check(not pcall(Lease.apply,nil,{kind="Acquire",owner=Policy.OWNER},now,scalar),"Lease never initializes missing profile")
 print("[P3b4 arithmetic] "..H:JSONEncode(rows))
 print(string.format("[P3b4] PASS %d assertions; fake only; %d bytes; %d calls / %d writes",count,bytes,raw.stats().calls,raw.stats().writes))
 return count
end
