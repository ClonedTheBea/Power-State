--!strict
-- Cosmetic coordinates never enter the lossless integer-kW transport model.
local Model=require(script.Parent.Parent.Operations.FleetNetworkModel)
local Wind=require(script.Parent.Parent.Operations.OperationsWind)
local Project=require(script.Parent.WindProject)
local Network={}
function Network.create(c:any,starterKW:number):any
 Model.integer(starterKW,0,3811)
 assert(c.fleet.windReceipt and c.construction.receipt,"Owned two-source composition requires both investments")
 local n:any={version=1,nodes={},lines={},sources={},sinks={}}
 for _,list in {c.network.nodes,c.deltas.builtNodes}do
  for _,node in list do table.insert(n.nodes,{id=node.id,kind=if node.kind=="Settlement"then "Demand"else node.kind,capacityKW=node.capacity*1000})end
 end
 for _,list in {c.network.lines,c.deltas.builtLines}do
  for _,line in list do table.insert(n.lines,{id=line.id,from=line.from,to=line.to,capacityKW=line.capacity*1000,connected=line.connected})end
 end
 local windNode=Project.assets(c)
 for id,u in c.fleet.units do
  local potential=if id==windNode.id then Wind.potential(c.fleet.windSeed,c.fleet.windRegion,c.simulation.step)else 5000
  table.insert(n.sources,{id=id,nodeId=id,availableKW=if u.on then math.min(u.capKW,potential)else 0,costMinorPerMWh=if id==windNode.id then 0 else 8000})
 end
 table.insert(n.sinks,{id=c.network.demandId,nodeId=c.network.demandId,requestedKW=starterKW})
 local district=c.construction.receipt.terminalId
 table.insert(n.sinks,{id=district,nodeId=district,requestedKW=math.floor((starterKW+2)/4)})
 Model.validate(n);return n
end
return table.freeze(Network)
