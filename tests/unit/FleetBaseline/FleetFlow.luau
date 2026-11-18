--!strict
-- Reusable topology; each solve owns fresh residual capacities. No mutable global cache.
local Flow={}
function Flow.compile(n:any):any
 local g:any={adj={},to={},cap={},cost={},sourceRefs={},sinkRefs={},lineRefs={},nodeRefs={}}
 local function vertex():number table.insert(g.adj,{});return #g.adj end
 local function edge(a:number,b:number,cap:number,cost:number):number
  local e=#g.to+1
  table.insert(g.to,b);table.insert(g.cap,cap);table.insert(g.cost,cost);table.insert(g.adj[a],e)
  table.insert(g.to,a);table.insert(g.cap,0);table.insert(g.cost,-cost);table.insert(g.adj[b],e+1);return e
 end
 g.source=vertex();g.sink=vertex();local nodes={}
 for _,v in n.nodes do local a,b=vertex(),vertex();nodes[v.id]={a,b};g.nodeRefs[v.id]=edge(a,b,v.capacityKW,0)end
 for _,v in n.sources do g.sourceRefs[v.id]=edge(g.source,nodes[v.nodeId][1],v.availableKW,v.costMinorPerMWh)end
 for _,v in n.sinks do g.sinkRefs[v.id]=edge(nodes[v.nodeId][2],g.sink,0,0)end
 for _,v in n.lines do
  local a,b=nodes[v.from],nodes[v.to];local i,o=vertex(),vertex();local cap=if v.connected then v.capacityKW else 0
  local gate=edge(i,o,cap,0);local fromA=edge(a[2],i,cap,0);edge(b[2],i,cap,0)
  local toA=edge(o,a[1],cap,0);edge(o,b[1],cap,0);g.lineRefs[v.id]={fromA,toA,gate}
 end
 return g
end
local function reverse(e:number):number return if e%2==1 then e+1 else e-1 end
function Flow.run(g:any,targets:any,budget:any,economic:boolean):(number,any)
 local resetStart=if budget.observer then os.clock()else 0
 local cap=table.clone(g.cap);local goal=0
 for id,value in targets do cap[g.sinkRefs[id]]=value;goal+=value end
 if budget.observer then budget.observer.reset(os.clock()-resetStart,#cap)end
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
 return total,cap
end
return table.freeze(Flow)
