--!strict
return function(fixtures:any)
 local S=game.ServerScriptService.Server
 local Country=require(S.Domain.FleetCountry);local Batch=require(S.Services.CountryFleetBatch)
 local C=require(S.Domain.ProfileCodec);local R=require(S.Domain.FleetRecord)
 local checks=0
 local function check(v:boolean,m:string)assert(v,m);checks+=1 end
 local function binding():any
  local state=Country.restore(fixtures.built,fixtures.world,"fake-fleet-cancellation")
  return {actor={world=fixtures.world,state=state},entry={owner=state.owner,fence=1}}
 end
 for _,kind in {"replaced","ownerLost","close","workLimit","deadline"}do
  local b=binding();local before=b.actor.state;local current=true;local installed=0;local failure=nil;local clock=0
  local options:any={current=function()return current end,install=function()installed+=1 end,failed=function(_,why)failure=why end}
  if kind=="workLimit"then options.scheduler={operationLimit=1}end
  if kind=="deadline"then options.scheduler={clock=function()return clock end}end
  local batch=Batch.new({b},options)
  check(not pcall(Batch.new,{b},options),"Overlapping country admission rejected")
  if kind=="replaced"then b.actor.state=R.freeze(C.copy(before))
  elseif kind=="ownerLost"then current=false
  elseif kind=="deadline"then clock=1
  elseif kind=="close"then batch.close()end
  if kind~="close"then
   for _=1,100 do batch.step();if batch.done()then break end end
   check(batch.done(),"Cancelled/failed job terminates")
  end
  batch.close()
  check(installed==0 and b.actor.state.step==before.step and b.actor.state.bank.balanceMinor==before.bank.balanceMinor,"No stale/failed energy or money installation")
  check(b.actor.fleetJob==nil,"Cancelled/failed ownership reference released")
  if kind=="workLimit"or kind=="deadline"then check(failure~=nil,"Hard failure reported for suspension")end
 end
 local b=binding();local options={current=function()return true end,install=function()end,failed=function()end}
 local forecast=require(S.Domain.CountryFleetForecast)
 local before=b.actor.state;local projected=forecast.create(before)
 local controls=require(S.Services.FleetControls)
 local prior=C.copy(before);prior.lastSequence=7;prior.controlRevision=9;prior.tokens=2;prior.rateAt=100000
 local restored=Country.restore(fixtures.built,b.actor.world,prior.epoch,R.freeze(prior))
 check(restored.lastSequence==7 and restored.controlRevision==10 and restored.tokens==2,"Commit preserves sequence/rate admission and invalidates old control revision")
 local replay,reason=controls.handle(restored,b.actor.world,restored.owner,{version=1,kind="SetFleetGenerator",epoch=restored.epoch,
  sequence=7,revision=9,assetId=restored.network.generatorId,online=false,capKW=5000},100000,true)
 check(replay==restored and reason=="Rejected","Pre-build command cannot replay after committed installation")
 check(#projected==5 and projected[1].offsetMinutes==0 and projected[5].offsetMinutes==60,"Bounded forecast horizon")
 check(b.actor.state==before,"Forecast never advances electricity or finance")
 for _,point in projected do
  check(point.windAvailableKW<=1600 and point.capacityMarginKW==point.availableKW-point.demandKW,"Forecast is capacity arithmetic, not dispatch")
 end
 local report=require(S.Operations.FleetSolver).solve(Country.prepare(before,b.actor.world,3000),before.step)
 local nextState=Country.complete(before,b.actor.world,report,Country.prepare(before,b.actor.world,3000))
 check(nextState.report.sinks[1].id==before.network.demandId and nextState.report.sinks[2].id==before.construction.receipt.terminalId,"Stable public sink identities")
 for id,available in nextState.fleetReport.availableKW do
  check(available-nextState.fleetReport.sources[id]==nextState.fleetReport.curtailedKW[id],"Server reports unused available capacity")
 end
 local nine={};for _=1,9 do table.insert(nine,b)end
 check(not pcall(Batch.new,nine,options),"Ninth country rejected before admission")
 check(not pcall(Batch.new,{b,b},options)and b.actor.fleetJob==nil,"Duplicate country rejected without retained jobs")
 b.entry.owner+=1
 check(not pcall(Batch.new,{b},options)and b.actor.fleetJob==nil,"Foreign coordinator owner rejected")
 print("[Owned fleet cancellation] PASS",checks)
 return checks
end
