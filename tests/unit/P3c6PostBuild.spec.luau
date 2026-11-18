--!strict
return function(origin:any)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local Plan=require(S.Domain.PostBuildProofPlan)
 local Runner=require(S.Services.PostBuildProofRunner);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local Lease=require(S.Domain.ProfileLease3)
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function id():string return H:GenerateGUID(false)end
 local n=0;local function check(v:boolean,m:string)assert(v,m);n+=1 end
 check(not pcall(require(S.Adapters.PostBuildProofAdapter).create,"A","","",{}),"Closed before service")
 local function run(fault:string?)
  local store=Fake.create({[Plan.KEY]=origin});local clock=2000000000;local reviewed=origin;local totals=0
  for _,phase in {"A","B"}do
   local head=store.read(Plan.KEY);local plan=Plan.create(origin,head,phase,scalar)
   check(C.encode(head,scalar)==C.encode(reviewed,scalar),"Fresh exact head")
   local guarded=Plan.guard(store,plan,scalar);local injected=false
   store.setHook(function(kind:string,_key:string)
    if kind=="Update" and store.inspect(Plan.KEY).lastCommit.kind=="Acquire" and fault and not injected then injected=true;store.inject(fault)end
   end)
   local result=Runner.run({adapter=guarded,scalar=scalar,id=id,utcMs=function()return math.floor(clock*1000)end,
    mono=function()return clock end,wait=function(dt)clock+=dt end,spawn=function(fn)fn()end,random=function()return 0 end,
    placeId=1,present=function()return true end},plan)
   check(result.profile.country.simulation.step==(if phase=="A" then 245 else 247),"Bounded progression")
   check(result.profile.country.bank.balanceMinor==(if phase=="A" then 25797 else 26328),"Exact Bank")
   check(result.profile.profileRevision==(if phase=="A" then 40 else 43) and not result.profile.lease,"Exact release")
   check(C.encode(result.profile.country.construction,scalar)==C.encode(origin.country.construction,scalar),"Protected receipt")
   check(result.stats.calls<=12 and result.stats.reads<=6 and result.stats.writes<=6,"Session ceilings")
   totals+=result.stats.calls;reviewed=result.profile;clock+=86400
  end
  check(totals<=24,"Combined ceiling")
 end
 for _,fault in {"None","BeforeWrite","AfterWrite","CallbackReplay"}do run(if fault=="None" then nil else fault)end
 local plan=Plan.create(origin,origin,"A",scalar);local store=Fake.create({[Plan.KEY]=origin});local guard=Plan.guard(store,plan,scalar)
 local op={id=id(),owner=Plan.OWNER,sessionId=id(),jobId="Fake",placeId=1,kind="Acquire",baseRevision=37,candidate=origin.country}
 local owned=guard.update(Plan.KEY,function(p:any)return Lease.apply(p,op,2000000000000,scalar)end)
 check(owned~=nil,"Guarded acquisition")
 check(not pcall(guard.update,Plan.KEY,function(p:any)p.country.construction.receipt.operationId=id();return p end),"Receipt mutation denied")
 check(not pcall(guard.update,Plan.KEY,function(p:any)p.country.network.lines[1].capacity=9;return p end),"Infrastructure mutation denied")
 check(not pcall(guard.update,Plan.KEY,function(p:any)p.country.bank.balanceMinor+=1;return p end),"Arbitrary Bank denied")
 local stale={id=id(),owner=Plan.OWNER,sessionId=id(),jobId="Fake",placeId=1,kind="Checkpoint",fence=owned.sessionEpoch,baseRevision=owned.profileRevision,snapshot=owned.country,countryRevision=owned.countryRevision}
 check(guard.update(Plan.KEY,function(p:any)return Lease.apply(p,stale,2000000000001,scalar)end)==nil,"Stale owner refused")
 local capped=Plan.guard(store,plan,scalar)
 for _=1,5 do capped.read(Plan.KEY)end
 check(not pcall(capped.read,Plan.KEY),"Read ceiling includes preflight")
 check(not pcall(capped.read,"u:1"),"Other key denied")
 check(not pcall(Plan.create,origin,origin,"C",scalar),"Third phase denied")
 print(string.format("[P3c6 PostBuild] PASS: %d guarded adapter/coordinator assertions; fake only",n))
end
