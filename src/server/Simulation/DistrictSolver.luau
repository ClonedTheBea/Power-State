--!strict
-- Composition v2 has no scarce-source allocation policy. Each admissible pair
-- fits every shared gate; unsupported deratings/topologies must be rejected.
local Solver=require(script.Parent.GridSolver)
local Model=require(script.Parent.NetworkModel)
local Starter=require(script.Parent.Parent.World.StarterValidator)
local Project=require(script.Parent.Parent.Domain.ConstructionProject)
local Codec=require(script.Parent.Parent.Domain.ProfileCodec)
local District={VERSION=2}
function District.solve(country:any,starterMW:number,online:boolean,branchConnected:boolean?):any
 local network=Codec.copy(country.network)
 local expected=Starter.network(Project.layout(country))
 assert(#network.nodes==3 and #network.lines==2,"Unsupported district topology")
 for i,n in network.nodes do for k,v in expected.nodes[i]do assert(n[k]==v,"Unsupported district node")end end
 for i,l in network.lines do for k,v in expected.lines[i]do assert(l[k]==v,"Unsupported upstream link")end end
 local starterKW=Model.units(starterMW)
 assert(starterKW<=3811,"Unsupported starter demand")
 network.demandMW=starterMW
 local first:any=Solver.solve(network,online)
 first.sinks={{id=network.demandId,requestedMW=starterMW,deliveredMW=first.deliveredMW,unmetMW=first.unmetMW}}
 if not country.construction.receipt then return first end
 local districtKW=math.floor((starterKW+2)/4)
 assert(starterKW+districtKW<=5000 and districtKW<=1000,"Unsupported competitive dispatch")
 local node,line=Project.assets(country)
 line.connected=branchConnected~=false
 table.insert(network.nodes,node);table.insert(network.lines,line)
 network.demandId=node.id;network.demandMW=districtKW/1000
 local second=Solver.solve(network,online)
 local result=Codec.copy(first)
 result.sinks[2]={id=node.id,requestedMW=second.demandMW,deliveredMW=second.deliveredMW,unmetMW=second.unmetMW}
 result.demandMW+=second.demandMW;result.deliveredMW+=second.deliveredMW;result.outputMW=result.deliveredMW
 result.unmetMW=result.demandMW-result.deliveredMW;result.headroomMW=result.availableMW-result.deliveredMW
 result.serviceRatio=if result.demandMW>0 then result.deliveredMW/result.demandMW else -1
 result.operations+=second.operations;assert(result.operations<=200000,"District solver budget")
 for id,flow in second.flows do result.flows[id]=(result.flows[id] or 0)+flow end
 for _,l in network.lines do assert(math.abs(result.flows[l.id])<=l.capacity+1e-9,"Shared physical capacity")end
 assert(result.deliveredMW<=result.availableMW+1e-9,"Shared generation capacity")
 result.status=if result.unmetMW<1e-9 then "Served" elseif not online then "Generator offline" else "Disconnected"
 return result
end
return table.freeze(District)
