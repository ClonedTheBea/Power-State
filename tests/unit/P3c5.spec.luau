--!strict
-- Supplied protected local capture only; this suite never reads a real service.
return function(review:any)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local Plan=require(S.Domain.ConstructionProofPlan)
 local Runner=require(S.Services.ConstructionProofRunner);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local Project=require(S.Domain.ConstructionProject);local Adapter=require(S.Adapters.Schema3ConstructionAdapter)
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local n=0;local function check(ok:boolean,message:string)assert(ok,message);n+=1 end
 local original=C.encode(review,scalar)
 check(review.profileRevision==33 and review.countryRevision==256 and review.sessionEpoch==9,"Reviewed funded revisions")
 check(review.country.bank.balanceMinor==125003 and review.country.simulation.step==242 and not review.lease,"Released funded state")
 check(not pcall(Adapter.create,"Build",original),"Closed Build capability rejects before real access")
 check(not pcall(Adapter.create,"Fund",original),"Stage A remains closed")
 for _,fault in {"None","CallbackReplay","AfterWrite","BeforeWrite"}do
  local plan=Plan.create(review,"Build",scalar);local store=Fake.create({[Plan.KEY]=review})
  local time=2000000000;local updates=0
  store.setHook(function(kind)if kind=="Update"then updates+=1;if updates==2 and fault~="None"then store.inject(fault)end end end)
  local adapter=Plan.guard(store,plan,scalar)
  local result=Runner.run({adapter=adapter,scalar=scalar,id=function()return H:GenerateGUID(false)end,
   utcMs=function()return math.floor(time*1000)end,mono=function()return time end,random=function()return 0 end,
   spawn=function(fn)fn()end,wait=function(seconds)time+=seconds end,present=function()return true end,placeId=1},plan)
  local p=result.profile;local r=p.country.construction.receipt
  check(result.completedIntervals==0 and result.checkpoints==1 and result.quoteState=="Built","Bounded Build only: "..fault)
  check(equal(p.country,Project.build(review.country,r.operationId,257,35)),"Exact atomic deterministic candidate: "..fault)
  check(p.country.bank.balanceMinor==25003 and p.country.bank.constructionSpentMinor==100000,"Exactly one debit: "..fault)
  check(equal(p.country.simulation,review.country.simulation) and equal(p.country.economy,review.country.economy),"Zero billing/history advancement: "..fault)
  check(#p.country.deltas.builtNodes==1 and #p.country.deltas.builtLines==1,"One terminal/feeder: "..fault)
  check(p.profileRevision==37 and p.countryRevision==257 and p.sessionEpoch==10 and not p.lease,"Released revisions: "..fault)
  check(p.lastCommit.kind=="Release" and r.projectId=="district-feeder-v1","Permanent receipt survives lastCommit: "..fault)
  check(equal(store.inspect(Plan.KEY),p) and result.coordinator.profiles==0,"Exact durable cleanup: "..fault)
  check(not pcall(Plan.create,p,"Build",scalar),"No second purchase: "..fault)
  if fault=="None"then check(result.stats.writes==4 and result.stats.reads==2,"Normal four updates/two confirmations; separate preflight")end
 end
 check(C.encode(review,scalar)==original,"Funded capture untouched")
 print(string.format("[P3c5 fake] PASS: %d assertions; exact funded capture, no real access",n))
end
