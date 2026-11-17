--!strict
export type Node = {id:string, kind:string, capacity:number, x:number, y:number, name:string}
export type Line = {id:string, from:string, to:string, capacity:number, connected:boolean}
export type Network = {nodes:{Node}, lines:{Line}, generatorId:string, demandId:string, demandMW:number, population:number}
local Model={}
function Model.units(mw:number):number
 assert(mw==mw and mw>=0 and mw<=100000 and math.abs(mw*1000-math.round(mw*1000))<1e-6,"Invalid MW rating (0.001 MW precision)")
 return math.round(mw*1000)
end
function Model.validate(n:Network)
 assert(#n.nodes>=2 and #n.nodes<=32 and #n.lines<=64,"Network budget")
 Model.units(n.demandMW)
 local ids:{[string]:boolean}={}
 for _,v in n.nodes do
  assert(#v.id>0 and #v.id<=64 and not ids[v.id],"Duplicate/invalid node")
  ids[v.id]=true;Model.units(v.capacity)
 end
 assert(ids[n.generatorId] and ids[n.demandId] and n.generatorId~=n.demandId,"Invalid source/sink")
 local edges:{[string]:boolean}={}
 for _,e in n.lines do
  assert(not edges[e.id] and ids[e.from] and ids[e.to] and e.from~=e.to,"Invalid line")
  edges[e.id]=true;Model.units(e.capacity)
 end
end
function Model.starter():Network
 return {generatorId="station",demandId="capital",demandMW=3,population=1000,
 nodes={
  {id="station",kind="Generator",capacity=5,x=340,y=320,name="Starter Generator"},
  {id="junction",kind="Substation",capacity=10,x=575,y=345,name="Central Substation"},
  {id="capital",kind="Settlement",capacity=10,x=755,y=250,name="Westhaven"}},
 lines={{id="feed",from="station",to="junction",capacity=10,connected=true},
 {id="town",from="junction",to="capital",capacity=10,connected=true}}}
end
return table.freeze(Model)
