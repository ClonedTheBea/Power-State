--!strict
return function()
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local Plan=require(S.Domain.BoundedEconomyPlan)
 local Policy=require(S.Domain.ExistingEconomyStore);local Fake=require(S.Adapters.FakeDataStoreAdapter)
 local Runner=require(S.Services.BoundedEconomyRunner);local Lease=require(S.Domain.ExistingEconomyLease)
 local function scalar(v:any):string return H:JSONEncode(v)end
 local function id():string return H:GenerateGUID(false)end
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local count=0;local function check(ok:boolean,msg:string)assert(ok,msg);count+=1 end
 local initial=require(script.Parent.P3b4Fixture)().profile
 local now=2000000;local mono=0
 local function execute(raw:any,phase:number,fault:string?):any
  local store=Policy.create(raw,scalar,function():number return now end)
  local plan=Plan.create(store.preflight,phase,scalar);local guarded=Plan.guard(store,plan,scalar)
  if fault then raw.inject(fault)end
  return Runner.run({adapter=guarded,scalar=scalar,utcMs=function():number return now end,mono=function():number return mono end,
   id=id,spawn=function(fn:()->())fn()end,wait=function()mono+=.05;now+=50 end,random=function():number return 0 end,
   jobId="P3b5Fake",placeId=1,present=function():boolean return true end,record=function()end},plan)
 end
 for _,fault in {"None","CallbackReplay","AfterWrite","BeforeWrite"}do
  local raw=Fake.create({[Policy.KEY]=initial})
  local a=execute(raw,1,if fault=="None" then nil else fault)
  check(a.completedIntervals==4 and not a.profile.lease,"Four intervals then release")
  check(a.checkpoints[1].country.bank.balanceMinor==100574 and a.profile.country.bank.balanceMinor==100574,"On/Off checkpoints exact")
  check(a.profile.country.simulation.step==117 and not a.profile.country.simulation.online,"Off state saved")
  now+=86400000;mono+=86400
  local b=execute(raw,2,nil)
  check(b.completedIntervals==1 and b.profile.country.simulation.step==118 and b.profile.country.simulation.online,"One reconnect interval only")
  check(b.profile.country.bank.balanceMinor==100766 and b.profile.country.economy.fixedExpenseRemainder==40000,"Exact final Bank/carry")
  check(b.profile.country.economy.lastSettledStep==118 and b.profile.country.economy.activationStep==113,"No duplicate/offline/grant billing")
  check(b.profile.country.economy.deliveredKwMinutes==12480 and b.profile.country.economy.onlineSteps==4,"Exact meters")
  check(b.profile.country.simulation.historyIndex==118 and #b.profile.country.simulation.history==118,"History preserved plus five intervals")
  check(b.profile.profileRevision==initial.profileRevision+7 and b.profile.sessionEpoch==initial.sessionEpoch+2,"Seven commits/two sessions despite retries")
  check(equal(b.profile.country.recipe,initial.country.recipe) and equal(b.profile.country.network,initial.country.network),"Identity and network preserved")
  if fault=="None" then check(raw.stats().calls==12 and raw.stats().writes==7,"Exactly seven updates/five reads")end
  check(not pcall(execute,raw,1,nil) and not pcall(execute,raw,2,nil),"No repeated phase after completion")
 end
 local plan=Plan.create(initial,1,scalar)
 local raw=Fake.create({[Policy.KEY]=initial});local guarded=Plan.guard(Policy.create(raw,scalar,function():number return now end),plan,scalar)
 local acquire={id=id(),kind="Acquire",owner=Policy.OWNER,sessionId=id(),jobId="Guard",placeId=1}
 local p=guarded.update(Policy.KEY,function(v:any):any return Lease.apply(v,acquire,now,scalar)end)
 local op={id=id(),kind="Checkpoint",owner=Policy.OWNER,sessionId=acquire.sessionId,fence=p.sessionEpoch,baseRevision=p.profileRevision,snapshot=plan.checkpoints[2].country,countryRevision=plan.checkpoints[2].revision}
 check(not pcall(guarded.update,Policy.KEY,function(v:any):any return Lease.apply(v,op,now,scalar)end),"Cannot skip planned checkpoint")
 check(raw.inspect(Policy.KEY).country.simulation.step==113,"Rejected write leaves country unchanged")
 local wrong=C.copy(initial);wrong.country.simulation.online=false
 check(not pcall(Plan.create,wrong,1,scalar),"Changed arithmetic preflight refused")
 check(not pcall(require(S.Adapters.Schema2GameplayAdapter).create,nil :: any),"Ordinary live adapter remains disabled")
 check(not pcall(require(S.Adapters.Schema2GameplayAdapter).createBounded,nil :: any,1,nil),"Bounded adapter rejects absent account before calls")
 print(string.format("[P3b5 fake] PASS %d assertions; 5 intervals / 7 commits / 5 reads; four fault scenarios; no real calls",count))
 return count
end
