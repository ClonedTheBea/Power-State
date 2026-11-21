--!strict
-- Shared exact-record primitives; no storage or solver dependencies.
local Codec=require(script.Parent.ProfileCodec)
local Legacy=require(script.Parent.ProfileSchema)
local Record={integer=Legacy.integer,LIMIT=1000000000000000}
local immutableProofs:any=setmetatable({},{__mode="k"})
local function immutable(v:any,seen:any):boolean
 if type(v)~="table"then return true end
 if not table.isfrozen(v)or getmetatable(v)~=nil then return false end
 if immutableProofs[v]then return true end
 assert(not seen[v],"Cyclic immutable record");seen[v]=true
 for _,item in v do if not immutable(item,seen)then seen[v]=nil;return false end end
 seen[v]=nil
 immutableProofs[v]=true;return true
end
function Record.immutable(v:any):boolean return immutable(v,{})end
function Record.snapshot(v:any):any
 -- Copy mutable branches only. Sharing a proven immutable branch cannot alias
 -- a future mutation; the complete returned profile is still schema validated.
 if type(v)~="table"or Record.immutable(v)then return v end
 local n={};for key,item in v do n[key]=Record.snapshot(item)end
 table.freeze(n);immutableProofs[n]=true;return n
end
function Record.fields(t:any,names:string,optional:string?)
 assert(type(t)=="table","Fleet record required")
 local allowed={}
 for key in names:gmatch("%S+")do allowed[key]=true;assert(t[key]~=nil,"Missing fleet field "..key)end
 for key in (optional or ""):gmatch("%S+")do allowed[key]=true end
 for key in t do assert(allowed[key],"Unsupported fleet field "..tostring(key))end
end
function Record.equal(a:any,b:any,scalar:(any)->string)
 assert(Codec.encode(a,scalar)==Codec.encode(b,scalar),"Fleet canonical mismatch")
end
function Record.guid(value:any)
 assert(type(value)=="string" and #value==36 and value:match("^[%x]+%-[%x]+%-[%x]+%-[%x]+%-[%x]+$"),"Fleet operation GUID")
end
function Record.amount(meter:number,rate:number):(number,number)
 local part=(meter%60000)*rate
 return math.floor(meter/60000)*rate+math.floor(part/60000),part%60000
end
function Record.near(a:number,b:number):boolean
 return math.abs(a-b)<=1e-6+1e-9*math.max(math.abs(a),math.abs(b))
end
function Record.freeze(value:any):any
 if type(value)=="table" and not table.isfrozen(value)then
  for _,item in value do Record.freeze(item)end;table.freeze(value)
 end
 return value
end
function Record.copyLive(value:any,baseline:any):any
 if value==baseline and type(baseline)=="table"and table.isfrozen(baseline)then return baseline end
 if type(value)~="table"then return value end
 local n={};for key,item in value do n[key]=Record.copyLive(item,baseline)end;return n
end
return table.freeze(Record)
