--!strict
-- The input is the historical local capture, never fetched by this suite.
return function(review:any)
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local Plan=require(S.Domain.ConstructionProofPlan)
 local Runner=require(S.Services.ConstructionProofRunner);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local Country=require(S.Domain.ConstructionCountry);local Demand=require(S.World.DemandModel)
 local V=require(S.Domain.ProfileSchema3);local Project=require(S.Domain.ConstructionProject)
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function id():string return H:GenerateGUID(false)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local n=0;local function check(ok:boolean,m:string)assert(ok,m);n+=1 end
 local original=C.encode(review,scalar);local plan=Plan.create(review,"Fund",scalar)
 check(plan.intervalCount==124 and plan.finalStep==242,"Recalculated first affordable interval")
 check(plan.intervals[123].bankMinor<125000 and plan.finalCountry.bank.balanceMinor==125003,"Exact affordability crossing")
 check(plan.finalCountry.bank.openingGrantMinor==100000 and not plan.finalCountry.construction.receipt,"No grant or speculative purchase")
 local function execute(profile:any,phase:string,fault:string?,slow:boolean?):(boolean,any,any,any)
  local p=Plan.create(profile,phase,scalar);local store=Fake.create({[Plan.KEY]=profile});local time=2000000000;local delayed=false;local updates=0
  store.setHook(function(kind)
   if kind=="Update"then updates+=1;if updates==2 and fault then store.inject(fault)end end
  end)
  local adapter=Plan.guard(store,p,scalar)
  local ok,result=pcall(Runner.run,{adapter=adapter,scalar=scalar,id=id,utcMs=function()return math.floor(time*1000)end,
   mono=function()return time end,random=function()return 0 end,spawn=function(fn)fn()end,
   wait=function(seconds)time+=seconds;if slow and seconds==1 and not delayed then time+=60;delayed=true end end,
   present=function()return true end,placeId=1},p)
  return ok,result,store,adapter
 end
 local ok,funded,store=execute(review,"Fund")
 check(ok,"Bounded funding succeeds")
 check(funded.completedIntervals==124 and funded.checkpoints==5,"Exact funding/checkpoint bounds")
 check(funded.stats.writes==7 and funded.stats.reads==2,"Acquire/five checkpoints/release and two confirmations")
 check(funded.profile.country.bank.balanceMinor==125003 and funded.profile.country.economy.lastSettledStep==242,"Durable affordable finance")
 check(not funded.profile.lease and funded.profile.profileRevision==33 and funded.profile.countryRevision==256,"Released funding revisions")
 check(equal(funded.profile.country,plan.finalCountry),"Exact funded carries/history preserved")
 local slowOk,slow=execute(review,"Fund",nil,true)
 check(slowOk and equal(slow.profile.country,funded.profile.country),"Scheduling delay adds no catch-up income")
 check(slow.stats.writes==8,"Longer funding renews lease without changing country")
 for _,fault in {"CallbackReplay","AfterWrite","BeforeWrite"}do
  local success,result=execute(review,"Fund",fault)
  check(success and equal(result.profile.country,funded.profile.country),"Funding retry preserves exact results: "..fault)
 end
 local purchase:any=nil
 for _,fault in {"None","CallbackReplay","AfterWrite","BeforeWrite"}do
  local success,result,raw=execute(funded.profile,"Build",if fault=="None"then nil else fault)
  check(success and result.quoteState=="Built","Durable quote purchase: "..fault)
  check(result.completedIntervals==0 and result.profile.country.simulation.step==242,"No Build-stage simulation")
  check(result.profile.country.bank.balanceMinor==25003 and result.profile.country.bank.constructionSpentMinor==100000,"One debit and operating buffer")
  check(#result.profile.country.deltas.builtNodes==1 and #result.profile.country.deltas.builtLines==1,"One terminal/feeder")
  check(result.profile.country.bank.openingGrantMinor==100000 and equal(result.profile.country.economy,funded.profile.country.economy),"No grant or suspended billing")
  check(result.profile.country.construction.receipt~=nil and result.profile.lastCommit.kind=="Release","Receipt survives checkpoint/release")
  check(result.profile.profileRevision==37 and result.profile.sessionEpoch==10 and not result.profile.lease,"One reconnect ownership transition")
  check(equal(raw.inspect(Plan.KEY),result.profile),"Exact durable profile")
  if fault=="None"then purchase=result;check(result.stats.writes==4 and result.stats.reads==2,"Bounded Build-stage calls")end
 end
 local world=plan.world;local restored=Country.restore(purchase.profile,world,id())
 check(equal(Country.capture(world,restored),purchase.profile.country),"Reconnect does not bill or replay purchase")
 local demand=Demand.atStep(restored.step,world.meanTemperatureCentiC,1000).demandMW
 local advanced=Country.advance(restored,world,demand)
 check(advanced.report.demandMW>demand and #advanced.report.sinks==2,"Additional demand only in fake post-build step")
 check(advanced.bank.constructionSpentMinor==100000,"Later billing preserves capital receipt")
 for _,bank in {124999,125000,125001}do
  local c=C.copy(funded.profile.country);c.bank.balanceMinor=bank
  local accepted,after=pcall(Project.build,c,id(),257,35)
  check(accepted==(bank>=125000),"Exact affordability boundary")
  if accepted then check(after.bank.balanceMinor==bank-100000 and after.bank.balanceMinor>=25000,"No buffer bypass")end
 end
 local guard=Plan.guard(Fake.create({[Plan.KEY]=review}),plan,scalar)
 check(not pcall(guard.read,"u:1"),"Other keys forbidden")
 check(not pcall(guard.update,Plan.KEY,function(p:any)p.country.bank.balanceMinor+=1;return p end),"Invented Credits rejected")
 check(not pcall(Plan.create,purchase.profile,"Build",scalar),"Built country cannot start another purchase phase")
 check(not pcall(require(S.Adapters.Schema3ConstructionAdapter).create,"Fund",original),"Real gate rejects before service access")
 check(not require(S.Adapters.Schema3ConstructionAdapter).isApproved({mode="Real"}),"Forged capability rejected")
 V.validate(purchase.profile,Plan.OWNER,scalar)
 check(#C.encode(purchase.profile,scalar)<196608,"Full profile within soft limit")
 check(C.encode(review,scalar)==original,"Historical capture untouched")
 print("[P3c3 forecast] "..H:JSONEncode({intervals=plan.intervalCount,step=plan.finalStep,bank=plan.finalCountry.bank.balanceMinor,
  beforeThreshold=plan.intervals[123].bankMinor,afterPurchase=purchase.profile.country.bank.balanceMinor,
  sales=plan.finalCountry.economy.baseSalesMinor,variable=plan.finalCountry.economy.variableExpenseMinor,fixed=plan.finalCountry.economy.fixedExpenseMinor,
  salesCarry=plan.finalCountry.economy.baseSalesRemainder,variableCarry=plan.finalCountry.economy.variableExpenseRemainder,fixedCarry=plan.finalCountry.economy.fixedExpenseRemainder,
  fundingCalls=funded.stats,purchaseCalls=purchase.stats,bytes=#C.encode(purchase.profile,scalar)}))
 print(string.format("[P3c3 fake] PASS: %d assertions; no real access",n))
end
