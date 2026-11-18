--!strict
-- P3b.5 exact five-interval authority. Planning uses copies, never durable state.
local C=require(script.Parent.ProfileCodec)
local V=require(script.Parent.ProfileSchema2)
local EC=require(script.Parent.EconomicCountry)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Generator=require(script.Parent.Parent.World.WorldGenerator)
local P=require(script.Parent.ExistingEconomyStore)
local Plan={}
function Plan.create(p:any,phase:number,scalar:(any)->string):any
 V.validate(p,P.OWNER,scalar)
 assert(phase==1 or phase==2,"Unknown proof phase")
 assert(p.country.recipe.countryId==P.COUNTRY_ID and not p.lease,"Reviewed released country required")
 local c=p.country;local e=c.economy
 assert(e.activationStep==113 and e.fundingReason==nil,"Unexpected activation/funding state")
 assert(c.simulation.step==(if phase==1 then 113 else 117) and c.simulation.online==(phase==1),"Unexpected step/generator; review required")
 assert(c.bank.balanceMinor==(if phase==1 then 100000 else 100574),"Unexpected Bank; review required")
 for key,expected in {deliveredKwMinutes=if phase==1 then 0 else 9360,generatedKwMinutes=if phase==1 then 0 else 9360,onlineSteps=if phase==1 then 0 else 3,baseSalesMinor=if phase==1 then 0 else 1872,variableExpenseMinor=if phase==1 then 0 else 1248,fixedExpenseMinor=if phase==1 then 0 else 50,bonusSalesMinor=0,baseSalesRemainder=0,bonusSalesRemainder=0,variableExpenseRemainder=0,fixedExpenseRemainder=0}do
  assert(e[key]==expected,"Unexpected financial starting state: "..tostring(key))
 end
 local world=Generator.create(c.recipe.seed,c.recipe.countryId,c.recipe.generationVersion)
 local state=EC.restore(p,world,"00000000-0000-0000-0000-000000000001")
 assert(C.encode(EC.capture(world,state),scalar)==C.encode(c,scalar),"Restore changed country")
 local checkpoints={};local intervals={};local sequence=0
 local function toggle(online:boolean)
  sequence+=1
  assert(EC.handle(state,P.OWNER,{version=1,kind="SetGenerator",epoch=state.epoch,sequence=sequence,revision=state.controlRevision,assetId=state.network.generatorId,online=online},sequence)=="Accepted","Planned control rejected")
 end
 local function advance()
  local d=Demand.atStep(state.step,world.meanTemperatureCentiC,1000)
  state=EC.advance(state,d.demandMW)
  table.insert(intervals,{step=state.step,online=state.online,demandMW=d.demandMW,deliveredMW=state.report.deliveredMW,outputMW=state.report.outputMW,bankMinor=state.bank.balanceMinor})
 end
 local function checkpoint()table.insert(checkpoints,{country=EC.capture(world,state),revision=state.revision})end
 if phase==1 then
  for _=1,3 do advance()end;assert(state.bank.balanceMinor==100574,"Three-On arithmetic differs; stop")
  checkpoint();toggle(false);advance();checkpoint()
 else toggle(true);advance();checkpoint()end
 assert(state.step==(if phase==1 then 117 else 118) and state.bank.balanceMinor==(if phase==1 then 100574 else 100766),"Final arithmetic differs; stop")
 return {phase=phase,initial=C.copy(p),world=world,checkpoints=checkpoints,intervals=intervals,maxIntervals=if phase==1 then 4 else 1}
end
function Plan.guard(store:any,plan:any,scalar:(any)->string):any
 local function equal(a:any,b:any):boolean return C.encode(a,scalar)==C.encode(b,scalar)end
 local countries={plan.initial.country};for _,cp in plan.checkpoints do table.insert(countries,cp.country)end
 local function index(country:any):number
  for i,c in countries do if equal(c,country)then return i end end
  error("Country outside bounded proof")
 end
 local adapter=table.clone(store)
 adapter.update=function(key:string,transform:(any)->any):any
  return store.update(key,function(current:any):any
   local before=index(current.country);local updated=transform(current);if not updated then return nil end
   if updated.lastCommit.operationId==current.lastCommit.operationId then assert(equal(updated,current),"Replay changed record");return updated end
   local kind=updated.lastCommit.kind;local after=index(updated.country)
   if kind=="Acquire" then assert(equal(current,plan.initial) and before==after,"Only initial acquisition")
   elseif kind=="Checkpoint" then assert(after==before+1 and updated.countryRevision==plan.checkpoints[after-1].revision,"Only next planned checkpoint")
   elseif kind=="Renew" then assert(before==after,"Renew cannot advance")
   elseif kind=="Release" then assert(before==#countries and after==before,"Release only confirmed final country")
   else error("Unapproved proof operation")end
   return updated
  end)
 end
 return adapter
end
return table.freeze(Plan)
