--!strict
-- Lossless transport only. Progressive proportional filling then economic routing.
local Model=require(script.Parent.FleetNetworkModel)
local Flow=require(script.Parent.FleetFlow)
local Solver={VERSION=1}
local function sorted(list:any):any local a=table.clone(list);table.sort(a,function(x:any,y:any)return x.id<y.id end);return a end
function Solver.solve(input:any,step:number,operationLimit:number?,observer:any?):any
 if observer then observer.phase("validation")end
 Model.validate(input);Model.integer(step,0,1000000000)
 local limit=operationLimit or Model.MAX_OPERATIONS;Model.integer(limit,1,Model.MAX_OPERATIONS)
 local n={nodes=sorted(input.nodes),lines=sorted(input.lines),sources=sorted(input.sources),sinks=sorted(input.sinks)}
 if observer then observer.phase("compile")end
 local g=Flow.compile(n);local budget={used=0,limit=limit,observer=observer};local targets={};local active={};local demand=0
 for _,v in n.sinks do targets[v.id]=0;demand+=v.requestedKW;if v.requestedKW>0 then table.insert(active,v)end end
 local feasibleTargets:any=nil;local feasibleResidual:any=nil
 local function feasible(t:any):boolean
  local wanted=0;for _,v in t do wanted+=v end
  local delivered,residual=Flow.run(g,t,budget,false)
  if delivered==wanted then feasibleTargets=t;feasibleResidual=residual;return true end
  return false
 end
 local rounds=0;local tieOrder={}
 for i,v in n.sinks do tieOrder[v.id]=(i-1-step)%#n.sinks end
 while #active>0 do
  if observer then observer.phase("progressive")end
  rounds+=1;assert(rounds<=8,"Fleet freeze-round bound")
  local full=table.clone(targets)
  for _,v in active do full[v.id]=v.requestedKW end
  local maximum=Flow.run(g,full,budget,false)
  -- Maximum transport is an upper bound, not a substitute for fair feasibility.
  -- Integer floors are included when bounding the common fraction.
  local lower,upper=0,1000
  while lower<upper do
   local mid=math.ceil((lower+upper)/2);local amount=0
   for _,v in n.sinks do amount+=targets[v.id]end
   for _,v in active do amount+=math.max(targets[v.id],math.floor(v.requestedKW*mid/1000))-targets[v.id]end
   if amount<=maximum then lower=mid else upper=mid-1 end
  end
  local low,high=0,lower
  local trial=table.clone(targets)
  for _,v in active do trial[v.id]=math.max(trial[v.id],math.floor(v.requestedKW*high/1000))end
  if feasible(trial)then low=high else high-=1 end
  while low<high do
   local mid=math.ceil((low+high)/2);local trial=table.clone(targets)
   for _,v in active do trial[v.id]=math.max(trial[v.id],math.floor(v.requestedKW*mid/1000))end
   if feasible(trial)then low=mid else high=mid-1 end
  end
  for _,v in active do targets[v.id]=math.max(targets[v.id],math.floor(v.requestedKW*low/1000))end
  if low==1000 then break end
  -- Complete the fractional quantum in 1-kW increments. Freeze a sink only
  -- after residual rerouting proves its next kW infeasible while retaining peers.
  if observer then observer.phase("remainder")end
  local same=feasibleTargets~=nil
  for id,value in targets do if not feasibleTargets or feasibleTargets[id]~=value then same=false;break end end
  local residual=feasibleResidual
  if not same then local _;_,residual=Flow.run(g,targets,budget,false)end
  local increments=0
  while true do
   table.sort(active,function(a,b)
    local left,right=targets[a.id]*b.requestedKW,targets[b.id]*a.requestedKW
    return if left==right then tieOrder[a.id]<tieOrder[b.id]else left<right
   end)
   local v=active[1]
   if targets[v.id]>=v.requestedKW then table.remove(active,1);break end
   local grown,reachable=Flow.grow(g,residual,v.id,budget)
   if not grown then
    if observer then observer.phase("freezing")end
    local removed=0
    for i=#active,1,-1 do
     local item=active[i]
     if targets[item.id]>=item.requestedKW or not reachable[Flow.sinkVertex(g,item.id)]then table.remove(active,i);removed+=1 end
    end
    assert(removed>0,"Failed increment requires a bottleneck cut")
    break
   end
   targets[v.id]+=1;increments+=1
   assert(increments<=math.ceil(demand/1000)+#n.sinks,"Fleet rounding bound")
  end
 end
 if observer then observer.phase("cost")end
 local total,cap=Flow.run(g,targets,budget,true)
 if observer then observer.phase("report")end
 local result:any={version=1,generatedKW=0,deliveredKW=total,requestedKW=demand,unmetKW=demand-total,
  sources={},sinks={},flowsKW={},throughputKW={},operations=budget.used,freezeRounds=rounds,costNumerator=0}
 local balance={};for _,v in n.nodes do balance[v.id]=0;local e=g.nodeRefs[v.id];result.throughputKW[v.id]=g.cap[e]-cap[e];assert(result.throughputKW[v.id]<=v.capacityKW,"Node capacity")end
 for _,v in n.sources do
  local e=g.sourceRefs[v.id];local output=g.cap[e]-cap[e];assert(output>=0 and output<=v.availableKW,"Source capacity")
  result.sources[v.id]=output;result.generatedKW+=output;result.costNumerator+=output*v.costMinorPerMWh;balance[v.nodeId]+=output
 end
 local delivered=0
 for _,v in n.sinks do
  local actual=targets[v.id]-cap[g.sinkRefs[v.id]];assert(actual==targets[v.id] and actual<=v.requestedKW,"Fair target delivery")
  result.sinks[v.id]={requestedKW=v.requestedKW,deliveredKW=actual,unmetKW=v.requestedKW-actual};balance[v.nodeId]-=actual;delivered+=actual
 end
 for _,v in n.lines do
  local refs=g.lineRefs[v.id];local flow=(g.cap[refs[1]]-cap[refs[1]])-(g.cap[refs[2]]-cap[refs[2]])
  assert(math.abs(flow)<=v.capacityKW and (v.connected or flow==0),"Physical link capacity")
  result.flowsKW[v.id]=flow;balance[v.from]-=flow;balance[v.to]+=flow
 end
 for _,v in balance do assert(v==0,"Node conservation")end
 assert(result.generatedKW==total and delivered==total,"National conservation")
 if observer then observer.finish(budget.used)end
 return result
end
return table.freeze(Solver)
