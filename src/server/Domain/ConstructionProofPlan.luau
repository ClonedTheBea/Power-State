--!strict
-- A finite replay allowlist, not a source of credits or a live simulation clock.
local C=require(script.Parent.ProfileCodec)
local V=require(script.Parent.ProfileSchema3)
local Country=require(script.Parent.ConstructionCountry)
local Project=require(script.Parent.ConstructionProject)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Generator=require(script.Parent.Parent.World.WorldGenerator)
local Plan={OWNER=149564436,KEY="u:149564436",COUNTRY_ID="55e35a88-e3b9-4f72-9e69-d9024e7730a4",MAX_INTERVALS=128}
function Plan.create(profile:any,phase:string,scalar:(any)->string):any
 V.validate(profile,Plan.OWNER,scalar)
 assert(phase=="Fund" or phase=="Build","Unknown proof phase")
 assert(not profile.lease and profile.country.recipe.countryId==Plan.COUNTRY_ID,"Released reviewed country required")
 local c=profile.country
 assert(c.recipe.seed=="1441a4d819354af7b306ef8797931e15" and c.settlement.name=="Rowanbridge","Reviewed identity required")
 assert(not c.construction.receipt and c.simulation.online and not c.economy.fundingReason,"Unexpected construction/generator state")
 local world=Generator.create(c.recipe.seed,c.recipe.countryId,c.recipe.generationVersion)
 local state=Country.restore(profile,world,"00000000-0000-0000-0000-000000000001")
 assert(C.encode(Country.capture(world,state),scalar)==C.encode(c,scalar),"Exact restoration required")
 local countries={[state.step]=C.encode(c,scalar)};local revisions={[state.step]=state.revision};local intervals={}
 if phase=="Fund" then
  assert(c.bank.balanceMinor<125000,"Already funded; new review required")
  while state.bank.balanceMinor<125000 and #intervals<Plan.MAX_INTERVALS do
   local demand=Demand.atStep(state.step,world.meanTemperatureCentiC,c.settlement.population).demandMW
   state=Country.advance(state,world,demand)
   table.insert(intervals,{step=state.step,bankMinor=state.bank.balanceMinor,requestedMW=state.report.demandMW,deliveredMW=state.report.deliveredMW})
   countries[state.step]=C.encode(Country.capture(world,state),scalar);revisions[state.step]=state.revision
  end
  assert(state.bank.balanceMinor>=125000,"Funding exceeds proposed interval cap; stop for review")
 else assert(c.bank.balanceMinor>=125000,"Construction is not affordable")end
 return {phase=phase,initial=C.copy(profile),world=world,countries=countries,revisions=revisions,intervals=intervals,
  finalCountry=Country.capture(world,state),finalRevision=state.revision,finalStep=state.step,intervalCount=#intervals}
end
function Plan.guard(transport:any,plan:any,scalar:(any)->string):any
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local initial=plan.initial
 local function validate(p:any)
  V.validate(p,Plan.OWNER,scalar)
  assert(p.country.recipe.countryId==Plan.COUNTRY_ID,"Wrong country")
  assert(p.profileRevision>=initial.profileRevision and p.profileRevision<=initial.profileRevision+(if plan.phase=="Fund" then 12 else 6),"Logical write ceiling")
  if p.country.construction.receipt then
   assert(plan.phase=="Build","No construction during funding")
   local r=p.country.construction.receipt
   assert(equal(p.country,Project.build(initial.country,r.operationId,initial.countryRevision+1,r.profileRevision)),"Only exact reviewed purchase")
   assert(p.countryRevision==initial.countryRevision+1,"Purchase revision")
  else
   assert(plan.countries[p.country.simulation.step]==C.encode(p.country,scalar),"Country outside deterministic proof")
   assert(p.countryRevision==plan.revisions[p.country.simulation.step],"Unapproved country revision")
  end
 end
 local calls,reads,writes=0,0,0
 local function consume(kind:string,key:string)
  assert(key==Plan.KEY,"Exact key only")
  assert(calls<64 and (if kind=="Read" then reads<24 else writes<40),"Proof request ceiling")
  calls+=1;if kind=="Read" then reads+=1 else writes+=1 end
 end
 local adapter={mode=transport.mode,preflight=C.copy(initial),budget=transport.budget,
  stats=function():any return {calls=calls,reads=reads,writes=writes}end}
 adapter.read=function(key:string):any consume("Read",key);local p=transport.read(key);validate(p);return p end
 adapter.update=function(key:string,transform:(any)->any):any
  consume("Update",key)
  return transport.update(key,function(current:any):any
   validate(current)
   local nextValue=transform(C.copy(current));if not nextValue then return nil end;validate(nextValue)
   if current.lastCommit.operationId==nextValue.lastCommit.operationId then assert(equal(current,nextValue),"Mutating replay");return nextValue end
   local kind=nextValue.lastCommit.kind
   if kind=="Acquire" then assert(equal(current,initial) and equal(nextValue.country,current.country),"Only reviewed acquisition")
   elseif kind=="Build" then assert(plan.phase=="Build" and not current.country.construction.receipt and nextValue.country.construction.receipt,"One purchase only")
   elseif kind=="Renew" then assert(equal(current.country,nextValue.country),"Renew cannot mutate country")
   elseif kind=="Checkpoint" then
    if plan.phase=="Build" then assert(current.country.construction.receipt and equal(current.country,nextValue.country),"No post-build simulation authority")
    else assert(nextValue.country.simulation.step>=current.country.simulation.step,"No step regression")end
   elseif kind=="Release" then assert(equal(current.country,nextValue.country),"Release only confirmed country")
   else error("Unapproved operation")end
   return nextValue
  end)
 end
 return adapter
end
return table.freeze(Plan)
