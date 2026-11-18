--!strict
-- An existing-country capability: initialization and migration are never legal here.
local Schema=require(script.Parent.ProfileSchema2)
local Lease=require(script.Parent.ProfileLease2)
local Existing={DURATION_MS=Lease.DURATION_MS,SAFETY_MS=Lease.SAFETY_MS}
function Existing.apply(current:any,op:any,now:number,scalar:(any)->string):(any,string?)
 Schema.validate(current,op.owner,scalar)
 assert(op.kind=="Acquire" or op.kind=="Checkpoint" or op.kind=="Renew" or op.kind=="Release","Unsupported existing-country operation")
 return Lease.apply(current,op,now,scalar)
end
return table.freeze(Existing)
