--!strict
-- Explicit bounded steps; never binds Heartbeat or mounts preview/gameplay services.
local C=require(script.Parent.Parent.Domain.ProfileCodec)
local V=require(script.Parent.Parent.Domain.ProfileSchema3)
local Lease=require(script.Parent.Parent.Domain.ProfileLease3)
local Country=require(script.Parent.Parent.Domain.ConstructionCountry)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Plan=require(script.Parent.Parent.Domain.ConstructionProofPlan)
local Profiles=require(script.Parent.ProfileService)
local Quotes=require(script.Parent.ConstructionQuotes)
local Runner={}
function Runner.run(deps:any,plan:any):any
 local scalar=deps.scalar;local began=deps.mono();local limit=if plan.phase=="Fund" then 240 else 90
 local svc=Profiles.create({adapter=deps.adapter,schema=V,lease=Lease,prepareCountry=V.country,scalar=scalar,
  utcMs=deps.utcMs,mono=deps.mono,id=deps.id,spawn=deps.spawn,random=deps.random,jobId="ConstructionProofOnly",placeId=deps.placeId})
 local e=svc.reserve(Plan.OWNER);assert(e,"Admission refused")
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local function tick()
  assert(deps.present() and deps.mono()-began<limit,"Proof presence/deadline; stop")
  svc.tick();assert(not e.terminal,"Persistence suspended: "..tostring(e.reason))
 end
 local function idle()
  local start=deps.mono()
  repeat tick();if not e.op and not e.inFlight and not e.result then return end
   assert(deps.mono()-start<30,"Operation wait deadline");deps.wait(.05)
  until false
 end
 svc.prepared(e,plan.initial.country);idle();svc.activate(e)
 assert(equal(svc.profile(e).country,plan.initial.country),"Acquisition changed country")
 local state=Country.restore(svc.profile(e),plan.world,e.commandEpoch)
 local checkpoints=0;local completed=0;local quoteState="NotRequested"
 local function checkpoint()
  svc.checkpoint(e);idle();assert(equal(svc.profile(e).country,Country.capture(plan.world,state)),"Unconfirmed checkpoint")
  checkpoints+=1
 end
 if plan.phase=="Fund" then
  for i=1,plan.intervalCount do
   deps.wait(1);tick();idle() -- A delay never accumulates catch-up intervals.
   assert(svc.canMutate(e) and not e.critical,"Cannot fund while suspended")
   local demand=Demand.atStep(state.step,plan.world.meanTemperatureCentiC,plan.initial.country.settlement.population).demandMW
   local nextState=Country.advance(state,plan.world,demand)
   assert(plan.countries[nextState.step]==C.encode(Country.capture(plan.world,nextState),scalar),"Deterministic funding mismatch")
   svc.stage(e,Country.capture(plan.world,nextState),nextState.revision);state=nextState;completed+=1
   if i%30==0 or state.bank.balanceMinor>=125000 then checkpoint()end
   if state.bank.balanceMinor>=125000 then break end
  end
  assert(completed<=Plan.MAX_INTERVALS and state.bank.balanceMinor>=125000 and state.step==plan.finalStep,"Funding boundary")
 else
  local quotes=Quotes.create({owner=Plan.OWNER,epoch=e.commandEpoch,id=deps.id,now=deps.mono,
   country=function()return Country.capture(plan.world,state)end,
   build=function(op)svc.stage(e,Country.capture(plan.world,state),state.revision);return svc.build(e,op)end,
   profile=function()return svc.profile(e)end,saveStatus=function()return svc.status(e)end,
   canResume=function()return svc.canMutate(e)end,install=function(p)state=Country.restore(p,plan.world,e.commandEpoch)end})
  local q=quotes.handle(Plan.OWNER,{version=1,epoch=e.commandEpoch,sequence=1,command="Quote"})
  assert(q.state=="Available","Quote unavailable")
  local before=state.step
  local accepted=quotes.handle(Plan.OWNER,{version=1,epoch=e.commandEpoch,sequence=2,command="Confirm",quoteId=q.quoteId})
  assert(accepted.state=="Saving" and not svc.canMutate(e),"Critical suspension required")
  idle();quotes.tick();quoteState=quotes.status().state
  assert(quoteState=="Built" and state.step==before,"Durable purchase without simulation")
  -- Replace lastCommit without advancing: the permanent semantic receipt must survive.
  svc.stage(e,Country.capture(plan.world,state),state.revision);checkpoint()
  assert(quotes.handle(Plan.OWNER,{version=1,epoch=e.commandEpoch,sequence=3,command="Quote"}).state=="AlreadyBuilt","Permanent replay protection")
 end
 local confirmed=svc.profile(e)
 assert(equal(deps.adapter.read(Plan.KEY),confirmed),"Uncached financial/build confirmation required")
 svc.close(e);idle();assert(svc.stats().profiles==0,"Release incomplete")
 local final=deps.adapter.read(Plan.KEY)
 assert(not final.lease and equal(final,svc.profile(e)),"Uncached release confirmation required")
 return {profile=final,completedIntervals=completed,checkpoints=checkpoints,quoteState=quoteState,stats=deps.adapter.stats(),coordinator=svc.stats()}
end
return table.freeze(Runner)
