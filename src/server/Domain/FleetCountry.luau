--!strict
local C=require(script.Parent.ProfileCodec)
local Schema=require(script.Parent.ProfileSchema4)
local Legacy=require(script.Parent.ConstructionCountry)
local Base=require(script.Parent.ProfileCountry)
local Network=require(script.Parent.CountryFleetNetwork)
local Economy=require(script.Parent.FleetEconomy)
local R=require(script.Parent.FleetRecord)
local Country={}
local function install(state:any,c:any):any
 local s=table.clone(state);s.network=table.clone(state.network)
 for key,value in c.simulation do if key~="simulationVersion"then s[key]=value end end
 for _,key in {"bank","economy","construction","deltas","fleet"}do s[key]=c[key]end
 s.countryId=c.recipe.countryId;return s
end
local function record(world:any,s:any):any
 assert(table.isfrozen(s)and s.identity and world.countryId==s.countryId,"Validated immutable owned state required")
 local c=table.clone(s.identity);c.simulation={simulationVersion=1}
 for _,key in {"step","online","requestedMWh","deliveredMWh","history","historyIndex","windowRequested","windowDelivered"}do c.simulation[key]=s[key]end
 for _,key in {"bank","economy","construction","deltas","fleet"}do c[key]=s[key]end
 return c
end
function Country.capture(world:any,s:any):any
 local c=record(world,s)
 Schema.country(c);return c
end
function Country.restore(p:any,world:any,epoch:string,previous:any?):any
 Schema.country(p.country)
 local structural=table.clone(p);structural.schemaVersion=1;structural.country=Schema.structural(p.country)
 local s=install(Base.restore(structural,world,epoch),C.copy(p.country))
 if previous then
  assert(previous.epoch==epoch and previous.owner==p.ownerUserId and previous.countryId==p.country.recipe.countryId,"Same-session committed installation only")
  s.lastSequence=previous.lastSequence;s.tokens=previous.tokens;s.rateAt=previous.rateAt
  s.controlRevision=previous.controlRevision+1
 end
 s.identity={recipe=C.copy(p.country.recipe),settlement=C.copy(p.country.settlement),network=C.copy(p.country.network),ownedSectors=C.copy(p.country.ownedSectors)}
 -- No saved dispatch report is fabricated on reconnect. The next completed
 -- interval supplies real source output; history and finance already restored.
 s.fleetReport=nil;s.dispatchPending=s.fleet.windReceipt~=nil
 s.report=require(script.Parent.Parent.Simulation.DistrictSolver).solve(p.country,s.network.demandMW,if s.fleet.windReceipt then false else s.online)
 if s.fleet.windReceipt then s.report.status="Awaiting first dispatch";s.report.pending=true end
 R.freeze(s);Country.capture(world,s);return s
end
function Country.prepare(s:any,world:any,starterKW:number):any
 assert(not s.suspended and s.fleet.windReceipt,"Active owned fleet required")
 local c=record(world,s)
 assert(c.bank.balanceMinor>=Economy.reservation(c),"InsufficientOperatingFunds")
 return Network.create(c,starterKW)
end
function Country.complete(s:any,world:any,report:any,network:any):any
 local c=Economy.settle(record(world,s),report);Schema.country(c)
 local n=install(s,c);n.revision=s.revision+1;n.fleetReport=C.copy(report);n.dispatchPending=false
 local available=0;n.fleetReport.availableKW={};n.fleetReport.curtailedKW={}
 for _,source in network.sources do
  available+=source.availableKW
  n.fleetReport.availableKW[source.id]=source.availableKW
  n.fleetReport.curtailedKW[source.id]=source.availableKW-report.sources[source.id]
 end
 local flows,sinks={},{}
 for id,value in report.flowsKW do flows[id]=value/1000 end
 -- Preserve the existing public town/district ordering; solver maps are keyed
 -- by electrical identity, and lexical ID order is not presentation order.
 for _,sink in network.sinks do
  local value=report.sinks[sink.id]
  table.insert(sinks,{id=sink.id,requestedMW=value.requestedKW/1000,deliveredMW=value.deliveredKW/1000,unmetMW=value.unmetKW/1000})
 end
 n.report={demandMW=report.requestedKW/1000,deliveredMW=report.deliveredKW/1000,outputMW=report.generatedKW/1000,
  availableMW=available/1000,unmetMW=report.unmetKW/1000,headroomMW=(available-report.generatedKW)/1000,
  serviceRatio=if report.requestedKW>0 then report.deliveredKW/report.requestedKW else -1,operations=report.operations,
  flows=flows,sinks=sinks,status=if report.unmetKW==0 then "Served"else "Supply shortfall"}
 n.network.demandMW=network.sinks[1].requestedKW/1000
 return R.freeze(n)
end
function Country.advanceLegacy(s:any,world:any,demandMW:number):any
 assert(not s.fleet.windReceipt,"Owned fleet requires scheduled solve")
 local old=C.copy(s);old.fleet=nil;old.bank.ledgerVersion=3;old.bank.windConstructionSpentMinor=nil;old.economy.economyVersion=1
 local n=Legacy.advance(old,world,demandMW)
 n.bank.ledgerVersion=4;n.bank.windConstructionSpentMinor=0;n.economy.economyVersion=2;n.fleet=C.copy(s.fleet)
 local gas=n.fleet.units[n.network.generatorId];gas.on=n.online
 for _,key in {"generatedKwMinutes","onlineSteps","variableExpenseMinor","fixedExpenseMinor","variableExpenseRemainder","fixedExpenseRemainder"}do gas[key]=n.economy[key]end
 R.freeze(n);Country.capture(world,n);return n
end
function Country.fundOrStop(s:any,world:any):any
 local c=Country.capture(world,s)
 if c.bank.balanceMinor>=Economy.reservation(c)then return s end
 local n=C.copy(s);n.online=false;n.controlRevision+=1;n.revision+=1
 for _,u in n.fleet.units do u.on=false end
 if n.fleet.windState then n.fleet.windState.on=false end
 n.economy.fundingReason="InsufficientOperatingFunds";n.economy.fundingStep=n.step
 return R.freeze(n)
end
return table.freeze(Country)
