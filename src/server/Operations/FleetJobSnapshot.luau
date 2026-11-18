--!strict
local Model=require(script.Parent.FleetNetworkModel)
local Snapshot={}
function Snapshot.copy(input:any):any
 assert(type(input)=="table","Job envelope required")
 local keys={countryId=true,epoch=true,step=true,countryRevision=true,topologyRevision=true,network=true}
 for k in input do assert(keys[k],"Unknown job field")end
 assert(type(input.countryId)=="string" and #input.countryId>0 and #input.countryId<=64,"Country identity")
 for _,k in {"epoch","step","countryRevision","topologyRevision"}do Model.integer(input[k],0,1000000000)end
 Model.validate(input.network)
 -- Validation bounds every record before copying; only scalar leaves are permitted.
 local n:any={version=input.network.version}
 for _,key in {"nodes","lines","sources","sinks"}do
  local list={};for _,record in input.network[key]do table.insert(list,table.freeze(table.clone(record)))end
  n[key]=table.freeze(list)
 end
 return table.freeze({countryId=input.countryId,epoch=input.epoch,step=input.step,countryRevision=input.countryRevision,
  topologyRevision=input.topologyRevision,network=table.freeze(n)})
end
function Snapshot.sameStamp(a:any,b:any):boolean
 if not a or not b then return false end
 for _,key in {"countryId","epoch","step","countryRevision","topologyRevision"}do if a[key]~=b[key]then return false end end
 return true
end
return table.freeze(Snapshot)
