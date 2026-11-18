--!strict
-- Finite deterministic progression; no generic gameplay or construction authority.
local C=require(script.Parent.ProfileCodec)
local V=require(script.Parent.ProfileSchema3)
local Country=require(script.Parent.ConstructionCountry)
local Demand=require(script.Parent.Parent.World.DemandModel)
local World=require(script.Parent.Parent.World.WorldGenerator)
local Plan={OWNER=149564436,KEY="u:149564436",COUNTRY_ID="55e35a88-e3b9-4f72-9e69-d9024e7730a4"}
function Plan.create(origin:any,review:any,phase:string,scalar:(any)->string):any
 V.validate(origin,Plan.OWNER,scalar);V.validate(review,Plan.OWNER,scalar)
 assert(phase=="A" or phase=="B","Two sessions only")
 assert(not origin.lease and origin.profileRevision==37 and origin.countryRevision==257 and origin.sessionEpoch==10,"Original released envelope")
 local c=origin.country
 assert(c.recipe.countryId==Plan.COUNTRY_ID and c.recipe.seed=="1441a4d819354af7b306ef8797931e15" and c.settlement.name=="Rowanbridge","Exact country")
 assert(c.simulation.step==242 and c.simulation.online and c.bank.balanceMinor==25003 and c.construction.receipt,"Built origin")
 local world=World.create(c.recipe.seed,c.recipe.countryId,c.recipe.generationVersion)
 local state=Country.restore(origin,world,"00000000-0000-0000-0000-000000000001")
 local countries={[242]=C.encode(c,scalar)};local rows={}
 for i=1,5 do
  local demand=Demand.atStep(state.step,world.meanTemperatureCentiC,c.settlement.population).demandMW
  local before=state;state=Country.advance(state,world,demand)
  local nextCountry=Country.capture(world,state);local report=state.report
  local town=({3370,3374,3378,3382,3386})[i];local district=math.floor((town+2)/4)
  assert(math.abs(report.sinks[1].deliveredMW-town/1000)<1e-9 and math.abs(report.sinks[2].deliveredMW-district/1000)<1e-9,"Pinned independent delivery")
  assert(math.abs(report.sinks[1].requestedMW-town/1000)<1e-9 and math.abs(report.sinks[2].requestedMW-district/1000)<1e-9,"Pinned demand")
  assert(math.abs(report.flows[c.construction.receipt.lineId]-district/1000)<1e-9 and district<=1000,"Feeder conservation")
  for _,line in world.network.lines do assert(math.abs(report.flows[line.id]-(town+district)/1000)<1e-9 and report.flows[line.id]<=line.capacity,"Upstream conservation")end
  assert(C.encode(nextCountry.construction,scalar)==C.encode(c.construction,scalar) and C.encode(nextCountry.deltas,scalar)==C.encode(c.deltas,scalar),"Protected construction")
  countries[state.step]=C.encode(nextCountry,scalar)
  table.insert(rows,{step=state.step,townKW=town,districtKW=district,bankMinor=state.bank.balanceMinor,
   salesMinor=state.economy.baseSalesMinor-before.economy.baseSalesMinor,variableMinor=state.economy.variableExpenseMinor-before.economy.variableExpenseMinor,
   fixedMinor=state.economy.fixedExpenseMinor-before.economy.fixedExpenseMinor})
 end
 assert(state.bank.balanceMinor==26328 and state.economy.baseSalesRemainder==36000 and state.economy.variableExpenseRemainder==24000 and state.economy.fixedExpenseRemainder==40000,"Pinned final accounting")
 local start=if phase=="A" then 242 else 245;local finish=if phase=="A" then 245 else 247
 assert(not review.lease and C.encode(review.country,scalar)==countries[start],"Exact phase country")
 assert(review.profileRevision==(if phase=="A" then 37 else 40) and review.countryRevision==257+start-242 and review.sessionEpoch==(if phase=="A" then 10 else 11),"Exact phase envelope")
 if phase=="A" then assert(C.encode(review,scalar)==C.encode(origin,scalar),"Exact initial profile")end
 return {phase=phase,initial=C.copy(review),world=world,countries=countries,rows=rows,startStep=start,finalStep=finish,intervalCount=finish-start}
end
function Plan.guard(transport:any,plan:any,scalar:(any)->string):any
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local initial=plan.initial;local calls,reads,writes=1,1,0 -- Includes mandatory preflight.
 local function validate(p:any)
  V.validate(p,Plan.OWNER,scalar)
  local d=p.profileRevision-initial.profileRevision
  assert(d>=0 and d<=3 and d%1==0,"Logical operation bound")
  assert(p.ownerUserId==initial.ownerUserId and p.createdAtUtc==initial.createdAtUtc,"Envelope identity")
  local step=if d<2 then plan.startStep else plan.finalStep
  assert(p.country.simulation.step==step and C.encode(p.country,scalar)==plan.countries[step],"Exact country progression only")
  assert(p.countryRevision==initial.countryRevision+step-plan.startStep,"Exact country revision")
  assert(p.sessionEpoch==initial.sessionEpoch+(if d==0 then 0 else 1),"One fenced acquisition")
  if d==0 then assert(equal(p,initial),"Exact initial head")
  else
   assert(p.lastCommit.kind==({"Acquire","Checkpoint","Release"})[d],"One checkpoint and release only")
   assert((d==3)==(p.lease==nil),"Lease phase")
  end
 end
 local function consume(kind:string,key:string)
  assert(key==Plan.KEY,"Exact approved key")
  -- Split envelope guarantees <=24 calls/12 reads/12 writes over two contexts.
  assert(calls<12 and (if kind=="Read" then reads<6 else writes<6),"PostBuild request ceiling")
  calls+=1;if kind=="Read" then reads+=1 else writes+=1 end
 end
 local adapter={mode=transport.mode,preflight=C.copy(initial),budget=transport.budget,
  stats=function():any return {calls=calls,reads=reads,writes=writes}end}
 adapter.read=function(key:string):any consume("Read",key);local p=transport.read(key);validate(p);return p end
 adapter.update=function(key:string,transform:(any)->any):any
  consume("Update",key)
  return transport.update(key,function(current:any):any
   validate(current);local n=transform(C.copy(current));if not n then return nil end;validate(n)
   if current.lastCommit.operationId==n.lastCommit.operationId then assert(equal(current,n),"Immutable callback replay");return n end
   assert(n.profileRevision==current.profileRevision+1,"Single revision transition")
   if n.lastCommit.kind=="Acquire" then assert(equal(current,initial),"Reviewed acquire only")
   else
    assert(current.lease and n.lastCommit.fence==current.lease.fence,"Existing fenced owner")
    if n.lease then
     assert(n.lease.ownerSessionId==current.lease.ownerSessionId and n.lease.jobId==current.lease.jobId and n.lease.placeId==current.lease.placeId,"Same session")
    end
   end
   return n
  end)
 end
 return adapter
end
return table.freeze(Plan)
