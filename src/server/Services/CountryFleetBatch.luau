--!strict
-- One bounded scheduler for up to eight owned countries, not eight frame budgets.
local Scheduler=require(script.Parent.Parent.Operations.FleetJobScheduler)
local Country=require(script.Parent.Parent.Domain.FleetCountry)
local Demand=require(script.Parent.Parent.World.DemandModel)
local Batch={}
function Batch.new(bindings:any,options:any):any
 assert(#bindings>=1 and #bindings<=8,"Owned fleet batch bound")
 local records={};local byId={};local began=os.clock();local closed=false
 local config=table.clone(options.scheduler or {})
 config.isCurrent=function(input:any):boolean
  local r=byId[input.countryId]
  return r~=nil and r.binding.actor.state==r.base and options.current(r.binding) and table.isfrozen(r.base)
 end
 local count=0
 for index,binding in bindings do
  assert(type(index)=="number"and index%1==0 and index>=1 and index<=#bindings,"Dense fleet batch")
  count+=1
  local actor=binding.actor;local base=actor.state
  assert(table.isfrozen(base) and not actor.fleetJob,"No overlapping/mutable fleet input")
  assert(binding.entry.owner==base.owner and options.current(binding),"Authenticated current country owner")
  assert(not byId[base.countryId],"Duplicate owned country")
  local demand=Demand.atStep(base.step,1700,1000)
  local network=Country.prepare(base,actor.world,math.floor(demand.demandMW*1000+.5))
  local r:any={binding=binding,base=base,network=network,done=false}
  byId[base.countryId]=r;table.insert(records,r)
 end
 assert(count==#bindings,"Dense fleet admission")
 local scheduler=Scheduler.new(config)
 local admitted,problem=pcall(function()
  for _,r in records do
   local base=r.base;r.binding.actor.fleetJob=r
   r.handle=scheduler.admit({countryId=base.countryId,epoch=r.binding.entry.fence,step=base.step,countryRevision=base.revision,
    topologyRevision=base.construction.topologyRevision+base.fleet.investmentSerial,network=r.network})
  end
 end)
 if not admitted then
  scheduler.close();for _,r in records do if r.binding.actor.fleetJob==r then r.binding.actor.fleetJob=nil end end
  error(problem)
 end
 local api={}
 function api.step():any
  assert(not closed,"Closed owned-fleet batch")
  local metrics=scheduler.step();local start=os.clock();local installed=false
  for _,r in records do if not r.done then
   local status=scheduler.status(r.handle)
   if status.state=="ready"and not installed then
    local report=scheduler.take(r.handle)
    local ok,candidate=pcall(Country.complete,r.base,r.binding.actor.world,report,r.network)
    if ok and config.isCurrent({countryId=r.base.countryId}) and os.clock()-began<.750 then
     options.install(r.binding,candidate)
    else options.failed(r.binding,if ok then "StaleOrExpiredFleetResult"else tostring(candidate))end
    r.done=true;installed=true
   elseif status.state~="pending"and status.state~="ready"then
    -- Input changes cancel this interval; never bill a stale report or catch up.
    if status.state~="stale" and status.state~="cancelled"then options.failed(r.binding,status.state)end
    r.done=true
   end
   if r.done and r.binding.actor.fleetJob==r then r.binding.actor.fleetJob=nil end
  end end
  metrics.installMs=(os.clock()-start)*1000;return metrics
 end
 function api.done():boolean for _,r in records do if not r.done then return false end end;return true end
 function api.stats():any return scheduler.stats()end
 function api.close()
  if closed then return end;closed=true
  scheduler.close()
  for _,r in records do if r.binding.actor.fleetJob==r then r.binding.actor.fleetJob=nil end end
 end
 return api
end
return table.freeze(Batch)
