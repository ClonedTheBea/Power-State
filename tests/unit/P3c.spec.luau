--!strict
return function()
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local Codec=require(S.Domain.ProfileCodec);local Schema=require(S.Domain.ProfileSchema3)
 local Migration=require(S.Domain.ProfileMigrations3);local Lease=require(S.Domain.ProfileLease3)
 local Country=require(S.Domain.ConstructionCountry);local Project=require(S.Domain.ConstructionProject)
 local Solver=require(S.Simulation.DistrictSolver);local Demand=require(S.World.DemandModel)
 local Service=require(S.Services.ProfileService);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local Quotes=require(S.Services.ConstructionQuotes)
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function id():string return H:GenerateGUID(false)end
 local count=0
 local function check(v:boolean,why:string)count+=1;assert(v,why)end
 local function rejects(fn:()->())check(not pcall(fn),"Expected invalid candidate rejection")end
 local fixture=require(script.Parent["P3b4Fixture"])();local world=fixture.world
 local old=Codec.encode(fixture.profile,scalar);local profile=Migration.read(fixture.profile,149564436,scalar)
 check(Codec.encode(fixture.profile,scalar)==old,"Pure migration input preserved")
 check(Codec.encode(Schema.previous(profile),scalar)==old,"Exact v2 projection")
 check(Codec.encode(Migration.read(profile,149564436,scalar),scalar)==Codec.encode(profile,scalar),"Idempotent v3 reload")
 local state=Country.restore(profile,world,id())
 for _=1,150 do state=Country.advance(state,world,Demand.atStep(state.step,1700,1000).demandMW)end
 profile.country=Country.capture(world,state);profile.countryRevision=state.revision;profile.lastCommit.countryRevision=state.revision
 Schema.validate(profile,149564436,scalar)
 local funded=Codec.copy(profile)
 local totalTime=0;local peak=0
 for _,fault in {"None","BeforeWrite","AfterWrite","CallbackReplay"}do
  local clock=1000;local store=Fake.create({["u:149564436"]=funded})
  local svc=Service.create({adapter=store,schema=Schema,lease=Lease,scalar=scalar,id=id,jobId="P3cFake",placeId=1,
   utcMs=function()return math.floor(clock*1000)end,mono=function()return clock end,random=function()return 0 end,spawn=function(fn)fn()end})
  local e=svc.reserve(149564436);svc.prepared(e,funded.country);svc.tick();svc.tick();svc.activate(e)
  local s=Country.restore(svc.profile(e),world,e.commandEpoch)
  local quotes=Quotes.create({owner=149564436,epoch=e.commandEpoch,id=id,now=function()return clock end,
   country=function()return Country.capture(world,s)end,
   build=function(op)svc.stage(e,Country.capture(world,s),s.revision);return svc.build(e,op)end,
   saveStatus=function()return svc.status(e)end,profile=function()return svc.profile(e)end,
   canResume=function()return svc.canMutate(e)end,install=function(p)s=Country.restore(p,world,e.commandEpoch)end})
  local q=quotes.handle(149564436,{version=1,epoch=e.commandEpoch,sequence=1,command="Quote"})
  check(q.state=="Available","Funded quote")
  if fault~="None"then store.inject(fault)end
  local beforeBank=s.bank.balanceMinor;local beforeStep=s.step
  local response=quotes.handle(149564436,{version=1,epoch=e.commandEpoch,sequence=2,command="Confirm",quoteId=q.quoteId})
  check(response.state=="Saving" and not svc.canMutate(e),"No success before durable commit; barrier holds")
  check(s.bank.balanceMinor==beforeBank and not s.construction.receipt,"No speculative debit/asset")
  check(quotes.handle(149564436,{version=1,epoch=e.commandEpoch,sequence=2,command="Confirm",quoteId=q.quoteId}).state=="Rejected","Duplicate sequence rejected")
  for _=1,8 do clock+=.1;svc.tick();quotes.tick()end
  check(quotes.status().state=="Built","Commit/reconciliation confirmed")
  check(s.bank.balanceMinor==beforeBank-100000 and s.step==beforeStep,"One capital debit, no suspended billing")
  check(svc.canMutate(e),"Resumed after confirmed build")
  local built=svc.profile(e);Schema.validate(built,149564436,scalar)
  check(#built.country.deltas.builtNodes==1 and #built.country.deltas.builtLines==1,"Atomic assets")
  check(built.country.bank.openingGrantMinor==100000,"No extra grant")
  local on=Solver.solve(built.country,3.811,true);local off=Solver.solve(built.country,3.811,false)
  local disconnected=Solver.solve(built.country,3.811,true,false)
  check(math.abs(on.deliveredMW-4.764)<1e-9 and on.sinks[2].deliveredMW==.953,"Peak delivery")
  check(off.deliveredMW==0 and off.sinks[2].unmetMW==.953,"Off preserves requested district demand")
  check(disconnected.sinks[1].deliveredMW==3.811 and disconnected.sinks[2].deliveredMW==0,"Disconnected branch independent")
  for _=1,10 do s=Country.advance(s,world,Demand.atStep(s.step,1700,1000).demandMW)end
  svc.stage(e,Country.capture(world,s),s.revision);svc.checkpoint(e);svc.tick();svc.tick()
  check(svc.profile(e).lastCommit.kind=="Checkpoint" and svc.profile(e).country.construction.receipt~=nil,"Permanent receipt survives lastCommit replacement")
  check(quotes.handle(149564436,{version=1,epoch=e.commandEpoch,sequence=3,command="Quote"}).state=="AlreadyBuilt","New operation cannot repurchase")
  check(not svc.build(e,id()),"Dedicated repeat rejected")
  svc.close(e);svc.tick();svc.tick();svc.tick()
  local saved=store.inspect("u:149564436");check(saved.lease==nil,"Controlled release")
  local restored=Country.restore(saved,world,id())
  check(Codec.encode(Country.capture(world,restored),scalar)==Codec.encode(saved.country,scalar),"Exact reconnect, no offline step or capital replay")
  peak=math.max(peak,svc.stats().peakInFlight);totalTime+=quotes.status().suspensionSeconds
  local broken=Codec.copy(saved);broken.country.deltas.builtLines={};rejects(function()Schema.validate(broken,149564436,scalar)end)
  broken=Codec.copy(saved);broken.country.bank.constructionSpentMinor=0;rejects(function()Schema.validate(broken,149564436,scalar)end)
  broken=Codec.copy(saved);broken.country.network.nodes[1].capacity=4;rejects(function()Solver.solve(broken.country,3.811,true)end)
 end
 for _,balance in {124999,125000,125001}do
  -- Affordability predicate isolated from the earned-money fixture, never a saved grant.
  local c=Codec.copy(funded.country);c.bank.balanceMinor=balance
  local ok,result=pcall(Project.build,c,id(),999,999)
  check(ok==(balance>=125000),"Exact affordability boundary")
  if ok then check(result.bank.balanceMinor>=25000,"Buffer retained")end
 end
 local p=Codec.copy(funded);local session=id()
 local op={id=id(),kind="Acquire",owner=149564436,sessionId=session,jobId="fake",placeId=1}
 p=Lease.apply(p,op,1000000,scalar)
 local before=Codec.copy(p.country)
 local build={id=id(),kind="Build",owner=149564436,sessionId=session,fence=p.sessionEpoch,baseRevision=p.profileRevision,
  before=before,beforeRevision=p.countryRevision,countryRevision=p.countryRevision+1}
 build.snapshot=Project.build(before,build.id,build.countryRevision,p.profileRevision+1)
 local committed=Lease.apply(p,build,1000001,scalar)
 check(Codec.encode(Lease.apply(committed,build,1000002,scalar),scalar)==Codec.encode(committed,scalar),"Callback replay exact")
 for _,key in {"fence","baseRevision"}do local bad=Codec.copy(build);bad[key]+=1;check(Lease.apply(p,bad,1000001,scalar)==nil,"Stale fence/revision")end
 check(Lease.apply(p,build,1180001,scalar)==nil,"Expired lease")
 local tamper=Codec.copy(build);tamper.snapshot.bank.balanceMinor+=1;rejects(function()Lease.apply(p,tamper,1000001,scalar)end)
 local kwh=0;local maximum=0;local times={}
 for step=0,1439 do
  local mw=Demand.atStep(step,1700,1000).demandMW;local start=os.clock()
  local report=Solver.solve(committed.country,mw,true)
  table.insert(times,(os.clock()-start)*1000)
  kwh+=math.floor(report.deliveredMW*1000+.5);maximum=math.max(maximum,report.deliveredMW)
 end
 check(kwh==5659536 and math.abs(maximum-4.764)<1e-9,"Full-day exact two-sink fixture")
 table.sort(times)
 print(string.format("[P3c fake profile] %d bytes; solver p50 %.4f / p95 %.4f ms; peak calls %d; synthetic suspension total %.2fs",#Codec.encode(committed,scalar),times[720],times[1368],peak,totalTime))
 print(string.format("[Power State P3c] PASS: %d assertions",count))
end
