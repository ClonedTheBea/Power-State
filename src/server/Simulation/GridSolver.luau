--!strict
-- Integer-kW residual max flow. One source/sink, equal cost: no priority/economic dispatch.
local Model=require(script.Parent.NetworkModel)
type Edge={to:number,reverse:number,capacity:number,initial:number}
local Solver={}
function Solver.solve(network:Model.Network,online:boolean)
 Model.validate(network)
 local graph:{{Edge}}={};local vertices:{[string]:{number}}={}
 local function vertex():number table.insert(graph,{});return #graph end
 local function edge(a:number,b:number,capacity:number):Edge
  local forward={to=b,reverse=#graph[b]+1,capacity=capacity,initial=capacity}
  local backward={to=a,reverse=#graph[a]+1,capacity=0,initial=0}
  table.insert(graph[a],forward);table.insert(graph[b],backward);return forward
 end
 local nodes=table.clone(network.nodes);table.sort(nodes,function(a,b)return a.id<b.id end)
 local lines=table.clone(network.lines);table.sort(lines,function(a,b)return a.id<b.id end)
 local source,sink=vertex(),vertex();local available=0
 for _,n in nodes do
  local a,b=vertex(),vertex();vertices[n.id]={a,b};edge(a,b,Model.units(n.capacity))
  if n.id==network.generatorId then available=if online then n.capacity else 0;edge(source,a,Model.units(available)) end
  if n.id==network.demandId then edge(b,sink,Model.units(network.demandMW)) end
 end
 local references:{[string]:{Edge}}={}
 for _,l in lines do
  -- One physical capacity gate is shared by both directions; endpoints cannot bypass it.
  local a,b=vertices[l.from],vertices[l.to];local i,o=vertex(),vertex()
  local cap=if l.connected then Model.units(l.capacity) else 0
  edge(i,o,cap)
  local fromA=edge(a[2],i,cap);edge(b[2],i,cap)
  local toA=edge(o,a[1],cap);edge(o,b[1],cap)
  references[l.id]={fromA,toA}
 end
 local total,operations=0,0
 while true do
  local parent:{[number]:{number}}={[source]={0,0}};local queue={source};local head=1
  while head<=#queue and not parent[sink] do
   local a=queue[head];head+=1
   for index,e in graph[a] do
    operations+=1;assert(operations<=200000,"Solver operation budget exhausted")
    if e.capacity>0 and not parent[e.to] then parent[e.to]={a,index};table.insert(queue,e.to) end
   end
  end
  if not parent[sink] then break end
  local amount=math.huge;local at=sink
  while at~=source do local p=parent[at];amount=math.min(amount,graph[p[1]][p[2]].capacity);at=p[1] end
  at=sink
  while at~=source do
   local p=parent[at];local e=graph[p[1]][p[2]];e.capacity-=amount;graph[at][e.reverse].capacity+=amount;at=p[1]
  end
  total+=amount
 end
 local flows:{[string]:number}={}
 for id,r in references do flows[id]=((r[1].initial-r[1].capacity)-(r[2].initial-r[2].capacity))/1000 end
 local reachable:{[string]:boolean}={[network.generatorId]=true}
 for _=1,#nodes do for _,l in lines do if l.connected then
  if reachable[l.from] then reachable[l.to]=true end
  if reachable[l.to] then reachable[l.from]=true end
 end end end
 local delivered=total/1000;local unmet=network.demandMW-delivered
 assert(delivered<=available and delivered<=network.demandMW and unmet>=0,"Power conservation")
 for _,l in lines do assert(math.abs(flows[l.id])<=l.capacity+1e-9,"Physical line rating") end
 local status=if network.demandMW==0 then "No demand" elseif unmet==0 then "Served"
  elseif not reachable[network.demandId] then "Disconnected" elseif available==0 then "Generator offline"
  elseif delivered==available then "Generation shortfall" else "Network bottleneck"
 return {availableMW=available,outputMW=delivered,demandMW=network.demandMW,deliveredMW=delivered,
  unmetMW=unmet,headroomMW=available-delivered,status=status,flows=flows,operations=operations,
  serviceRatio=if network.demandMW>0 then delivered/network.demandMW else -1}
end
return table.freeze(Solver)
