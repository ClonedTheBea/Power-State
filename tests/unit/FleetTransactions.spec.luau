--!strict
return function(fixtures:any,definitionVersion:number?,adapterFactory:any?)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local V=require(S.Domain.ProfileSchema4);local L=require(S.Domain.ProfileLease4)
 local Project=require(S.Domain.WindProject).catalog(definitionVersion or 1);local Service=require(S.Services.ProfileService)
 local Fake=require(S.Adapters.FakeDataStoreAdapter);local Country=require(S.Domain.FleetCountry)
 local Network=require(S.Domain.CountryFleetNetwork);local Solver=require(S.Operations.FleetSolver)
 local Controls=require(S.Services.FleetControls);local Quotes=require(S.Services.ConstructionQuotes)
 local checks=0;local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local id=function():string return H:GenerateGUID(false)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local owner=149564436;local key="u:"..owner
 local completed:any=nil
 for _,fault in {"None","BeforeWrite","AfterWrite","CallbackReplay"}do
  task.wait() -- Between independent fake scenarios, never inside a transaction.
  local store=(adapterFactory or Fake.create)({[key]=fixtures.funded});local now=2000000000
  local p=Service.create({adapter=store,schema=V,lease=L,windDefinitionVersion=definitionVersion or 1,id=id,scalar=scalar,jobId="FleetFake",placeId=1,
   utcMs=function()return math.floor(now*1000)end,mono=function()return now end,random=function()return 0 end,spawn=function(fn)fn()end})
  local function drain(test:()->boolean)
   for _=1,60 do p.tick();if test()then return end;now+=.01 end;error("Bounded fake coordinator did not complete")
  end
  local e=p.reserve(owner);p.prepared(e,fixtures.funded.country);drain(function()return e.acquired end);p.activate(e)
  local state=Country.restore(p.profile(e),fixtures.world,e.commandEpoch)
  local baseline=C.encode(state.fleet.baseline,scalar);local step=state.step
  local q=Quotes.create({owner=owner,epoch=e.commandEpoch,id=id,now=function()return now end,project=Project,
   receipt=function(c:any)return c.fleet.windReceipt end,topology=function(c:any)return c.construction.topologyRevision+c.fleet.investmentSerial end,
   eligible=function(c)return c.construction.receipt~=nil end,country=function()return Country.capture(fixtures.world,state)end,
   build=function(operation)p.stage(e,Country.capture(fixtures.world,state),state.revision);return p.buildWind(e,operation)end,
   profile=function()return p.profile(e)end,saveStatus=function()return p.status(e)end,canResume=function()return p.canMutate(e)end,
   install=function(profile)state=Country.restore(profile,fixtures.world,e.commandEpoch)end})
  local sequence=0
  local function send(command:string,quoteId:string?):any sequence+=1;return q.handle(owner,{version=1,epoch=e.commandEpoch,sequence=sequence,command=command,quoteId=quoteId})end
  local old=send("Quote");now+=30
  check(send("Confirm",old.quoteId).state=="QuoteExpired","Expired quote never buys")
  local fresh=send("Quote");check(fresh.quoteId~=old.quoteId,"Refresh issues new server quote")
  if fault~="None"then store.inject(fault)end
  local saving=send("Confirm",fresh.quoteId)
  check(saving.state=="Saving"and not p.canMutate(e),"Critical Build suspends mutation")
  local operation=e.op;local duplicate=send("Confirm",fresh.quoteId)
  check((duplicate.state=="Saving"or duplicate.state=="Rejected")and e.op==operation and not p.canMutate(e),"Double click retains exactly one critical operation, including rate-limit rejection")
  drain(function()q.tick();return q.status().state=="Built"end)
  local saved=p.profile(e)
  check(saved.country.bank.balanceMinor==fixtures.funded.country.bank.balanceMinor-Project.PRICE,"Exactly one capital debit: "..fault)
  check(saved.country.simulation.step==step and equal(saved.country.economy,fixtures.funded.country.economy),"No critical-transaction billing")
  check(#saved.country.deltas.builtNodes==2 and #saved.country.deltas.builtLines==2,"Exactly one new node and edge")
  check(C.encode(saved.country.fleet.baseline,scalar)==baseline,"Build preserves frozen baseline")
  now+=2;check(send("Quote").state=="AlreadyBuilt","Semantic receipt rejects later purchase")
  local before=Country.capture(fixtures.world,state)
  local network=Network.create(before,3000);local report=Solver.solve(network,state.step)
  state=Country.complete(state,fixtures.world,report,network)
  p.stage(e,Country.capture(fixtures.world,state),state.revision);p.checkpoint(e)
  drain(function()return not e.op and not e.result end)
  check(p.profile(e).lastCommit.kind=="Checkpoint"and p.profile(e).country.fleet.windReceipt~=nil,"Permanent receipt outlives lastCommit")
  local exact=p.profile(e).country
  p.close(e);drain(function()return p.stats().profiles==0 end)
  check(not store.inspect(key).lease,"Fenced release")
  now+=600;local re=p.reserve(owner);p.prepared(re,exact);drain(function()return re.acquired end);p.activate(re)
  check(equal(p.profile(re).country,exact),"Reconnect restores exact Bank/carries/history without offline progress")
  local duplicate,reason=p.buildWind(re,id());check(not duplicate and reason=="AlreadyBuilt","No second purchase after reconnect")
  check(p.stats().peakInFlight<=1 and p.stats().profiles==1,"Bounded coordinator resources")
  local op={id=id(),kind="Checkpoint",owner=owner,sessionId=id(),fence=re.fence,baseRevision=re.profile.profileRevision,
   snapshot=exact,countryRevision=re.profile.countryRevision}
  local value,why=L.apply(p.profile(re),op,math.floor(now*1000),scalar)
  check(value==nil and why=="OwnershipLost","Stale owner cannot save")
  local mutated=C.copy(exact);mutated.fleet.baseline.migrationOperationId=id()
  check(not pcall(V.transition,exact,mutated,scalar),"Every later transition preserves immutable baseline")
  local restored=Country.restore(p.profile(re),fixtures.world,re.commandEpoch)
  local command={version=1,kind="SetFleetGenerator",epoch=restored.epoch,sequence=1,revision=restored.controlRevision,
   assetId=exact.fleet.windReceipt.generatorId,online=false,capKW=2000}
  local changed,outcome=Controls.handle(restored,fixtures.world,owner,command,now,true)
  check(outcome=="Accepted"and not changed.fleet.windState.on,"Owned wind On/Off intent")
  check(equal(changed.bank,restored.bank)and changed.step==restored.step,"Control never settles money or time")
  local _,cross=Controls.handle(restored,fixtures.world,owner+1,command,now,true);check(cross=="Unauthorized","No cross-player control")
  command.capKW=1999;local _,bad=Controls.handle(restored,fixtures.world,owner,command,now,true);check(bad=="Rejected","Cap quantization")
  p.close(re);drain(function()return p.stats().profiles==0 end)
  completed=store.inspect(key)
 end
 for _,amount in {Project.PRICE+24999,Project.PRICE+25000,Project.PRICE+25001}do
  -- Direct project precondition test; not a funded profile or claimed save.
  local c=C.copy(fixtures.funded.country);c.bank.balanceMinor=amount
  local ok,result=pcall(Project.build,c,id(),99999,99999)
  check(ok==(amount>=Project.PRICE+25000),"Exact wind affordability boundary")
  if ok then check(result.bank.balanceMinor==amount-Project.PRICE,"Retained 250-Credit buffer")end
 end
 print("FLEET_TRANSACTIONS_PASS",checks,"catalogue",Project.VERSION)
 return completed
end
