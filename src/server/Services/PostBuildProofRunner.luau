--!strict
-- Manual finite runner: no Heartbeat, quote, Build or normal startup entry point.
local C=require(script.Parent.Parent.Domain.ProfileCodec)
local V=require(script.Parent.Parent.Domain.ProfileSchema3)
local Lease=require(script.Parent.Parent.Domain.ProfileLease3)
local Country=require(script.Parent.Parent.Domain.ConstructionCountry)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Plan=require(script.Parent.Parent.Domain.PostBuildProofPlan)
local Profiles=require(script.Parent.ProfileService)
local Runner={}
function Runner.run(deps:any,plan:any):any
 local began=deps.mono();local scalar=deps.scalar
 local svc=Profiles.create({adapter=deps.adapter,schema=V,lease=Lease,prepareCountry=V.country,scalar=scalar,id=deps.id,
  utcMs=deps.utcMs,mono=deps.mono,spawn=deps.spawn,random=deps.random,jobId="PostBuildProofOnly",placeId=deps.placeId})
 local e=svc.reserve(Plan.OWNER);assert(e,"Admission refused")
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local function tick()
  assert(deps.present() and deps.mono()-began<90,"PostBuild presence/deadline")
  svc.tick();assert(not e.terminal,"Persistence suspended: "..tostring(e.reason))
 end
 local function idle()
  local start=deps.mono()
  repeat tick();if not e.op and not e.inFlight and not e.result then return end
   assert(deps.mono()-start<30,"Operation deadline");deps.wait(.05)
  until false
 end
 svc.prepared(e,plan.initial.country);idle();svc.activate(e)
 assert(equal(svc.profile(e).country,plan.initial.country),"No acquisition/offline progression")
 local state=Country.restore(svc.profile(e),plan.world,e.commandEpoch);local rows={}
 for _=1,plan.intervalCount do
  deps.wait(1);idle();assert(svc.canMutate(e),"Safe lease before interval")
  local demand=Demand.atStep(state.step,plan.world.meanTemperatureCentiC,plan.initial.country.settlement.population).demandMW
  state=Country.advance(state,plan.world,demand)
  local country=Country.capture(plan.world,state)
  assert(C.encode(country,scalar)==plan.countries[state.step],"Exact computed interval")
  local row=plan.rows[state.step-242];local report=state.report
  assert(math.abs(report.sinks[1].requestedMW-row.townKW/1000)<1e-9 and math.abs(report.sinks[1].deliveredMW-row.townKW/1000)<1e-9,"Actual town service")
  assert(math.abs(report.sinks[2].requestedMW-row.districtKW/1000)<1e-9 and math.abs(report.sinks[2].deliveredMW-row.districtKW/1000)<1e-9,"Actual district service")
  assert(math.abs(report.flows[state.construction.receipt.lineId]-row.districtKW/1000)<1e-9,"Actual feeder flow")
  for _,line in plan.world.network.lines do assert(math.abs(report.flows[line.id]-(row.townKW+row.districtKW)/1000)<1e-9 and report.flows[line.id]<=line.capacity,"Actual upstream flow")end
  table.insert(rows,C.copy(row))
  svc.stage(e,country,state.revision)
 end
 assert(state.step==plan.finalStep,"Exact interval count")
 svc.checkpoint(e);idle();local confirmed=svc.profile(e)
 assert(equal(confirmed.country,Country.capture(plan.world,state)),"Whole financial checkpoint")
 assert(equal(deps.adapter.read(Plan.KEY),confirmed),"Uncached checkpoint confirmation")
 svc.close(e);idle();local final=deps.adapter.read(Plan.KEY)
 assert(not final.lease and equal(final,svc.profile(e)) and svc.stats().profiles==0,"Exact released confirmation")
 assert(final.profileRevision==plan.initial.profileRevision+3,"Unexpected logical transition")
 assert(deps.mono()-began<90,"Final session deadline")
 return {profile=final,rows=rows,stats=deps.adapter.stats(),coordinator=svc.stats(),elapsedSeconds=deps.mono()-began}
end
return table.freeze(Runner)
