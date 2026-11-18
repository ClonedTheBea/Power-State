--!strict
-- Reusable topology; each solve owns fresh residual capacities. No mutable global cache.
local Flow={}
function Flow.compile(n:any):any
 local g:any={adj={},to={},cap={},cost={},sourceRefs={},sinkRefs={},lineRefs={},nodeRefs={},sourceOrder={}}
 local function vertex():number table.insert(g.adj,{});return #g.adj end
 local function edge(a:number,b:number,cap:number,cost:number):number
  local e=#g.to+1
  table.insert(g.to,b);table.insert(g.cap,cap);table.insert(g.cost,cost);table.insert(g.adj[a],e)
  table.insert(g.to,a);table.insert(g.cap,0);table.insert(g.cost,-cost);table.insert(g.adj[b],e+1);return e
 end
 g.source=vertex();g.sink=vertex();local nodes={}
 for _,v in n.nodes do local a,b=vertex(),vertex();nodes[v.id]={a,b};g.nodeRefs[v.id]=edge(a,b,v.capacityKW,0)end
 for _,v in n.sources do
  local e=edge(g.source,nodes[v.nodeId][1],v.availableKW,v.costMinorPerMWh);g.sourceRefs[v.id]=e
  table.insert(g.sourceOrder,{edge=e,cost=v.costMinorPerMWh,id=v.id})
 end
 table.sort(g.sourceOrder,function(a:any,b:any)return if a.cost==b.cost then a.id<b.id else a.cost<b.cost end)
 g.distinctCosts=true
 for i=2,#g.sourceOrder do if g.sourceOrder[i].cost==g.sourceOrder[i-1].cost then g.distinctCosts=false end end
 for _,v in n.sinks do g.sinkRefs[v.id]=edge(nodes[v.nodeId][2],g.sink,0,0)end
 for _,v in n.lines do
  local a,b=nodes[v.from],nodes[v.to];local i,o=vertex(),vertex();local cap=if v.connected then v.capacityKW else 0
  local gate=edge(i,o,cap,0);local fromA=edge(a[2],i,cap,0);edge(b[2],i,cap,0)
  local toA=edge(o,a[1],cap,0);edge(o,b[1],cap,0);g.lineRefs[v.id]={fromA,toA,gate}
 end
 return g
