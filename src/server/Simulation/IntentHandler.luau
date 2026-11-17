--!strict
local Country=require(script.Parent.Country)
local Solver=require(script.Parent.GridSolver)
local Handler={}
local function integer(value:any,maximum:number):boolean
 return type(value)=="number" and value==value and value>=0 and value<=maximum and value%1==0
end
function Handler.handle(state:Country.State,actor:number,payload:any,now:number):string
 if actor~=state.owner then return "Unauthorized" end
 state.tokens=math.min(4,state.tokens+math.max(0,now-state.rateAt)*2);state.rateAt=now
 if state.tokens<1 then return "RateLimited" end
 state.tokens-=1
 if type(payload)~="table" then return "Malformed" end
 local count=0
 for key,value in payload do
  count+=1;if count>7 or type(key)~="string" or (type(value)~="string" and type(value)~="number" and type(value)~="boolean") then return "Malformed" end
  if type(value)=="string" and #value>64 then return "Malformed" end
 end
 if payload.version~=1 then return "Malformed" end
 if payload.kind=="Unsubscribe" then return if count==2 then "Unsubscribed" else "Malformed" end
 if payload.kind=="Sync" then return if count==2 then "Synced" else "Malformed" end
 local allowed={version=true,kind=true,epoch=true,sequence=true,revision=true,assetId=true,online=true}
 for key in payload do if not allowed[key] then return "Malformed" end end
 if count~=7 or payload.kind~="SetGenerator" or type(payload.online)~="boolean"
  or not integer(payload.sequence,1000000) or payload.sequence<1 or not integer(payload.revision,1000000) then return "Malformed" end
 if payload.epoch~=state.epoch then return "StaleSession" end
 if payload.assetId~=state.network.generatorId then return "UnauthorizedAsset" end
 if payload.sequence<=state.lastSequence then return "Duplicate" end
 if payload.sequence~=state.lastSequence+1 then return "OutOfOrder" end
 -- Consume a valid sequence even on a stale/no-op transition; only Sync can refresh client state.
 state.lastSequence=payload.sequence
 if state.suspended then return "Suspended" end
 if payload.revision~=state.controlRevision then return "StaleRevision" end
 if payload.online==state.online then return "NoChange" end
 local report=Solver.solve(state.network,payload.online)
 state.online=payload.online;state.report=report;state.controlRevision+=1;state.revision+=1
 -- Immediate power response does not award an extra energy step.
 return "Accepted"
end
return table.freeze(Handler)
