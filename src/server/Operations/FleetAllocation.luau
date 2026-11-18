--!strict
-- Exact constraint generation for the approved quantized progressive policy.
-- See NATIONAL-GRID-OPERATIONS-STAGE1C.md for the cut and prefix arguments.
local Flow=require(script.Parent.FleetFlow)
local Allocation={}
function Allocation.solve(n:any,g:any,step:number,budget:any,observer:any):(any,number)
 local targets={};local active={};local tieOrder={};local cuts={};local cutByKey={};local bits={};local demand=0
 for i,v in n.sinks do targets[v.id]=0;bits[v.id]=2^(i-1);demand+=v.requestedKW;tieOrder[v.id]=(i-1-step)%#n.sinks;if v.requestedKW>0 then table.insert(active,v)end end
 local function remember(cut:any)
  table.sort(cut.ids);local key=0;for _,id in cut.ids do key+=bits[id]end
  local old=cutByKey[key]
  if old then assert(cut.capacity<old.capacity,"Cut must tighten rejected vector");old.capacity=cut.capacity
  else table.insert(cuts,cut);cutByKey[key]=cut end
  assert(#cuts<=255,"Eight-sink cut bound")
 end
 -- Universal single-node and aggregate source cuts avoid trivial failed flows.
 local nodes={};for _,v in n.nodes do nodes[v.id]=v end
 local supply=0;for _,v in n.sources do supply+=v.availableKW end
 if #n.sinks>1 then local ids={};for _,v in n.sinks do table.insert(ids,v.id)end;remember({ids=ids,capacity=supply})end
 for _,v in n.sinks do remember({ids={v.id},capacity=math.min(nodes[v.nodeId].capacityKW,supply)})end
 local function checkpoint(name:string)if budget.checkpoint then budget.checkpoint(name)end end
 local function allowed(t:any):boolean
  checkpoint("cut-test")
  for _,cut in cuts do local total=0;for _,id in cut.ids do total+=t[id]end;if total>cut.capacity then return false end end
  return true
 end
 local certified=table.clone(targets);local residual=table.clone(g.cap)
 local function feasible(t:any):boolean
  checkpoint("feasibility")
  local wanted=0;for _,value in t do wanted+=value end
  local total,nextResidual,cut=Flow.advance(g,certified,residual,t,budget)
  if total==wanted then certified=t;residual=nextResidual;return true end
  assert(cut and #cut.ids>0 and cut.capacity>=0,"Valid failed-flow cut")
  remember(cut);return false
 end
 local rounds=0
 while #active>0 do
  checkpoint("round")
  if observer then observer.phase("progressive")end
  rounds+=1;assert(rounds<=8,"Fleet freeze-round bound")
  local function fraction(f:number):any
   local t=table.clone(targets)
   for _,v in active do t[v.id]=math.max(t[v.id],math.floor(v.requestedKW*f/1000))end
   return t
  end
  local high=1000;local chosen:any=nil
  while true do
   -- Monotone integer search over cheap cut sums, never over flow feasibility.
   local lo,hi=0,high
   while lo<hi do local mid=math.ceil((lo+hi)/2);if allowed(fraction(mid))then lo=mid else hi=mid-1 end end
   local trial=fraction(lo)
   if feasible(trial)then high=lo;chosen=trial;break end
   assert(lo>0,"Existing feasible minima cannot be rejected");high=lo-1
  end
  targets=chosen
  if high==1000 then break end
  if observer then observer.phase("remainder")end
  -- Generate exactly the old ordered 1-kW sequence, independent of routing.
  -- Prefix feasibility is downward closed; a rejected prefix supplies a new cut.
  local prefixes={table.clone(targets)};local order=table.clone(active);local t=table.clone(targets);local fullId:string?=nil
  local bound=math.ceil(demand/1000)+#n.sinks
  for _=0,bound do
   checkpoint("prefix")
   table.sort(order,function(a:any,b:any)
    local left,right=t[a.id]*b.requestedKW,t[b.id]*a.requestedKW
    return if left==right then tieOrder[a.id]<tieOrder[b.id]else left<right
   end)
   local v=order[1]
   if t[v.id]>=v.requestedKW then fullId=v.id;break end
   t[v.id]+=1;table.insert(prefixes,table.clone(t))
  end
  local upper=#prefixes;local selected=1
  while true do
   local lo,hi=1,upper
   while lo<hi do local mid=math.ceil((lo+hi)/2);if allowed(prefixes[mid])then lo=mid else hi=mid-1 end end
   if lo==1 or feasible(prefixes[lo])then selected=lo;break end
   upper=lo-1
  end
  targets=prefixes[selected]
  checkpoint("freeze")
  if observer then observer.phase("freezing")end
  if selected==#prefixes and fullId then
   for i,v in active do if v.id==fullId then table.remove(active,i);break end end
  else
   assert(selected<#prefixes,"Remainder exceeded approved quantum bound")
   -- A binding necessary cut makes every member individually unaugmentable.
   local blocked={}
   for _,cut in cuts do local total=0;for _,id in cut.ids do total+=targets[id]end;if total==cut.capacity then for _,id in cut.ids do blocked[id]=true end end end
   local removed=0
   for i=#active,1,-1 do if blocked[active[i].id]then table.remove(active,i);removed+=1 end end
   assert(removed>0,"First rejected increment requires a binding cut")
  end
 end
 return targets,rounds
end
return table.freeze(Allocation)
