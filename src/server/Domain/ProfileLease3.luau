--!strict
local V2Lease=require(script.Parent.ProfileLease2)
local Schema=require(script.Parent.ProfileSchema3)
local Codec=require(script.Parent.ProfileCodec)
local Project=require(script.Parent.ConstructionProject)
local Lease={DURATION_MS=180000,SAFETY_MS=30000}
function Lease.apply(current:any,op:any,now:number,scalar:(any)->string):(any,string?)
 assert(current~=nil,"Schema3 initialization is not implicit")
 Schema.validate(current,op.owner,scalar)
 assert(table.find({"Acquire","Checkpoint","Renew","Release","Build"},op.kind),"Unsupported operation")
 if current.lastCommit.operationId==op.id then return Codec.copy(current),nil end
 local projected=Codec.copy(op)
 if op.kind=="Build" then
  local receipt=current.country.construction.receipt
  if receipt then return nil,"AlreadyBuilt"end
  assert(op.before~=nil and op.snapshot~=nil,"Build requires captured prefix")
  Schema.transition(current.country,op.before,scalar)
  assert(op.countryRevision==op.beforeRevision+1 and op.beforeRevision>=current.countryRevision,"Build revision")
  local expected=Project.build(op.before,op.id,op.countryRevision,current.profileRevision+1)
  assert(Codec.encode(expected,scalar)==Codec.encode(op.snapshot,scalar),"Nonatomic construction")
  projected.kind="Checkpoint"
 elseif op.snapshot then Schema.transition(current.country,op.snapshot,scalar)end
 if op.snapshot then projected.snapshot=Schema.previousCountry(op.snapshot)end
 local p,why=V2Lease.apply(Schema.previous(current),projected,now,scalar)
 if not p then return nil,why end
 p.schemaVersion=3;p.country=Codec.copy(op.snapshot or current.country)
 if op.kind=="Build" then p.lastCommit.kind="Build"end
 Schema.validate(p,op.owner,scalar)
 return p,nil
end
return table.freeze(Lease)