end
local function reverse(e:number):number return if e%2==1 then e+1 else e-1 end
local function maxFlow(g:any,cap:any,goal:number,budget:any):(number,any)
 local total=0
 while total<goal do
  local level=table.create(#g.adj,-1);level[g.source]=0
  local queue={g.source};local head=1
  while head<=#queue do
   local u=queue[head];head+=1
   for _,e in g.adj[u]do
    budget.used+=1;assert(budget.used<=budget.limit,"Fleet solver operation budget exhausted")
    local v=g.to[e]
    if cap[e]>0 and level[v]<0 then level[v]=level[u]+1;table.insert(queue,v)end
   end
  end
  if level[g.sink]<0 then return total,level end
  local cursor=table.create(#g.adj,1)
  local function push(u:number,amount:number):number
   if u==g.sink then return amount end
   local edges=g.adj[u]
   while cursor[u]<=#edges do
    local e=edges[cursor[u]];local v=g.to[e]
    budget.used+=1;assert(budget.used<=budget.limit,"Fleet solver operation budget exhausted")
    if cap[e]>0 and level[v]==level[u]+1 then
     local sent=push(v,math.min(amount,cap[e]))
     if sent>0 then cap[e]-=sent;cap[reverse(e)]+=sent;return sent end
    end
    cursor[u]+=1
   end
   return 0
  end
  while total<goal do local sent=push(g.source,goal-total);if sent==0 then break end;total+=sent end
 end
 return total,nil
end
-- Extend only a previously certified target vector. Failed trials are discarded.
function Flow.advance(g:any,previous:any,residual:any,targets:any,budget:any):(number,any,any)
 local resetStart=if budget.observer then os.clock()else 0
 local cap:any=table.clone(residual);local base,extra=0,0
 for id,value in targets do
  local delta=value-previous[id];assert(delta>=0,"Incremental targets must not decrease")
  cap[g.sinkRefs[id]]+=delta;base+=previous[id];extra+=delta
 end
 if budget.observer then budget.observer.reset(os.clock()-resetStart,#cap)end
 local added,level=maxFlow(g,cap,extra,budget);local total=base+added
 if added==extra then return total,cap,nil end
 local cut:any={ids={},capacity=total}
 for id,value in targets do
  if level[g.to[reverse(g.sinkRefs[id])]]<0 then table.insert(cut.ids,id)else cut.capacity-=value end
 end
 return total,cap,cut
end
function Flow.run(g:any,targets:any,budget:any,economic:boolean):(number,any,any)
 local resetStart=if budget.observer then os.clock()else 0
 local cap=table.clone(g.cap);local goal=0
 for id,value in targets do cap[g.sinkRefs[id]]=value;goal+=value end
 if budget.observer then budget.observer.reset(os.clock()-resetStart,#cap)end
 if not economic then
  local total,level=maxFlow(g,cap,goal,budget)
  if total==goal then return total,cap,nil end
  -- Cut capacity = fixed crossing arcs + reachable customer target arcs.
  -- Thus every feasible vector must satisfy sum(unreachable targets) <= fixed.
  local cut:any={ids={},capacity=total}
  for id,value in targets do
   if level[g.to[reverse(g.sinkRefs[id])]]<0 then table.insert(cut.ids,id)
   else cut.capacity-=value end
  end
  return total,cap,cut
 end
 -- Costs exist only on source arcs. Feasible source injections form a network
 -- polymatroid: saturating increasing-cost prefixes gives the minimum-cost base.
 -- Residual reverse arcs reroute existing delivery; no physical path is frozen.
 -- Retain the original shortest-path tie behavior for equal-cost sources.
 if g.distinctCosts then
  for _,v in g.sourceOrder do cap[v.edge]=0 end
  local total=0
  for _,v in g.sourceOrder do
   cap[v.edge]=g.cap[v.edge]
   total+=maxFlow(g,cap,goal-total,budget)
   if total==goal then break end
  end
  -- Disabled source arcs must still report zero output against original capacity.
  for _,v in g.sourceOrder do if cap[reverse(v.edge)]==0 then cap[v.edge]=g.cap[v.edge]end end
  return total,cap,nil
 end
 local total=0
 while total<goal do
  local parent={};local queue={g.source};local head=1
  local distance={[g.source]=0};local queued={[g.source]=true}
  while head<=#queue do
   local u=queue[head];head+=1;queued[u]=nil
   if not economic and u==g.sink then break end
   for _,e in g.adj[u]do
    budget.used+=1;assert(budget.used<=budget.limit,"Fleet solver operation budget exhausted")
    local v=g.to[e]
    if cap[e]>0 and v~=g.source then
     local d=distance[u]+(if economic then g.cost[e]else 1)
     if distance[v]==nil or (economic and d<distance[v])then
      distance[v]=d;parent[v]=e
      if not queued[v]then queued[v]=true;table.insert(queue,v)end
     end
    end
   end
  end
  if not parent[g.sink]then break end
  local amount=goal-total;local at=g.sink;local length=0
  while at~=g.source do
   length+=1;assert(length<=#g.adj,"Invalid residual path")
   local e=parent[at];amount=math.min(amount,cap[e]);at=g.to[reverse(e)]
  end
  at=g.sink
  while at~=g.source do local e=parent[at];cap[e]-=amount;cap[reverse(e)]+=amount;at=g.to[reverse(e)]end
  total+=amount
 end
 return total,cap,nil
end
-- With all current targets met, a residual path to a sink terminal is exactly
-- the condition for one additional kW without reducing any other delivered target.
function Flow.grow(g:any,cap:any,id:string,budget:any):(boolean,any)
 local target=g.to[reverse(g.sinkRefs[id])]
 local seen={[g.source]=true};local parent={};local queue={g.source};local head=1
 while head<=#queue and not seen[target]do
  local u=queue[head];head+=1
  for _,e in g.adj[u]do
   budget.used+=1;assert(budget.used<=budget.limit,"Fleet solver operation budget exhausted")
   local v=g.to[e]
   if cap[e]>0 and v~=g.sink and not seen[v]then seen[v]=true;parent[v]=e;table.insert(queue,v)end
  end
 end
 if not seen[target]then return false,seen end
 local at=target
 while at~=g.source do local e=parent[at];cap[e]-=1;cap[reverse(e)]+=1;at=g.to[reverse(e)]end
 cap[reverse(g.sinkRefs[id])]+=1
 return true,seen
end
function Flow.sinkVertex(g:any,id:string):number return g.to[reverse(g.sinkRefs[id])]end
return table.freeze(Flow)
