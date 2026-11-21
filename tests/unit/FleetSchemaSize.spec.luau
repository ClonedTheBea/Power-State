--!strict
-- Pure W5 gate. Size-only wind records are not a purchase or storage adapter.
return function()
 local S=game.ServerScriptService.Server;local H=game:GetService("HttpService")
 local C=require(S.Domain.ProfileCodec);local V3=require(S.Domain.ProfileSchema3)
 local V4=require(S.Domain.ProfileSchema4);local M3=require(S.Domain.ProfileMigrations3)
 local M4=require(S.Domain.ProfileMigrations4);local Country=require(S.Domain.ConstructionCountry)
 local District=require(S.Domain.ConstructionProject);local Wind=require(S.Domain.WindProject)
 local Demand=require(S.World.DemandModel)
 local FleetNetwork=require(S.Domain.CountryFleetNetwork);local FleetEconomy=require(S.Domain.FleetEconomy)
 local Solver=require(S.Operations.FleetSolver);local R=require(S.Domain.FleetRecord)
 local scalar=function(v:any):string return H:JSONEncode(v)end
 local id=function():string return H:GenerateGUID(false)end
 local checks=0;local function check(ok:boolean,message:string)assert(ok,message);checks+=1 end
 local observations={}
 local function measure(label:string,p:any)
  local bytes,soft=V4.validate(p,149564436,scalar)
  table.insert(observations,{label=label,bytes=bytes,softWarning=soft,headroom=262144-bytes,
   step=p.country.simulation.step,liveHistory=#p.country.simulation.history,
   frozenHistory=#p.country.fleet.baseline.legacySimulation.history})
  print("FLEET_SIZE_SAMPLE",H:JSONEncode(observations[#observations]))
 end
 local fixture=require(script.Parent.P3b4Fixture)()
 local p=M3.read(fixture.profile,149564436,scalar)
 local original=C.encode(p,scalar)
 local migrated=M4.read(p,149564436,id(),scalar)
 measure("newly-migrated-empty",migrated)
 check(C.encode(p,scalar)==original,"Migration does not mutate source")
 check(C.encode(V4.baselineCountry(migrated.country),scalar)==C.encode(p.country,scalar),"Exact old country reconstruction")
 check(C.encode(M4.read(migrated,149564436,id(),scalar),scalar)==C.encode(migrated,scalar),"Idempotent conversion")
 check(migrated.country.simulation~=migrated.country.fleet.baseline.legacySimulation,"Independent simulation objects")
 check(migrated.country.simulation.history~=migrated.country.fleet.baseline.legacySimulation.history,"Independent history arrays")
 check(migrated.country.simulation.history[1]~=migrated.country.fleet.baseline.legacySimulation.history[1],"Independent history rows")
 local state=Country.restore(p,fixture.world,id())
 local function envelope(country:any):any
  local n=C.copy(p);n.country=country;n.countryRevision=country.simulation.step+10
  n.lastCommit.countryRevision=n.countryRevision;return n
 end
 -- Genuine existing single/two-sink accounting; no invented funding balance.
 for i=1,3301 do
  state=Country.advance(state,fixture.world,Demand.atStep(state.step,fixture.world.meanTemperatureCentiC,1000).demandMW)
  if not state.construction.receipt and state.bank.balanceMinor>=125000 then
   local built=District.build(Country.capture(fixture.world,state),id(),state.step+1,p.profileRevision)
   state=Country.restore(envelope(built),fixture.world,id())
  end
  if i%50==0 then task.wait()end
 end
 p=envelope(Country.capture(fixture.world,state));V3.validate(p,149564436,scalar)
 local full=M4.read(p,149564436,id(),scalar);measure("full-rings-district-before-wind",full)
 check(full.country.bank.balanceMinor>=425000,"Ordinary earned funds cover wind plus buffer")
 local frozen=C.encode(full.country.fleet.baseline,scalar)
 -- Exact approved record shape for encoded-size coverage only. It is deliberately
 -- local to this test and cannot issue a quote, commit, or report purchase success.
 local after=C.copy(full);local c=after.country;local node,line=Wind.assets(c)
 c.bank.balanceMinor-=Wind.PRICE;c.bank.spentMinor+=Wind.PRICE;c.bank.windConstructionSpentMinor=Wind.PRICE
 c.fleet.investmentSerial=1;c.fleet.windState={on=true,capKW=2000}
 c.fleet.windReceipt={projectId=Wind.ID,definitionVersion=1,operationId=id(),priceMinor=Wind.PRICE,
  generatorId=node.id,lineId=line.id,step=c.simulation.step,beforeBankMinor=full.country.bank.balanceMinor,
  afterBankMinor=c.bank.balanceMinor,countryRevision=after.countryRevision,profileRevision=after.profileRevision}
 c.fleet.units[node.id]={costVersion=1,on=true,capKW=2000,generatedKwMinutes=0,onlineSteps=0,
  variableExpenseMinor=0,fixedExpenseMinor=0,variableExpenseRemainder=0,fixedExpenseRemainder=0}
 table.insert(c.deltas.builtNodes,node);table.insert(c.deltas.builtLines,line)
 measure("full-rings-both-receipts-wind",after)
 check(C.encode(c.fleet.baseline,scalar)==frozen,"Size fixture retains frozen baseline")
 local post=C.copy(after)
 for i=1,1441 do
  local demand=Demand.atStep(post.country.simulation.step,fixture.world.meanTemperatureCentiC,1000)
  local network=FleetNetwork.create(post.country,math.floor(demand.demandMW*1000+.5))
  local report=Solver.solve(network,post.country.simulation.step)
  post.country=FleetEconomy.settle(post.country,report)
  post.countryRevision+=1;post.lastCommit.countryRevision=post.countryRevision
  if i%50==0 then V4.validate(post,149564436,scalar);task.wait()end
 end
 measure("post-wind-full-day-real-pure-solver",post)
 check(C.encode(post.country.fleet.baseline,scalar)==frozen,"Frozen baseline after actual two-source billing and ring overwrite")
 check(post.country.fleet.units[node.id].generatedKwMinutes>0,"Wind dispatch enters its own energy/cost meters")
 -- Retained-country advance is independent from frozen validation data.
 for i=1,1441 do
  state=Country.advance(state,fixture.world,Demand.atStep(state.step,fixture.world.meanTemperatureCentiC,1000).demandMW)
  if i%50==0 then task.wait()end
 end
 local advanced=M4.read(envelope(Country.capture(fixture.world,state)),149564436,id(),scalar)
 advanced.country.fleet.baseline=C.copy(full.country.fleet.baseline)
 advanced.country.fleet.cutoverStep=full.country.fleet.cutoverStep
 measure("additional-day-no-wind-baseline-frozen",advanced)
 check(C.encode(V4.baselineCountry(advanced.country),scalar)==C.encode(p.country,scalar),"Exact baseline after ring replacement")
 -- Supported-range storage stress, not a claim to have replayed a billion steps.
 -- Constant 3.5 MW served history gives full-precision fractional JSON values.
 local extreme=C.copy(p);local ec=extreme.country;local es=ec.simulation;local ee=ec.economy
 local target=999998401;local elapsed=target-ee.activationStep
 es.step=target;es.online=true;es.historyIndex=(target-1)%1440+1;es.history={}
 es.windowRequested=0;es.windowDelivered=0
 for i=1,1440 do es.history[i]={requested=3500/60000,delivered=3500/60000};es.windowRequested+=3500/60000;es.windowDelivered+=3500/60000 end
 es.deliveredMWh=ee.baselineDeliveredMWh+elapsed*3500/60000;es.requestedMWh=ee.baselineRequestedMWh+elapsed*3500/60000
 ee.lastSettledStep=target;ee.generatedKwMinutes=elapsed*3500;ee.deliveredKwMinutes=ee.generatedKwMinutes;ee.onlineSteps=elapsed
 ee.baseSalesMinor,ee.baseSalesRemainder=R.amount(ee.deliveredKwMinutes,12000)
 ee.variableExpenseMinor,ee.variableExpenseRemainder=R.amount(ee.generatedKwMinutes,8000)
 ee.fixedExpenseMinor,ee.fixedExpenseRemainder=R.amount(elapsed*1000,1000)
 ee.statements={}
 for start=(math.floor(target/60)-24)*60,target-1,60 do
  local finish=math.min(start+60,target);local minutes=finish-start;local before=start-ee.activationStep
  local saleA=R.amount(before*3500,12000);local saleB=R.amount((before+minutes)*3500,12000)
  local varA=R.amount(before*3500,8000);local varB=R.amount((before+minutes)*3500,8000)
  local fixA=R.amount(before*1000,1000);local fixB=R.amount((before+minutes)*1000,1000)
  table.insert(ee.statements,{startStep=start,endStep=finish,deliveredKwMinutes=minutes*3500,generatedKwMinutes=minutes*3500,
   onlineSteps=minutes,baseSalesMinor=saleB-saleA,variableExpenseMinor=varB-varA,fixedExpenseMinor=fixB-fixA})
 end
 ec.bank.earnedMinor=ee.baseSalesMinor;ec.bank.spentMinor=ee.variableExpenseMinor+ee.fixedExpenseMinor+ec.bank.constructionSpentMinor
 ec.bank.balanceMinor=ec.bank.openingGrantMinor+ec.bank.earnedMinor-ec.bank.spentMinor
 extreme.countryRevision=target+100;extreme.profileRevision=999999999;extreme.sessionEpoch=99999999
 extreme.lastCommit={operationId=id(),kind="Checkpoint",fence=extreme.sessionEpoch,baseProfileRevision=extreme.profileRevision-1,
  committedProfileRevision=extreme.profileRevision,countryRevision=extreme.countryRevision}
 extreme.lease={ownerSessionId=id(),jobId=string.rep("j",64),placeId=9007199254740991,fence=extreme.sessionEpoch,expiresAtUtcMs=9007199254740991}
 V3.validate(extreme,149564436,scalar)
 local large=M4.read(extreme,149564436,id(),scalar);measure("supported-numeric-range-full-histories-25-statements",large)
 check(#large.country.economy.statements==25 and #large.country.fleet.baseline.legacyEconomy.statements==25,"Maximum supported statement retention")
 local lc=large.country
 lc.bank.balanceMinor-=Wind.PRICE;lc.bank.spentMinor+=Wind.PRICE;lc.bank.windConstructionSpentMinor=Wind.PRICE
 lc.fleet.windReceipt=C.copy(after.country.fleet.windReceipt);lc.fleet.windReceipt.step=target
 lc.fleet.windReceipt.beforeBankMinor=lc.bank.balanceMinor+Wind.PRICE;lc.fleet.windReceipt.afterBankMinor=lc.bank.balanceMinor
 lc.fleet.windReceipt.countryRevision=large.countryRevision;lc.fleet.windReceipt.profileRevision=large.profileRevision
 lc.fleet.windState={on=true,capKW=2000};lc.fleet.investmentSerial=1
 lc.fleet.units[node.id]=C.copy(after.country.fleet.units[node.id]);lc.deltas=C.copy(after.country.deltas)
 measure("supported-numeric-range-both-receipts-wind",large)
 for i=1,100 do
  local demand=Demand.atStep(large.country.simulation.step,fixture.world.meanTemperatureCentiC,1000)
  local network=FleetNetwork.create(large.country,math.floor(demand.demandMW*1000+.5))
  large.country=FleetEconomy.settle(large.country,Solver.solve(network,large.country.simulation.step))
  large.countryRevision+=1;large.lastCommit.countryRevision=large.countryRevision
  if i%25==0 then task.wait()end
 end
 measure("supported-numeric-range-post-wind",large)
 -- Conservative structural envelope: reserve 24 encoded characters for every
 -- numeric scalar, plus 1024 bytes for bounded identity/name variation. This is
 -- a size bound, not a valid serialized profile or a replacement representation.
 local bound=#C.encode(large,function(v:any):string
  if type(v)=="number"then check(#scalar(v)<=24,"Numeric width assumption");return string.rep("9",24)end
  return scalar(v)
 end)+1024
 check(bound<262144,"Credible complete-profile growth headroom")
 print("FLEET_SIZE_ENVELOPE",H:JSONEncode({bytes=bound,headroom=262144-bound,softWarning=bound>196608}))
 for _,mutation in {
  function(n:any)n.country.fleet.cutoverStep+=1 end,
  function(n:any)n.country.fleet.baseline.legacySimulation.step+=1 end,
  function(n:any)n.country.fleet.units[n.country.network.generatorId].variableExpenseRemainder+=1 end,
  function(n:any)n.country.bank.balanceMinor+=1 end,
  function(n:any)n.country.fleet.baseline.legacySimulation.history[1].delivered+=1 end,
 }do local n=C.copy(full);mutation(n);check(not pcall(function()V4.validate(n,149564436,scalar)end),"Reject malformed cutover/carry/Bank/history")end
 print("FLEET_SCHEMA_SIZE_INITIAL",H:JSONEncode({checks=checks,samples=observations,
  status="Representative and supported-range pure gate samples; not persistence or runtime acceptance"}))
 print("FLEET_SCHEMA_SIZE_COUNTS",checks)
 return {funded=full,built=after,post=post,high=large,world=fixture.world,samples=observations,upperBytes=bound}
end
