--!strict
-- Storage-only envelope. Gameplay and leases always receive canonical schema4.
local C=require(script.Parent.ProfileCodec)
local V=require(script.Parent.ProfileSchema4)
local R=require(script.Parent.FleetRecord)
local Format={NAME="PowerStateHistoryPairs",VERSION=1}
-- Full-record proofs only for recursively immutable envelopes. Never trust a
-- checksum or mutable table; owner and scalar encoder identity remain pinned.
local proofs:any=setmetatable({},{__mode="k"})
local entries=0;local bytes=0
local function remember(envelope:any,canonical:any,owner:number,scalar:(any)->string)
 local cost=#C.encode(envelope,scalar)+#C.encode(canonical,scalar)
 if entries>=16 or bytes+cost>4194304 then proofs=setmetatable({},{__mode="k"});entries=0;bytes=0 end
 proofs[envelope]={canonical=R.snapshot(canonical),owner=owner,scalar=scalar}
 entries+=1;bytes+=cost -- Encoded-equivalent payload bound; table/allocator overhead is additional.
end
local function rings(p:any):{any}
 return {p.country.simulation.history,p.country.fleet.baseline.legacySimulation.history}
end
function Format.pack(profile:any,owner:number,scalar:(any)->string):any
 V.validate(profile,owner,scalar)
 local p=C.copy(profile)
 for _,ring in rings(p)do
  for i,row in ring do ring[i]={row.requested,row.delivered}end
 end
 local envelope={storageFormat=Format.NAME,storageVersion=Format.VERSION,profile=p}
 C.encode(envelope,scalar) -- Physical record retains the same byte/depth/node limits.
 return R.snapshot(envelope)
end
function Format.read(value:any,owner:number,scalar:(any)->string):any
 C.encode(value,scalar) -- Reject cycles, excessive traversal and size before allocation.
 assert(type(value)=="table","Storage record required")
 local proof=proofs[value]
 if proof and proof.owner==owner and proof.scalar==scalar then
  return R.copyLive(proof.canonical,proof.canonical.country.fleet.baseline)
 end
 if value.storageFormat==nil and value.storageVersion==nil then
  V.validate(value,owner,scalar)
  local canonical=C.copy(value);R.freeze(canonical.country.fleet.baseline);return canonical
 end
 R.fields(value,"storageFormat storageVersion profile")
 assert(value.storageFormat==Format.NAME and value.storageVersion==Format.VERSION,"Unknown storage format")
 local p=C.copy(value.profile)
 assert(p.schemaVersion==4,"Compact format requires schema4")
 for _,ring in rings(p)do
  assert(type(ring)=="table" and #ring<=1440,"Bounded compact history")
  local count=0
  for i,pair in ring do
   R.integer(i,1,#ring);count+=1
   assert(type(pair)=="table" and #pair==2,"Exact history pair")
   local keys=0;for k in pair do assert(k==1 or k==2,"Unknown pair field");keys+=1 end
   assert(keys==2 and type(pair[1])=="number" and type(pair[2])=="number","Numeric history pair")
   ring[i]={requested=pair[1],delivered=pair[2]}
  end
  assert(count==#ring,"Dense compact history")
 end
 -- The immutable legacy audit branch may be shared, never used as writable live state.
 R.freeze(p.country.fleet.baseline)
 V.validate(p,owner,scalar) -- Includes unchanged schema3 legacy projection.
 if R.immutable(value)then remember(value,p,owner,scalar)end
 return p
end
return table.freeze(Format)
