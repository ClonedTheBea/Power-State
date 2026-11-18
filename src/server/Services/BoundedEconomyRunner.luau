--!strict
-- No Heartbeat advancement, remotes, automatic startup or recovery writes.
local Profiles=require(script.Parent.ProfileService)
local C=require(script.Parent.Parent.Domain.ProfileCodec)
local V=require(script.Parent.Parent.Domain.ProfileSchema2)
local Lease=require(script.Parent.Parent.Domain.ExistingEconomyLease)
local EC=require(script.Parent.Parent.Domain.EconomicCountry)
local Demand=require(script.Parent.Parent.World.DemandModel)
local P=require(script.Parent.Parent.Domain.ExistingEconomyStore)
local Runner={}
function Runner.run(deps:any,plan:any):any
 local scalar=deps.scalar
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local svc=Profiles.create({adapter=deps.adapter,schema=V,lease=Lease,prepareCountry=V.country,
  utcMs=deps.utcMs,mono=deps.mono,id=deps.id,scalar=scalar,spawn=deps.spawn,random=deps.random,jobId=deps.jobId,placeId=deps.placeId})
 local entry=svc.reserve(P.OWNER);assert(entry,"Profile admission failed")
 local function waitFor(predicate:()->boolean)
  local began=deps.mono()
  repeat
   svc.tick();assert(not entry.terminal,"Coordinator suspended: "..tostring(entry.reason))
   assert(deps.mono()-began<30,"Bounded coordinator deadline")
   if predicate()then return end
   deps.wait()
  until false
 end
 svc.prepared(entry,plan.initial.country)
 waitFor(function():boolean return entry.acquired and entry.op==nil and not entry.inFlight end)
 assert(equal(svc.profile(entry).country,plan.initial.country),"Acquisition changed country")
 local state=EC.restore(svc.profile(entry),plan.world,entry.commandEpoch)
 assert(equal(EC.capture(plan.world,state),plan.initial.country),"Reconnect/offline restore mismatch")
 svc.activate(entry)
 local completed=0;local sequence=0;local checkpoints={}
 local function advance()
  assert(completed<plan.maxIntervals and state.step<118,"Five-interval boundary")
  assert(deps.present() and svc.canMutate(entry) and entry.status=="Live" and entry.op==nil,"Cannot advance uncertain/unowned state")
  local d=Demand.atStep(state.step,plan.world.meanTemperatureCentiC,1000)
  local nextState=EC.advance(state,d.demandMW)
  svc.stage(entry,EC.capture(plan.world,nextState),nextState.revision);state=nextState;completed+=1
  local expected=plan.intervals[completed]
  assert(state.step==expected.step and state.bank.balanceMinor==expected.bankMinor and state.report.deliveredMW==expected.deliveredMW and state.report.outputMW==expected.outputMW,"Solver/replay mismatch")
 end
 local function toggle(online:boolean)
  assert(deps.present() and svc.canMutate(entry) and entry.status=="Live","Cannot control uncertain/unowned state")
  sequence+=1;local nextState=C.copy(state)
  assert(EC.handle(nextState,P.OWNER,{version=1,kind="SetGenerator",epoch=state.epoch,sequence=sequence,revision=state.controlRevision,assetId=state.network.generatorId,online=online},deps.mono())=="Accepted","Validated generator command refused")
  svc.stage(entry,EC.capture(plan.world,nextState),nextState.revision);state=nextState
 end
 local function checkpoint(index:number,readBack:boolean)
  local expected=plan.checkpoints[index]
  assert(equal(EC.capture(plan.world,state),expected.country) and state.revision==expected.revision,"Planned checkpoint mismatch")
  svc.checkpoint(entry);waitFor(function():boolean return entry.op==nil and not entry.inFlight end)
  local confirmed=svc.profile(entry);assert(equal(confirmed.country,expected.country),"Financial checkpoint mismatch")
  assert(svc.status(entry).savedBankMinor==state.bank.balanceMinor and svc.status(entry).savedStep==state.step,"Confirmed UI financial state mismatch")
  if readBack then assert(equal(deps.adapter.read(P.KEY),confirmed),"Uncached checkpoint mismatch")end
  table.insert(checkpoints,C.copy(confirmed));deps.record("Checkpoint",confirmed)
 end
 if plan.phase==1 then
  for _=1,3 do advance()end;checkpoint(1,true)
  toggle(false);advance();checkpoint(2,false)
 else toggle(true);advance();checkpoint(1,false)end
 assert(completed==plan.maxIntervals,"Wrong completed interval count")
 svc.close(entry);waitFor(function():boolean return svc.stats().profiles==0 end)
 local released=svc.profile(entry)
 assert(released and not released.lease and released.lastCommit.kind=="Release","Release not confirmed")
 local final=deps.adapter.read(P.KEY)
 assert(equal(final,released) and equal(final.country,plan.checkpoints[#plan.checkpoints].country),"Final uncached release mismatch")
 deps.record("Released",final)
 return {profile=final,completedIntervals=completed,checkpoints=checkpoints,stats=deps.adapter.stats()}
end
return table.freeze(Runner)
